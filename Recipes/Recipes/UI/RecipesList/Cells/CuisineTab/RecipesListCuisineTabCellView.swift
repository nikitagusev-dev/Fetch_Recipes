//
//  RecipesListCuisineTabCellView.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/25/24.
//

import UIKit
import SnapKit

final class RecipesListCuisineTabCellView: UICollectionViewCell {
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViewComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(using viewModel: RecipesListCuisineTabCellViewModel) {
        titleLabel.text = viewModel.title
        
        titleLabel.textColor = viewModel.isSelected
            ? .white
            : Colors.dark
        
        backgroundView?.backgroundColor = viewModel.isSelected
            ? Colors.dark
            : Colors.lightGray
    }
}

// MARK: - Private methods
private extension RecipesListCuisineTabCellView {
    func configureViewComponents() {
        configureLayout()
        
        backgroundView = UIView()
        backgroundView?.layer.cornerRadius = 12
        backgroundView?.layer.cornerCurve = .continuous
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
    }
    
    func configureLayout() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(14)
            $0.verticalEdges.equalToSuperview().inset(8)
        }
    }
}

// MARK: - Preview
@available(iOS 17, *)
#Preview {
    let view = RecipesListCuisineTabCellView()
    view.configure(using: RecipesListCuisineTabCellViewModel(title: "American", isSelected: false))
    return view
}
