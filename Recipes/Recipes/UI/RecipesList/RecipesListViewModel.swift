//
//  RecipesListViewModel.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/25/24.
//

import Combine
import Foundation

struct RecipesListContent {
    let cuisineTabViewModels: [RecipesListCuisineTabCellViewModel]
    let recipesViewModels: [RecipesListRecipeCellViewModel]
    
    static func empty() -> Self {
        RecipesListContent(cuisineTabViewModels: [], recipesViewModels: [])
    }
}

enum RecipesListState {
    case loadingWithoutContent
    case error(RecipesListInfoViewModelType)
    case empty(RecipesListInfoViewModelType)
    case content(RecipesListContent, animated: Bool)
    
    var isContent: Bool {
        if case .content = self {
            return true
        }
        return false
    }
}

protocol RecipesListViewModelType {
    var state: any Publisher<RecipesListState, Never> { get }
    
    func onWillAppear()
    func onPullToRefresh()
    func onItemSelection(indexPath: IndexPath)
}

final class RecipesListViewModel: RecipesListViewModelType {
    var state: any Publisher<RecipesListState, Never> {
        stateSubject
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
    }
    
    private let recipesRepository: RecipesRepositoryType
    private let urlOpenerService: URLOpenerServiceType
    
    private let stateSubject = CurrentValueSubject<RecipesListState?, Never>(nil)
    private var overallContent: RecipesListContent = .empty()
    private var isLoading = false
    
    init(
        recipesRepository: RecipesRepositoryType,
        urlOpenerService: URLOpenerServiceType
    ) {
        self.recipesRepository = recipesRepository
        self.urlOpenerService = urlOpenerService
    }
    
    func onWillAppear() {
        updateRecipes()
    }
    
    func onPullToRefresh() {
        updateRecipes()
    }
    
    func onItemSelection(indexPath: IndexPath) {
        guard indexPath.section == 0,
              case let .content(content, _) = stateSubject.value
        else { return }
        
        let currentCuisineTabViewModels = content.cuisineTabViewModels
        let currentSelectedCuisineIndex = currentCuisineTabViewModels
            .firstIndex(where: { $0.isSelected }) ?? 0
        
        guard indexPath.item < currentCuisineTabViewModels.count,
              indexPath.item != currentSelectedCuisineIndex
        else { return }
        
        let newCuisineTabViewModels = currentCuisineTabViewModels
            .enumerated()
            .map { index, tabViewModel in
                RecipesListCuisineTabCellViewModel(
                    title: tabViewModel.title,
                    isSelected: index == indexPath.item
                )
            }
        
        let filteredCuisine = newCuisineTabViewModels[indexPath.item].title
        
        let allCuisinesTabTitle = NSLocalizedString("RecipesList.AllCuisinesTabTitle", comment: "")
    
        let newRecipesViewModels = if filteredCuisine == allCuisinesTabTitle {
            overallContent.recipesViewModels
        } else {
            overallContent.recipesViewModels
                .filter { $0.cuisine == filteredCuisine }
        }
        
        let currentSelectedCuisine = currentCuisineTabViewModels
            .first(where: { $0.isSelected })?
            .title ?? ""
        let newSelectedCuisine = newCuisineTabViewModels[indexPath.item].title
        
        let animated = currentSelectedCuisine == allCuisinesTabTitle
            || newSelectedCuisine == allCuisinesTabTitle
        
        stateSubject.send(
            .content(
                RecipesListContent(
                    cuisineTabViewModels: newCuisineTabViewModels,
                    recipesViewModels: newRecipesViewModels
                ),
                animated: animated
            )
        )
    }
}

// MARK: - Private methods
private extension RecipesListViewModel {
    func updateRecipes() {
        guard !isLoading else { return }
        
        isLoading = true
        
        if !(stateSubject.value?.isContent ?? false)  {
            stateSubject.send(.loadingWithoutContent)
        }
        
        Task { @MainActor in
            do {
                let recipes = try await recipesRepository.getRecipes()
                
                isLoading = false
                
                if recipes.isEmpty {
                    stateSubject.send(
                        .empty(
                            RecipesListEmptyInfoViewModel(
                                onButtonTap: { [weak self] in
                                    self?.updateRecipes()
                                }
                            )
                        )
                    )
                    overallContent = .empty()
                } else {
                    let (cuisineTabViewModels, recipesViewModels) = makeCellViewModels(from: recipes)
                    
                    stateSubject.send(
                        .content(
                            RecipesListContent(
                                cuisineTabViewModels: cuisineTabViewModels,
                                recipesViewModels: recipesViewModels
                            ),
                            animated: false
                        )
                    )
                    overallContent = RecipesListContent(
                        cuisineTabViewModels: cuisineTabViewModels,
                        recipesViewModels: recipesViewModels
                    )
                }
            } catch {
                isLoading = false
                
                stateSubject.send(
                    .error(
                        RecipesListErrorInfoViewModel(
                            onButtonTap: { [weak self] in
                                self?.updateRecipes()
                            }
                        )
                    )
                )
                overallContent = .empty()
            }
        }
    }
    
    func makeCellViewModels(
        from recipes: [RecipeDTO]
    ) -> ([RecipesListCuisineTabCellViewModel], [RecipesListRecipeCellViewModel]) {
        var cuisineTabViewModels: [RecipesListCuisineTabCellViewModel] = []
        var recipesViewModels: [RecipesListRecipeCellViewModel] = []
        
        for recipe in recipes {
            if !cuisineTabViewModels.contains(where: { $0.title == recipe.cuisine }) {
                cuisineTabViewModels.append(
                    RecipesListCuisineTabCellViewModel(
                        title: recipe.cuisine,
                        isSelected: false
                    )
                )
            }

            recipesViewModels.append(
                RecipesListRecipeCellViewModel(
                    imageURL: makeURL(from: recipe.largePhotoURL),
                    name: recipe.name,
                    cuisine: recipe.cuisine,
                    sourceURL: makeURL(from: recipe.sourceURL),
                    youtubeURL: makeURL(from: recipe.youtubeURL),
                    urlOpenerService: urlOpenerService
                )
            )
        }
        
        cuisineTabViewModels.sort(by: { $0.title < $1.title })
        cuisineTabViewModels.insert(
            RecipesListCuisineTabCellViewModel(
                title: NSLocalizedString("RecipesList.AllCuisinesTabTitle", comment: ""),
                isSelected: true
            ),
            at: 0
        )
        
        return (cuisineTabViewModels, recipesViewModels)
    }
    
    func makeURL(from string: String?) -> URL? {
        if let string, let url = URL(string: string) {
            url
        } else {
            nil
        }
    }
}
