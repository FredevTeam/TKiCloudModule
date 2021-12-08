//
//  AddViewController.swift
//  TKiCloudModule-iOS
//
//  Created by 🐶 on 2021/12/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import TKiCloudModule


class AddViewController: UIViewController {
    
    private let textView = UITextView.init()
    private let nameTextField = UITextField.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installSubviews()
        view.backgroundColor = UIColor.white
    }
    
}


extension AddViewController {
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(saveButtonAction))
     
        
        view.addSubview(nameTextField)
        nameTextField.placeholder = "name or path"
        nameTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(textView.snp.bottom).offset(20)
            make.height.equalTo(50)
        }
        
        nameTextField.layer.borderColor = UIColor.green.cgColor
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.cornerRadius = 5
        
    }
}


extension AddViewController {
    @objc private func saveButtonAction () {
        
        let name = self.nameTextField.text ?? ""
        let value = self.textView.text ?? ""
        
        if name.isEmpty || value.isEmpty {
            debugPrint("name is empty or value is empty")
            return
        }
        
        iCloud.default.save(SingleDocument.self, name, content: value) { document, content, error in
            if let error = error {
                debugPrint("save failed: \(error)")
                return
            }
            debugPrint("save success . name:\(name) ===content:\(content)")
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
        
    }
}
