//
//  KeyValueViewController.swift
//  TKiCloudModule_Example
//
//  Created by 🐶 on 2021/12/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Cocoa
import PLExtensionsModule
import TKiCloudModule

class KeyValueViewController: NSViewController {

    @IBOutlet weak var keyLabel: NSTextField!
    @IBOutlet weak var valueLabel: NSTextField!
    @IBOutlet weak var keyTextField: NSTextField!
    @IBOutlet weak var valueTextField: NSTextField!
    
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    
    
    private let tableView = CocoaTableView.init()
    private var dataSources: [String] {
        return Array(iCloudStore.instance.dictionaryRepresentation.keys).sorted()
    }
}

extension KeyValueViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        installSubviews()
        iCloudStore.instance.delegate = self
    }
    
    private func installSubviews() {
        keyLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
            make.width.equalTo(100)
        }
        keyTextField.placeholderString = "key string"
        keyTextField.snp.makeConstraints { make in
            make.leading.equalTo(keyLabel.snp.trailing).offset(20)
            make.centerY.equalTo(keyLabel)
            make.trailing.equalTo(saveButton.snp.leading).offset(-50)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(keyLabel.snp.bottom).offset(20)
            make.width.equalTo(100)
        }
        valueTextField.placeholderString = "value string"
        valueTextField.snp.makeConstraints { make in
            make.leading.equalTo(valueLabel.snp.trailing).offset(20)
            make.centerY.equalTo(valueLabel)
            make.trailing.equalTo(saveButton.snp.leading).offset(-50)
        }
        
        saveButton.target = self
        saveButton.action = #selector(save)
        saveButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.centerY.equalTo(keyTextField)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        removeButton.target = self
        removeButton.action = #selector(remove)
        removeButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.centerY.equalTo(valueTextField)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        tableView.backgroundColor = NSColor.white
        tableView.focusRingType = .none
        tableView.autoresizesSubviews = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil
        tableView.rowSizeStyle = .large
        tableView.allowsEmptySelection = false
        tableView.hasHorizontalScroller = false
        tableView.autohidesScrollers = true
        
        // TODO: 解决cell 前面多出来的间距问题
        tableView.intercellSpacing = CGSize.init(width: 0, height: 0)
        tableView.rowSizeStyle = .custom
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(200)
            make.top.equalTo(valueLabel.snp.bottom).offset(40)
        }
    }
}

extension KeyValueViewController : NSTableViewDataSource {
    struct UserInterfaceItemIdentifier {
        static var cell = NSUserInterfaceItemIdentifier.init("EffectiveResourceViewController_cell")
        static var header = NSUserInterfaceItemIdentifier.init("EffectiveResourceViewController_HeaderView")
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSources.count
    }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cell = tableView.makeView(withIdentifier: UserInterfaceItemIdentifier.cell, owner: self) as? TableViewCell
        if  cell == nil {
            cell = TableViewCell.init()
            cell?.identifier = UserInterfaceItemIdentifier.cell
        }
        guard row < dataSources.count else {
            return cell
        }
        let item = dataSources[row]
        cell?.titleLabel.stringValue = item
        return cell
        
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = NSTableRowView.init()
        return rowView
    }
}


extension KeyValueViewController: CocoaTableViewDelegate {
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    func tableView(_ tableView: CocoaTableView, didSelectAt selectRow: Int, selectColumn: Int) {
        let key = dataSources[selectRow]
        keyTextField.stringValue = key
        if let value: String? = iCloudStore.instance.value(key) {
            valueTextField.stringValue = value ?? ""
        }
    }
    
}



extension KeyValueViewController:iCloudStoreDelegate {
    func cloudStore(_ cloudStore: iCloudStore, keyValueChange reson: iCloudStore.KeyValueStoreChangeReason?, change keys: [String]?) {
        debugPrint("==================ios:\(reson.debugDescription) ======\(keys ?? [])")
        self.tableView.reloadData()
    }
    
}

extension KeyValueViewController {
    
    @objc private func remove() {
        let key = keyTextField.stringValue
        if key.isEmpty {
            return
        }
        
        _ = iCloudStore.instance.remove(key)
        self.tableView.reloadData()
    }
    
    
    @objc  private func save() {
        let key = keyTextField.stringValue
        let value = valueTextField.stringValue
        
        if key.isEmpty || value.isEmpty {
            return
        }
        
        iCloudStore.instance.set(value, key: key)
        self.tableView.reloadData()
    }
}

