//
//  RecipesListInfoView.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/26/24.
//

import UIKit
import SnapKit

final class RecipesListInfoView: UIView {
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let button = UIButton()
    
    private let viewModel: RecipesListInfoViewModelType
    
    init(viewModel: RecipesListInfoViewModelType) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        configureViewComponents()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private methods
private extension RecipesListInfoView {
    func configureViewComponents() {
        configureLayout()
        
        backgroundColor = .white
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = Colors.dark
        
        button.layer.cornerRadius = 20
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(.from(color: Colors.dark), for: .normal)
        button.setBackgroundImage(.from(color: .black), for: .highlighted)
        button.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)
    }
    
    func configureLayout() {
        let containerView = UIView()
        
        addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(button)
        
        containerView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(18)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
        }
        
        button.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
    
    func bindViewModel() {
        imageView.image = viewModel.image
        descriptionLabel.text = viewModel.description
        
        let attributedTitle = NSAttributedString(
            string: viewModel.buttonTitle,
            attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold)]
        )
        button.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    @objc func onButtonTap() {
        viewModel.onButtonTap()
    }
}

// MARK: - UIImage + from(color:)
private extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

// MARK: - Preview
@available(iOS 17, *)
#Preview {
    RecipesListInfoView(viewModel: RecipesListErrorInfoViewModel(onButtonTap: {}))
}
