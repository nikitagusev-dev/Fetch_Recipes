//
//  RecipesListTests.swift
//  RecipesTests
//
//  Created by Nikita Gusev on 10/24/24.
//

import XCTest
@testable import Recipes
import Combine

final class RecipesListTests: XCTestCase {
    private var recipesRepository: RecipesRepositoryMock!
    private var urlOpenerService: URLOpenerServiceMock!
    private var cancellables: [AnyCancellable] = []
    
    override func setUp() {
        recipesRepository = RecipesRepositoryMock()
        urlOpenerService = URLOpenerServiceMock()
        cancellables = []
    }
    
    func test_onAppear_shouldUpdateRecipes() {
        // Given
        let viewModel = makeRecipesListViewModel()
        recipesRepository.recipesResult = .success([])
        
        let expectation = XCTestExpectation(description: "didUpdate")
        
        recipesRepository.onGetRecipesRequest = {
            expectation.fulfill()
        }
        
        // When
        viewModel.onWillAppear()
        
        // Then
        wait(for: [expectation], timeout: 0.5)
    }
    
    func test_onPullToRefresh_shouldUpdateRecipes() {
        // Given
        let viewModel = makeRecipesListViewModel()
        recipesRepository.recipesResult = .success([])
        
        let expectation = XCTestExpectation(description: "didUpdate")
        
        recipesRepository.onGetRecipesRequest = {
            expectation.fulfill()
        }
        
        // When
        viewModel.onWillAppear()
        
        // Then
        wait(for: [expectation], timeout: 0.5)
    }
    
    func test_screenState_afterInitialization_shouldNotEmitAnything() {
        // Given + When
        let viewModel = makeRecipesListViewModel()
        
        let expectation = XCTestExpectation(description: "state")
        expectation.isInverted = true
        
        viewModel.state
            .sink(receiveValue: { _ in
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 0.5)
    }
    
    func test_screenState_onAppearAfterCorrectRecipesLoaded_shouldBeLoadingWithoutContentAndThenContent() {
        // Given
        let viewModel = makeRecipesListViewModel()
        recipesRepository.recipesResult = .success(makeRecipes())
        
        var recipesStates: [RecipesListState] = []
        let expectation = XCTestExpectation(description: "state")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.state
            .sink(receiveValue: { state in
                recipesStates.append(state)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        // When
        viewModel.onWillAppear()
        wait(for: [expectation], timeout: 0.5)
        
        // Then
        XCTAssertTrue(recipesStates.count == 2)
        XCTAssertTrue(recipesStates[0].isLoading)
        XCTAssertTrue(recipesStates[1].isContent)
    }
    
    func test_screenState_onAppearAfterEmptyRecipesLoaded_shouldBeLoadingWithoutContentAndThenEmpty() {
        // Given
        let viewModel = makeRecipesListViewModel()
        recipesRepository.recipesResult = .success([])
        
        var recipesStates: [RecipesListState] = []
        let expectation = XCTestExpectation(description: "state")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.state
            .sink(receiveValue: { state in
                recipesStates.append(state)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        // When
        viewModel.onWillAppear()
        wait(for: [expectation], timeout: 0.5)
        
        // Then
        XCTAssertTrue(recipesStates.count == 2)
        XCTAssertTrue(recipesStates[0].isLoading)
        XCTAssertTrue(recipesStates[1].isEmpty)
    }
    
    func test_screenState_onAppearAfterRecipesLoadingError_shouldBeLoadingWithoutContentAndThenError() {
        // Given
        let viewModel = makeRecipesListViewModel()
        recipesRepository.recipesResult = .failure(TestError.test)
        
        var recipesStates: [RecipesListState] = []
        let expectation = XCTestExpectation(description: "state")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.state
            .sink(receiveValue: { state in
                recipesStates.append(state)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        // When
        viewModel.onWillAppear()
        wait(for: [expectation], timeout: 0.5)
        
        // Then
        XCTAssertTrue(recipesStates.count == 2)
        XCTAssertTrue(recipesStates[0].isLoading)
        XCTAssertTrue(recipesStates[1].isError)
    }
    
    func test_screenState_withAlreadyLoadedCorrectContentOnPullToRefresh_shouldBeContent() {
        // Given
        let viewModel = makeRecipesListViewModel()
        recipesRepository.recipesResult = .success(makeRecipes())
        
        var recipesStates: [RecipesListState] = []
        
        let contentStateExpectation = XCTestExpectation(description: "contentStateExpectation")
        
        viewModel.state
            .drop(while: { !$0.isContent })
            .sink(receiveValue: { state in
                contentStateExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        let testedStateExpectation = XCTestExpectation(description: "state")
        testedStateExpectation.expectedFulfillmentCount = 1
        
        viewModel.state
            .drop(while: { !$0.isContent })
            .dropFirst()
            .sink(receiveValue: { state in
                recipesStates.append(state)
                testedStateExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.onWillAppear()
        
        wait(for: [contentStateExpectation], timeout: 0.5)
        
        // When
        viewModel.onPullToRefresh()
        wait(for: [testedStateExpectation], timeout: 0.5)
        
        // Then
        XCTAssertTrue(recipesStates.count == 1)
        XCTAssertTrue(recipesStates[0].isContent)
    }
    
    func test_screenState_withAlreadyLoadedEmptyContentOnPullToRefresh_shouldStartWithLoadingWithoutContent() {
        // Given
        let viewModel = makeRecipesListViewModel()
        recipesRepository.recipesResult = .success([])
        
        var recipesStates: [RecipesListState] = []
        
        let emptyStateExpectation = XCTestExpectation(description: "emptyStateExpectation")
        
        viewModel.state
            .drop(while: { !$0.isEmpty })
            .sink(receiveValue: { state in
                emptyStateExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        let testedStateExpectation = XCTestExpectation(description: "state")
        testedStateExpectation.expectedFulfillmentCount = 2
        
        viewModel.state
            .drop(while: { !$0.isEmpty })
            .dropFirst()
            .sink(receiveValue: { state in
                recipesStates.append(state)
                testedStateExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.onWillAppear()
        
        wait(for: [emptyStateExpectation], timeout: 0.5)
        
        // When
        viewModel.onPullToRefresh()
        wait(for: [testedStateExpectation], timeout: 0.5)
        
        // Then
        XCTAssertTrue(recipesStates.count == 2)
        XCTAssertTrue(recipesStates[0].isLoading)
        XCTAssertFalse(recipesStates[1].isLoading)
    }
    
    func test_screenState_withAlreadyLoadedErrorOnPullToRefresh_shouldStartWithLoadingWithoutContent() {
        // Given
        let viewModel = makeRecipesListViewModel()
        recipesRepository.recipesResult = .failure(TestError.test)
        
        var recipesStates: [RecipesListState] = []
        
        let errorStateExpectation = XCTestExpectation(description: "errorStateExpectation")
        
        viewModel.state
            .drop(while: { !$0.isError })
            .sink(receiveValue: { state in
                errorStateExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        let testedStateExpectation = XCTestExpectation(description: "state")
        testedStateExpectation.expectedFulfillmentCount = 2
        
        viewModel.state
            .drop(while: { !$0.isError })
            .dropFirst()
            .sink(receiveValue: { state in
                recipesStates.append(state)
                testedStateExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.onWillAppear()
        
        wait(for: [errorStateExpectation], timeout: 0.5)
        
        // When
        viewModel.onPullToRefresh()
        wait(for: [testedStateExpectation], timeout: 0.5)
        
        // Then
        XCTAssertTrue(recipesStates.count == 2)
        XCTAssertTrue(recipesStates[0].isLoading)
        XCTAssertFalse(recipesStates[1].isLoading)
    }
    
    func test_cuisineTabsInContent_shouldCorrespondToLoadedResponse() {
        // Given
        let viewModel = makeRecipesListViewModel()
        let recipes = makeRecipes()
        recipesRepository.recipesResult = .success(recipes)
        
        let expectedCuisines = ["All"] + Array(Set(recipes.map(\.cuisine))).sorted()
        
        var recipesState: RecipesListState!
        let expectation = XCTestExpectation(description: "state")
        
        viewModel.state
            .drop(while: { !$0.isContent })
            .sink(receiveValue: { state in
                recipesState = state
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        // When
        viewModel.onWillAppear()
        wait(for: [expectation], timeout: 0.5)
        
        // Then
        guard case let .content(content, _) = recipesState else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(content.cuisineTabViewModels.count, expectedCuisines.count)
        XCTAssertEqual(content.cuisineTabViewModels.map(\.title), expectedCuisines)
    }
    
    func test_recipesInContent_shouldCorrespondToLoadedResponse() {
        // Given
        let viewModel = makeRecipesListViewModel()
        let recipes = makeRecipes()
        recipesRepository.recipesResult = .success(recipes)
        
        let expectedRecipeNames = recipes.map(\.name)
        
        var recipesState: RecipesListState!
        let expectation = XCTestExpectation(description: "state")
        
        viewModel.state
            .drop(while: { !$0.isContent })
            .sink(receiveValue: { state in
                recipesState = state
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        // When
        viewModel.onWillAppear()
        wait(for: [expectation], timeout: 0.5)
        
        // Then
        guard case let .content(content, _) = recipesState else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(content.recipesViewModels.count, expectedRecipeNames.count)
        XCTAssertEqual(content.recipesViewModels.map(\.name), expectedRecipeNames)
    }
    
    func test_cuisineTabsInContent_onCuisineTabSelection_shouldHaveOneCorrectSelectedCuisine() {
        // Given
        let viewModel = makeRecipesListViewModel()
        let recipes = makeRecipes()
        recipesRepository.recipesResult = .success(recipes)
        
        let selectedCuisineIndex = 1
        let expectedCuisines = ["All"] + Array(Set(recipes.map(\.cuisine))).sorted()
        
        var recipesState: RecipesListState!
        
        let contentStateExpectation = XCTestExpectation(description: "contentStateExpectation")
        
        viewModel.state
            .drop(while: { !$0.isContent })
            .sink(receiveValue: { state in
                contentStateExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        let expectedStateExpectation = XCTestExpectation(description: "expectedStateExpectation")
        
        viewModel.state
            .drop(while: { !$0.isContent })
            .dropFirst()
            .sink(receiveValue: { state in
                recipesState = state
                expectedStateExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.onWillAppear()
        wait(for: [contentStateExpectation], timeout: 0.5)
        
        // When
        viewModel.onItemSelection(indexPath: IndexPath(item: selectedCuisineIndex, section: 0))
        wait(for: [expectedStateExpectation], timeout: 0.5)
        
        // Then
        guard case let .content(content, _) = recipesState else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(content.cuisineTabViewModels.filter { $0.isSelected }.count == 1)
        XCTAssertTrue(content.cuisineTabViewModels[selectedCuisineIndex].isSelected)
        XCTAssertEqual(content.cuisineTabViewModels[selectedCuisineIndex].title, expectedCuisines[1])
    }
    
    func test_recipesInContent_onCuisineTabSelection_shouldHaveOnlySuitableRecipes() {
        // Given
        let viewModel = makeRecipesListViewModel()
        let recipes = makeRecipes()
        recipesRepository.recipesResult = .success(recipes)
        
        let selectedCuisineIndex = 1
        let expectedCuisines = ["All"] + Array(Set(recipes.map(\.cuisine))).sorted()
        let expectedRecipes = recipes.filter { $0.cuisine == expectedCuisines[selectedCuisineIndex] }
        
        var recipesState: RecipesListState!
        
        let contentStateExpectation = XCTestExpectation(description: "contentStateExpectation")
        
        viewModel.state
            .drop(while: { !$0.isContent })
            .sink(receiveValue: { state in
                contentStateExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        let expectedStateExpectation = XCTestExpectation(description: "expectedStateExpectation")
        
        viewModel.state
            .drop(while: { !$0.isContent })
            .dropFirst()
            .sink(receiveValue: { state in
                recipesState = state
                expectedStateExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.onWillAppear()
        wait(for: [contentStateExpectation], timeout: 0.5)
        
        // When
        viewModel.onItemSelection(indexPath: IndexPath(item: selectedCuisineIndex, section: 0))
        wait(for: [expectedStateExpectation], timeout: 0.5)
        
        // Then
        guard case let .content(content, _) = recipesState else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(content.recipesViewModels.count, expectedRecipes.count)
        XCTAssertEqual(content.recipesViewModels.map(\.name), expectedRecipes.map(\.name))
    }
    
    func test_externalResourceButton_withBothSourceAndYoutubeURLProvided_shouldBeVisible() {
        // Given
        let recipeViewModel = RecipesListRecipeCellViewModel(
            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg"),
            name: "Apam Balik",
            cuisine: "Malaysian",
            sourceURL: URL(string: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ"),
            youtubeURL: URL(string: "https://www.youtube.com/watch?v=6R8ffRRJcrg"),
            urlOpenerService: urlOpenerService
        )
        
        // Then
        XCTAssertTrue(recipeViewModel.externalResourceButtonIsVisible)
    }
    
    func test_externalResourceButton_withOnlySourceURLProvided_shouldBeVisible() {
        // Given
        let recipeViewModel = RecipesListRecipeCellViewModel(
            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg"),
            name: "Apam Balik",
            cuisine: "Malaysian",
            sourceURL: URL(string: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ"),
            urlOpenerService: urlOpenerService
        )
        
        // Then
        XCTAssertTrue(recipeViewModel.externalResourceButtonIsVisible)
    }
    
    func test_externalResourceButton_withOnlyYoutubeURLProvided_shouldBeVisible() {
        // Given
        let recipeViewModel = RecipesListRecipeCellViewModel(
            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg"),
            name: "Apam Balik",
            cuisine: "Malaysian",
            youtubeURL: URL(string: "https://www.youtube.com/watch?v=6R8ffRRJcrg"),
            urlOpenerService: urlOpenerService
        )
        
        // Then
        XCTAssertTrue(recipeViewModel.externalResourceButtonIsVisible)
    }
    
    func test_externalResourceButton_withNoURLsProvided_shouldBeHidden() {
        // Given
        let recipeViewModel = RecipesListRecipeCellViewModel(
            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg"),
            name: "Apam Balik",
            cuisine: "Malaysian",
            urlOpenerService: urlOpenerService
        )
        
        // Then
        XCTAssertFalse(recipeViewModel.externalResourceButtonIsVisible)
    }
    
    func test_byTapOnVisibleExternalResourceButton_urlShouldBeOpened() {
        // Given
        let recipeViewModel = RecipesListRecipeCellViewModel(
            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg"),
            name: "Apam Balik",
            cuisine: "Malaysian",
            sourceURL: URL(string: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ"),
            youtubeURL: URL(string: "https://www.youtube.com/watch?v=6R8ffRRJcrg"),
            urlOpenerService: urlOpenerService
        )
        
        // When
        recipeViewModel.onExternalResourceButtonTap()
        
        // Then
        XCTAssertNotNil(urlOpenerService.openedURL)
    }
    
    func test_externalResourceURL_withBothSourceAndYoutubeURLProvided_shouldBeSourceURL() {
        // Given
        let recipeViewModel = RecipesListRecipeCellViewModel(
            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg"),
            name: "Apam Balik",
            cuisine: "Malaysian",
            sourceURL: URL(string: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ"),
            youtubeURL: URL(string: "https://www.youtube.com/watch?v=6R8ffRRJcrg"),
            urlOpenerService: urlOpenerService
        )
        
        // When
        recipeViewModel.onExternalResourceButtonTap()
        
        // Then
        XCTAssertEqual(urlOpenerService.openedURL, URL(string: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ"))
    }
    
    func test_externalResourceURL_withOnlySourceURLProvided_shouldBeSourceURL() {
        // Given
        let recipeViewModel = RecipesListRecipeCellViewModel(
            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg"),
            name: "Apam Balik",
            cuisine: "Malaysian",
            sourceURL: URL(string: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ"),
            urlOpenerService: urlOpenerService
        )
        
        // When
        recipeViewModel.onExternalResourceButtonTap()
        
        // Then
        XCTAssertEqual(urlOpenerService.openedURL, URL(string: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ"))
    }
    
    func test_externalResourceURL_withOnlyYoutubeURLProvided_shouldBeSourceURL() {
        // Given
        let recipeViewModel = RecipesListRecipeCellViewModel(
            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg"),
            name: "Apam Balik",
            cuisine: "Malaysian",
            youtubeURL: URL(string: "https://www.youtube.com/watch?v=6R8ffRRJcrg"),
            urlOpenerService: urlOpenerService
        )
        
        // When
        recipeViewModel.onExternalResourceButtonTap()
        
        // Then
        XCTAssertEqual(urlOpenerService.openedURL, URL(string: "https://www.youtube.com/watch?v=6R8ffRRJcrg"))
    }
    
    // Modify this test when new localizations are added
    func test_emptyViewWordings_shouldBeCorrect() {
        // Given + When
        let viewModel = RecipesListEmptyInfoViewModel(onButtonTap: { })
        
        // Then
        XCTAssertEqual(viewModel.description, "Looks like there are no recipes here")
        XCTAssertEqual(viewModel.buttonTitle, "Refresh")
    }
    
    // Modify this test when new localizations are added
    func test_errorViewWordings_shouldBeCorrect() {
        // Given + When
        let viewModel = RecipesListErrorInfoViewModel(onButtonTap: { })
        
        // Then
        XCTAssertEqual(viewModel.description, "Oops! An error occurred while loading recipes")
        XCTAssertEqual(viewModel.buttonTitle, "Try again")
    }
}

// MARK: - Private methods
private extension RecipesListTests {
    func makeRecipesListViewModel() -> RecipesListViewModel {
        RecipesListViewModel(
            recipesRepository: recipesRepository,
            urlOpenerService: urlOpenerService
        )
    }
    
    func makeRecipes() -> [RecipeDTO] {
        [
            RecipeDTO(
                id: "1",
                cuisine: "Malaysian",
                name: "Apam Balik",
                largePhotoURL: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
                smallPhotoURL: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                sourceURL: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                youtubeURL: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
            ),
            RecipeDTO(
                id: "2",
                cuisine: "British",
                name: "Apple & Blackberry Crumble",
                largePhotoURL: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
                smallPhotoURL: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                sourceURL: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                youtubeURL: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
            ),
            RecipeDTO(
                id: "3",
                cuisine: "American",
                name: "Banana Pancakes",
                largePhotoURL: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
                smallPhotoURL: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                sourceURL: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                youtubeURL: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
            )
        ]
    }
}

// MARK: - Helpers
private extension RecipesListState {
    var isLoading: Bool {
        if case .loadingWithoutContent = self {
            return true
        }
        return false
    }
    
    var isEmpty: Bool {
        if case .empty = self {
            return true
        }
        return false
    }
    
    var isError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
}

private enum TestError: Error {
    case test
}
