//
//  ShowViewController.swift
//  TKiCloudModule-iOS
//
//  Created by 🐶 on 2021/12/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import TKiCloudModule


class ShowViewController: UIViewController {
    var item: NSMetadataItem? {
        didSet {
           setContent()
        }
    }
    
    private let textView = UITextView.init()
    private let nameTextField = UITextField.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installSubviews()
        view.backgroundColor = UIColor.white
    }
    
}


extension ShowViewController {
    
    private func installSubviews() {
        view.addSubview(self.textView)
        textView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.snp.topMargin)
            make.height.equalTo(250)
        }
        textView.layer.borderColor = UIColor.red.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.isEditable = false

        
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(textView.snp.bottom).offset(20)
            make.height.equalTo(50)
        }
        
        nameTextField.layer.borderColor = UIColor.green.cgColor
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.cornerRadius = 5
        nameTextField.isEnabled = false
        
    }
}


extension ShowViewController {
    private func setContent() {
        item?.attributes.forEach({ key in
            if let value = item?.value(forAttribute: key) {
                debugPrint("key:\(key) ===value:\(value)")
            }
        })
        
        
        if let name = item?.value(forAttribute: NSMetadataItemFSNameKey) as? String, let path = item?.value(forAttribute: NSMetadataItemPathKey) as? String {
            iCloud.default.open(SingleDocument.self, document: path, ifNotExitsWith: true) { document, error in
                self.textView.text = document?.content
            }
            self.nameTextField.text = name
        }
        
    }
}

