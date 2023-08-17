//
//  View.swift
//  RXSwift
//

import UIKit

final class View: UIView {
    
    private lazy var containerView = UIView().withDefaultParams()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let outputView = UIActivityIndicatorView(style: .large).withDefaultParams()
        outputView.stopAnimating()
        return outputView
    }()
    
    private lazy var textFieldBackgound: UIView = {
        let outputView = UIView().withDefaultParams()
        outputView.layer.cornerRadius = 16
        outputView.backgroundColor = .white
        return outputView
    }()
    
    lazy var textField: UITextField = {
        let outputView = UITextField().withDefaultParams()
        outputView.autocorrectionType = .no
        outputView.autocapitalizationType = .none
        return outputView
    }()
    
    lazy var cancelButton: UIButton = {
        let outputView = UIButton().withDefaultParams()
        outputView.setImage(UIImage(systemName: "xmark"), for: .normal)
        outputView.tintColor = .systemGray
        return outputView
    }()

    lazy var resultTableView: UITableView = {
        let outputView = UITableView().withDefaultParams()
        outputView.backgroundColor = .white
        outputView.showsVerticalScrollIndicator = false
        outputView.separatorStyle = .singleLine
        outputView.allowsSelection = false
        outputView.layer.cornerRadius = 16
        outputView.register(Cell.self, forCellReuseIdentifier: "Cell")
        return outputView
    }()
    
    func setup() {
        backgroundColor = .systemGray6
        setupLayout()
    }

    private func setupLayout() {
        addSubview(containerView)
        
        [textFieldBackgound,
         resultTableView,
         activityIndicator].forEach { subView in
            containerView.addSubview(subView)
        }
        
        [textField,
         cancelButton].forEach { subView in
            textFieldBackgound.addSubview(subView)
        }
        
        containerView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(16)
            maker.top.equalTo(safeAreaLayoutGuide)
            maker.bottom.equalToSuperview()
        }
        
        
        textFieldBackgound.snp.makeConstraints { maker in
            maker.top.leading.trailing.equalToSuperview()
            maker.height.equalTo(50)
        }
        
        textField.snp.makeConstraints { maker in
            maker.leading.equalToSuperview().inset(12)
            maker.trailing.equalTo(cancelButton.snp.leading).offset(-12)
            maker.top.bottom.equalToSuperview().inset(4)
        }
        
        cancelButton.snp.makeConstraints { maker in
            maker.top.bottom.equalTo(textField)
            maker.trailing.equalToSuperview().inset(12)
            maker.width.equalTo(cancelButton.snp.height)
        }
        
        resultTableView.snp.makeConstraints { maker in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.top.equalTo(textFieldBackgound.snp.bottom).offset(20)
        }
        
        activityIndicator.snp.makeConstraints { maker in
            maker.centerX.centerY.equalToSuperview()
        }
    }
}
