//
//  RecipesListViewController.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/25/24.
//

import UIKit
import Combine
import SnapKit

final class RecipesListViewController: UIViewController {
    private enum CollectionViewSection {
        case cuisineTabs
        case recipes
    }
    
    private let staticContentStackView = UIStackView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let refreshControl = UIRefreshControl()
    
    private let viewModel: RecipesListViewModelType
    
    private var dataSource: UICollectionViewDiffableDataSource<CollectionViewSection, AnyHashable>?
    private var cancellables: [AnyCancellable] = []
    
    init(viewModel: RecipesListViewModelType) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewComponents()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onWillAppear()
    }
}

// MARK: - Private methods
private extension RecipesListViewController {
    func configureViewComponents() {
        configureLayout()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = NSLocalizedString("RecipesList.NavigationBarTitle", comment: "")
        
        view.backgroundColor = .white
        
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.register(
            RecipesListCuisineTabCellView.self,
            forCellWithReuseIdentifier: "RecipesListCuisineTabCellView"
        )
        collectionView.register(
            RecipesListRecipeCellView.self,
            forCellWithReuseIdentifier: "RecipesListRecipeCellView"
        )
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            if let cuisineTabCellViewModel = item as? RecipesListCuisineTabCellViewModel,
               let cell = collectionView.dequeueReusableCell(
                   withReuseIdentifier: "RecipesListCuisineTabCellView",
                   for: indexPath
               ) as? RecipesListCuisineTabCellView {
                cell.configure(using: cuisineTabCellViewModel)
                return cell
            } else if let recipeCellViewModel = item as? RecipesListRecipeCellViewModel,
                      let cell = collectionView.dequeueReusableCell(
                          withReuseIdentifier: "RecipesListRecipeCellView",
                          for: indexPath
                      ) as? RecipesListRecipeCellView {
                cell.configure(using: recipeCellViewModel)
                return cell
            }
            
            return UICollectionViewCell()
        }
        
        staticContentStackView.isHidden = false
        collectionView.isHidden = true
        
        refreshControl.addTarget(
            self,
            action: #selector(onPullToRefresh),
            for: .valueChanged
        )
    }
    
    func configureLayout() {
        view.addSubview(collectionView)
        view.addSubview(staticContentStackView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(view)
        }
        
        staticContentStackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    func bindViewModel() {
        viewModel.state
            .sink(receiveValue: { [weak self] state in
                guard let self else { return }
                
                switch state {
                    case .loadingWithoutContent:
                        staticContentStackView.isHidden = false
                        collectionView.isHidden = true
                        
                        staticContentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                        staticContentStackView.addArrangedSubview(RecipesListLoadingView())
                        
                    case let .error(viewModel):
                        staticContentStackView.isHidden = false
                        collectionView.isHidden = true
                        refreshControl.endRefreshing()
                        
                        staticContentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                        staticContentStackView.addArrangedSubview(
                            RecipesListInfoView(viewModel: viewModel)
                        )
                        
                    case let .empty(viewModel):
                        staticContentStackView.isHidden = false
                        collectionView.isHidden = true
                        refreshControl.endRefreshing()
                        
                        staticContentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                        staticContentStackView.addArrangedSubview(
                            RecipesListInfoView(viewModel: viewModel)
                        )
                        
                    case let .content(content, animated):
                        staticContentStackView.isHidden = true
                        collectionView.isHidden = false
                        refreshControl.endRefreshing()
                        
                        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                            guard let self else { return }
                            
                            var cuisineTabsSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
                            cuisineTabsSnapshot.append(
                                content.cuisineTabViewModels.map(AnyHashable.init)
                            )
                            dataSource?.apply(
                                cuisineTabsSnapshot,
                                to: .cuisineTabs,
                                animatingDifferences: true
                            )
                            
                            var recipesSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
                            recipesSnapshot.append(
                                content.recipesViewModels.map(AnyHashable.init)
                            )
                            dataSource?.apply(
                                recipesSnapshot,
                                to: .recipes,
                                animatingDifferences: animated
                            )
                            
                            DispatchQueue.main.async { [weak self] in
                                self?.collectionView.scrollToItem(
                                    at: IndexPath(
                                        item: content.cuisineTabViewModels.firstIndex(where: { $0.isSelected}) ?? 0,
                                        section: 0
                                    ),
                                    at: .left,
                                    animated: true
                                )
                            }
                        }
                }
            })
            .store(in: &cancellables)
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { section, _ -> NSCollectionLayoutSection? in
            if section == 0 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(30),
                    heightDimension: .estimated(30)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(30),
                    heightDimension: .estimated(30)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = .init(top: 8, leading: 18, bottom: 0, trailing: 18)
                section.interGroupSpacing = 8
                
                return section
            } else {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .estimated(150)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(150)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item, item]
                )
                group.interItemSpacing = .fixed(10)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = .init(top: 20, leading: 18, bottom: 0, trailing: 18)
                
                return section
            }
        }
    }
    
    @objc func onPullToRefresh() {
        viewModel.onPullToRefresh()
    }
}

// MARK: - UICollectionViewDelegate conformance
extension RecipesListViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.onItemSelection(indexPath: indexPath)
    }
}

// MARK: - Preview
@available(iOS 17, *)
#Preview {
    RecipesListViewController(viewModel: RecipesListViewModelMock())
}

private struct RecipesListViewModelMock: RecipesListViewModelType {
    var state: any Publisher<RecipesListState, Never> {
        Just(
            .content(
                RecipesListContent(
                    cuisineTabViewModels: [
                        RecipesListCuisineTabCellViewModel(title: "All", isSelected: true),
                        RecipesListCuisineTabCellViewModel(title: "American", isSelected: false),
                        RecipesListCuisineTabCellViewModel(title: "British", isSelected: false),
                        RecipesListCuisineTabCellViewModel(title: "Canadian", isSelected: false),
                        RecipesListCuisineTabCellViewModel(title: "Italian", isSelected: false),
                        RecipesListCuisineTabCellViewModel(title: "Tunisian", isSelected: false),
                        RecipesListCuisineTabCellViewModel(title: "French", isSelected: false),
                        RecipesListCuisineTabCellViewModel(title: "Greek", isSelected: false)
                    ],
                    recipesViewModels: [
                        RecipesListRecipeCellViewModel(
                            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg")!,
                            name: "Apple & Blackberry Crumble",
                            cuisine: "British",
                            urlOpenerService: URLOpenerService()
                        ),
                        RecipesListRecipeCellViewModel(
                            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg")!,
                            name: "Apam Balik",
                            cuisine: "Malaysian",
                            urlOpenerService: URLOpenerService()
                        ),
                        RecipesListRecipeCellViewModel(
                            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/7276e9f9-02a2-47a0-8d70-d91bdb149e9e/large.jp")!,
                            name: "Apple Frangipan Tart",
                            cuisine: "British",
                            urlOpenerService: URLOpenerService()
                        ),
                        RecipesListRecipeCellViewModel(
                            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b6efe075-6982-4579-b8cf-013d2d1a461b/large.jpg")!,
                            name: "Banana Pancakes",
                            cuisine: "American",
                            urlOpenerService: URLOpenerService()
                        ),
                        RecipesListRecipeCellViewModel(
                            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/ec1b84b1-2729-4547-99db-5e0b625c0356/large.jpg")!,
                            name: "Battenberg Cake",
                            cuisine: "British",
                            urlOpenerService: URLOpenerService()
                        ),
                        RecipesListRecipeCellViewModel(
                            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/ec155176-ebb3-4e83-a320-c5c1d8d0c559/large.jpg")!,
                            name: "Chinon Apple Tarts",
                            cuisine: "French",
                            urlOpenerService: URLOpenerService()
                        ),
                        RecipesListRecipeCellViewModel(
                            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg")!,
                            name: "BeaverTails",
                            cuisine: "Canadian",
                            urlOpenerService: URLOpenerService()
                        ),
                        RecipesListRecipeCellViewModel(
                            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg")!,
                            name: "Blackberry Fool",
                            cuisine: "British",
                            urlOpenerService: URLOpenerService()
                        ),
                        RecipesListRecipeCellViewModel(
                            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg")!,
                            name: "Canadian Butter Tarts",
                            cuisine: "Canadian",
                            urlOpenerService: URLOpenerService()
                        ),
                        RecipesListRecipeCellViewModel(
                            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg")!,
                            name: "Cashew Ghoriba Biscuits",
                            cuisine: "Tunisian",
                            urlOpenerService: URLOpenerService()
                        )
                    ]
                ),
                animated: false
            )
        )
    }
    
    func onWillAppear() {
    }
    
    func onPullToRefresh() {
    }
    
    func onItemSelection(indexPath: IndexPath) {
    }
}
