//
//  KeyValueViewController.swift
//  TKiCloudModule-iOS
//
//  Created by 🐶 on 2021/12/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import TKiCloudModule

class KeyValueViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var keyTextField: UITextField!
    
    private var dataSources:[String] {
        return Array(iCloudStore.instance.dictionaryRepresentation.keys).sorted()
    }
}



extension KeyValueViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Key-Value Test"
        iCloudStore.instance.delegate = self
        installSubviews()
    }
    
    private func installSubviews() {
        keyTextField.placeholder = "key"
        valueTextField.placeholder = "value"
        
        saveButton.backgroundColor = UIColor.red
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        
        removeButton.backgroundColor = UIColor.green
        removeButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


extension KeyValueViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "Cell")
        }
        cell?.textLabel?.text = dataSources[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        keyTextField.text = dataSources[indexPath.row]
        if let value: String = iCloudStore.instance.value(dataSources[indexPath.row]) {
            valueTextField.text = value
        }
        
    }
}


extension KeyValueViewController {
    @objc private func save() {
        if let key = keyTextField.text, let value = valueTextField.text {
            iCloudStore.instance.set(value, key: key)
            self.tableView.reloadData()
            self.view.endEditing(true)
        }
    }
    
    @objc private func remove() {
        if let key = keyTextField.text {
            iCloudStore.instance.remove(key)
            self.tableView.reloadData()
        }
    }
}


extension KeyValueViewController: iCloudStoreDelegate {
    func cloudStore(_ cloudStore: iCloudStore, keyValueChange reson: iCloudStore.KeyValueStoreChangeReason?, change keys: [String]?) {
        debugPrint("==================ios:\(reson.debugDescription) ======\(keys ?? [])")
        self.tableView.reloadData()
    }
    
    
}
