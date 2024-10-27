//
//  RecipesListLoadingView.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/26/24.
//

import UIKit
import SnapKit

final class RecipesListLoadingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViewComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private methods
private extension RecipesListLoadingView {
    func configureViewComponents() {
        let scrollView = UIScrollView()
        let tabsSkeletonContainer = makeTabsSkeletonContainer()
        let recipesSkeletonContainer = makeRecipesSkeletonContainer()
        
        addSubview(scrollView)
        scrollView.addSubview(tabsSkeletonContainer)
        scrollView.addSubview(recipesSkeletonContainer)
        
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        tabsSkeletonContainer.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(18)
        }
        
        recipesSkeletonContainer.snp.makeConstraints {
            $0.top.equalTo(tabsSkeletonContainer.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.width.equalToSuperview().offset(-40)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    func makeTabsSkeletonContainer() -> UIView {
        let tabsStackView = UIStackView()
        tabsStackView.spacing = 8
        
        for _ in 0...3 {
            tabsStackView.addArrangedSubview(makeCuisineTabSkeletonView())
        }
        
        return tabsStackView
    }
    
    func makeRecipesSkeletonContainer() -> UIView {
        let recipesStackView = UIStackView()
        recipesStackView.axis = .vertical
        recipesStackView.spacing = 10
        
        for _ in 0...3 {
            let leftRecipeView = makeRecipeCellSkeletonView()
            let rightRecipeView = makeRecipeCellSkeletonView()
            
            recipesStackView.addArrangedSubview(
                embeddedIntoStackView(firstView: leftRecipeView, secondView: rightRecipeView)
            )
        }
        
        return recipesStackView
    }
    
    func makeCuisineTabSkeletonView() -> UIView {
        let skeletonView = SkeletonView()
        skeletonView.backgroundColor = Colors.lightGray
        skeletonView.cornerRadius = 12
        skeletonView.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.height.equalTo(30)
        }
        return skeletonView
    }
    
    func makeRecipeCellSkeletonView() -> UIView {
        let cellView = UIView()
        let imageSkeletonView = SkeletonView()
        let titleSkeletonView = SkeletonView()
        let subtitleSkeletonView = SkeletonView()
        
        cellView.backgroundColor = Colors.lightGray
        cellView.layer.cornerRadius = 16
        cellView.layer.cornerCurve = .continuous
        
        [imageSkeletonView, titleSkeletonView, subtitleSkeletonView]
            .forEach { $0.backgroundColor = Colors.lightGray }
        
        imageSkeletonView.cornerRadius = 16
        
        cellView.addSubview(imageSkeletonView)
        cellView.addSubview(titleSkeletonView)
        cellView.addSubview(subtitleSkeletonView)
        
        imageSkeletonView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(0)
            $0.top.equalToSuperview().offset(0)
            $0.width.equalTo(imageSkeletonView.snp.height)
        }
        
        titleSkeletonView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(10)
            $0.top.equalTo(imageSkeletonView.snp.bottom).offset(8)
            $0.height.equalTo(20)
        }
        
        subtitleSkeletonView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().multipliedBy(0.6)
            $0.top.equalTo(titleSkeletonView.snp.bottom).offset(16)
            $0.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(14)
        }
        
        return cellView
    }
    
    func embeddedIntoStackView(firstView: UIView, secondView: UIView) -> UIView {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        stackView.addArrangedSubview(firstView)
        stackView.addArrangedSubview(secondView)
        
        return stackView
    }
}

// MARK: - Preview
@available(iOS 17, *)
#Preview {
    RecipesListLoadingView()
}
