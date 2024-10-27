//
//  RecipesListRecipeCellView.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/25/24.
//

import UIKit
import SnapKit
import Kingfisher

final class RecipesListRecipeCellView: UICollectionViewCell {
    private let imageView = UIImageView()
    private let nameTextView = UITextView()
    private let cuisineLabel = UILabel()
    private let externalResourceButton = UIButton()
    
    private var viewModel: RecipesListRecipeCellViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViewComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(using viewModel: RecipesListRecipeCellViewModel) {
        self.viewModel = viewModel
        
        imageView.kf.setImage(with: viewModel.imageURL, placeholder: UIImage.recipePlaceholder)
        nameTextView.text = viewModel.name
        cuisineLabel.text = viewModel.cuisine
        externalResourceButton.isHidden = !viewModel.externalResourceButtonIsVisible
    }
}

// MARK: - Private methods
private extension RecipesListRecipeCellView {
    func configureViewComponents() {
        configureLayout()
        
        backgroundView = UIView()
        backgroundView?.layer.cornerRadius = 16
        backgroundView?.layer.cornerCurve = .continuous
        backgroundView?.backgroundColor = Colors.lightGray
        
        clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.layer.cornerCurve = .continuous
        imageView.clipsToBounds = true
        
        nameTextView.font = .systemFont(ofSize: 14, weight: .semibold)
        nameTextView.textColor = Colors.dark
        nameTextView.isScrollEnabled = false
        nameTextView.isEditable = false
        nameTextView.isSelectable = false
        nameTextView.isUserInteractionEnabled = false
        nameTextView.textContainer.lineFragmentPadding = .zero
        nameTextView.textContainerInset = .zero
        nameTextView.backgroundColor = .clear
        nameTextView.textContainer.lineBreakMode = .byTruncatingTail
        nameTextView.textContainer.maximumNumberOfLines = 2
        
        cuisineLabel.font = .systemFont(ofSize: 12, weight: .medium)
        cuisineLabel.textColor = UIColor(red: 170 / 255, green: 170 / 255, blue: 170 / 255, alpha: 1)
        cuisineLabel.numberOfLines = 1
        
        externalResourceButton.backgroundColor = .white
        externalResourceButton.layer.cornerRadius = 10
        externalResourceButton.imageView?.contentMode = .scaleAspectFit
        externalResourceButton.layer.shadowOffset = .zero
        externalResourceButton.layer.shadowRadius = 4
        externalResourceButton.layer.shadowColor = UIColor.black.cgColor
        externalResourceButton.layer.shadowOpacity = 0.06
        externalResourceButton.imageEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
        externalResourceButton.setImage(
            .externalLink.withTintColor(Colors.dark),
            for: .normal
        )
        externalResourceButton.addTarget(
            self,
            action: #selector(externalResourceButtonTapped),
            for: .touchUpInside
        )
    }
    
    func configureLayout() {
        addSubview(imageView)
        addSubview(nameTextView)
        addSubview(cuisineLabel)
        addSubview(externalResourceButton)
        
        imageView.snp.makeConstraints {
            $0.horizontalEdges.top.equalToSuperview()
            $0.width.equalTo(imageView.snp.height)
        }
        
        nameTextView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(10)
            $0.top.equalTo(imageView.snp.bottom).offset(8)
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ]
            let twoLineHeight = "\n".size(withAttributes: attributes).height
            
            $0.height.equalTo(twoLineHeight + 1)
        }
        
        cuisineLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.lessThanOrEqualTo(externalResourceButton.snp.leading).offset(-4)
            $0.top.equalTo(nameTextView.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        externalResourceButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(10)
            $0.width.equalTo(38)
            $0.height.equalTo(28)
        }
    }
    
    @objc func externalResourceButtonTapped() {
        viewModel?.onExternalResourceButtonTap()
    }
}

// MARK: - Preview
@available(iOS 17, *)
#Preview {
    let view = RecipesListRecipeCellView()
    view.configure(
        using: RecipesListRecipeCellViewModel(
            imageURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/small.jpg")!,
            name: "Apple & Blackberry Crumble",
            cuisine: "British",
            urlOpenerService: URLOpenerService()
        )
    )
    return view
}
