//
//  ViewController.swift
//  TKiCloudModule
//
//  Created by macer-sources on 11/29/2021.
//  Copyright (c) 2021 macer-sources. All rights reserved.
//

import Cocoa
import TKiCloudModule
import SnapKit
import PLExtensionsModule

class iCloudViewController: NSViewController {

    private let tableView = CocoaTableView.init()
    private let textView = CocoaTextView.init()
    private let textField = NSTextField.init()
    private let button = NSButton.init()
    
    private var dataSources:Set<NSMetadataItem> = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    private let oldTextField  = NSTextField.init()
    private let newTextField = NSTextField.init()
    
    
}
extension iCloudViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installSubviews()
        iCloud.default.delegate = self
    }
}

extension iCloudViewController {
    
    private func installSubviews() {
        tableView.backgroundColor = NSColor.clear
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
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(200)
        }
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.leading.equalTo(tableView.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(200)
        }
        
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.equalTo(textView.snp.trailing)
            make.top.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        button.target = self
        button.action = #selector(buttonAction)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.width.equalTo(textField)
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor.red.cgColor
        
        view.addSubview(oldTextField)
        view.addSubview(newTextField)
        
        oldTextField.snp.makeConstraints { make in
            make.centerX.equalTo(textField)
            make.width.equalTo(textField)
            make.top.equalTo(textField.snp.bottom).offset(100)
            make.height.equalTo(50)
        }
        newTextField.snp.makeConstraints { make in
            make.centerX.equalTo(textField)
            make.width.equalTo(textField)
            make.top.equalTo(oldTextField.snp.bottom)
            make.height.equalTo(50)
        }
        
    }

}


extension iCloudViewController : NSTableViewDataSource {
    struct UserInterfaceItemIdentifier {
        static var cell = NSUserInterfaceItemIdentifier.init("EffectiveResourceViewController_cell")
        static var header = NSUserInterfaceItemIdentifier.init("EffectiveResourceViewController_HeaderView")
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSources.count
    }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
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
        let item = Array(dataSources)[row]
        if let name = item.value(forAttribute: NSMetadataItemFSNameKey) as? String {
            cell?.titleLabel.stringValue = name
        }
        
        if let cloud = iCloud.default.cloud, let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL {
            let string = url.relativePath.replacingOccurrences(of: cloud.relativePath, with: "")
            cell?.parentPathLabel.stringValue = string
        }
        if let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL {
            debugPrint("name:\(cell?.titleLabel.stringValue ?? "") ===path:\(url.path)")
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = NSTableRowView.init()
        return rowView
    }
}


extension iCloudViewController: CocoaTableViewDelegate {
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    func tableView(_ tableView: CocoaTableView, didSelectAt selectRow: Int, selectColumn: Int) {
//        let item = Array(self.dataSources)[selectRow]
//
//        guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL else {
//            return
//        }
//        self.oldTextField.stringValue = url.relativePath.replacingOccurrences(of: iCloud.default.cloud?.relativePath ?? "", with: "")
//        var dir: ObjCBool = false
//        FileManager.default.fileExists(atPath: url.path, isDirectory: &dir)
//
//        if dir.boolValue {
//            return
//        }
//
//        if let name = item.value(forAttribute: NSMetadataItemFSNameKey) as? String, let path = item.value(forAttribute: NSMetadataItemPathKey) as? String {
//            let string = path.replacingOccurrences(of: iCloud.default.cloud?.relativePath ?? "", with: "")
//            iCloud.default.open(CocoaDocument.self, document: string, ifNotExitsWith: true) { document, error in
//                if let error = error {
//                    debugPrint("\(error)")
//                }
//                self.textView.textView.string = document?.content ?? ""
//            }
//            self.textField.stringValue = name
//        }
//

    }
    
}



extension iCloudViewController : iCloudDelegate {
    func cloud(_ cloud: iCloud, syncDocument path: String, faieldByError error: Error?) {
        
    }
    
    func cloud(_ cloud: iCloud, uploadLocal path: String) -> Bool {
        return true
    }
    
    func cloud(_ cloud: iCloud, didFinishInitializingWith ubiquityToken: Any?) {
        debugPrint("\(#function)")
    }
    
    func cloud(_ cloud: iCloud, didChangedUbiquityToken newToken: Any?, oldToken: Any?) {
        debugPrint("\(#function)")
    }
    
    func cloud(_ cloud: iCloud, syncDidFinish files: [NSMetadataItem]) {
        debugPrint("\(#function)")
        dataSources.formUnion(files)
    }
    
    func cloud(_ cloud: iCloud, syncChanged type: iCloud.SyncType, onContent files: [NSMetadataItem]) {
        debugPrint("\(#function)")
        dataSources.formUnion(files)
    }
    
    func cloud(_ cloud: iCloud, didChanged files: [String]) {
        debugPrint("\(#function)")
    }
    
    func cloud(_ cloud: iCloud, conflictBetween cloudFile: String, localFile: String) {
        debugPrint("\(#function)")
    }
    
    
}



extension iCloudViewController {
    
    @objc private func buttonAction() {
//        save()
//        rename()
//        upload()
//        duplicate()
//        share()
//        openExit()
//        openNotExit()
        evict()
    }
    
    private func delete() {
        
    }

    private func evict() {
        let name = "doc/预览.md"
        iCloud.default.evict(CocoaDocument.self, nameOrPath: name) { localPath, error in
            if let error = error {
                debugPrint("\(error)")
            }
        }
    }
}


extension iCloudViewController {
    private func save() {
        let name = self.textField.stringValue
        let value = self.textView.textView.string
        if name.isEmpty || value.isEmpty {
            debugPrint("name is empty or value is empty")
            return
        }
        
        iCloud.default.save(CocoaDocument.self, name, content: value) { document, content, error in
            if let error = error {
                debugPrint("save failed: \(error)")
                return
            }
            
            debugPrint("save success . name:\(name) ===content:\(content)")
        }
    }
    
    
    private func rename() {
        let oldName = self.oldTextField.stringValue
        let newName = self.newTextField.stringValue
        if oldName.isEmpty || newName.isEmpty {
            return
        }
        
        if !iCloud.default.exitsInCloud(document: oldName) {
            return
        }
        
        iCloud.default.rename(document: oldName, with: newName) { error in
            if let error = error {
                debugPrint("rename error:\(error)")
            }
        }
    }
    
    private func duplicate() {
        let oldName = self.oldTextField.stringValue
        let newName = self.newTextField.stringValue
        if oldName.isEmpty || newName.isEmpty {
            return
        }
        
        if !iCloud.default.exitsInCloud(document: oldName) {
            return
        }
        
        
        iCloud.default.duplicate(document: oldName, with: newName) { error in
            if let error = error {
                debugPrint("duplicate error: \(error)")
            }
        }
        
    }
    
    
    
    private func upload() {
        let fileUrl = URL.init(fileURLWithPath: "/Users/tao/Desktop/预览.md")
//        let fileUrl = URL.init(fileURLWithPath: "/Users/tao/Documents/doc/预览.md")
        if iCloud.default.fileManager.isUbiquitousItem(at: fileUrl) {
            debugPrint("")
        }
        
        iCloud.default.upload(CocoaDocument.self, fileUrl, "doc/预览.md") { error in
            if let error = error {
                debugPrint("error upload: \(error)")
            }
        }
//        文件H3260.pptx

        
//        iCloud.default.upload(CocoaDocument.self, fileUrl, "H3260.pptx") { error in
//            if let error = error {
//                debugPrint("\(error)")
//            }
//        }
    }
    
    
    private func share() {
        let oldName = self.oldTextField.stringValue
        
        if !iCloud.default.exitsInCloud(document: oldName) {
            return
        }
        iCloud.default.share(document: oldName) { shared, expirationDate, error in
            if let error = error {
                debugPrint("share error: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    private func openExit() {
        let oldName = self.oldTextField.stringValue
        if !iCloud.default.exitsInCloud(document: oldName) {
            return
        }
        iCloud.default.open(CocoaDocument.self, document: oldName, ifNotExitsWith: true) { document, error in
            if let error = error {
                debugPrint("open error: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func openNotExit() {
        let oldName = self.oldTextField.stringValue
        if iCloud.default.exitsInCloud(document: oldName) {
            return
        }
        
        iCloud.default.open(CocoaDocument.self, document: oldName, ifNotExitsWith: true) { document, error in
            if let error = error {
                debugPrint("open error: \(error.localizedDescription)")
            }
        }
        
    }
}


//let cloudURL = iCloud.default.cloud?.appendingPathComponent("doc")
//
//if let cloudURL = cloudURL {
//    try? FileManager.default.removeItem(at: cloudURL)
////            try? iCloud.default.fileManager.evictUbiquitousItem(at: cloudURL)
//    do {
//        try iCloud.default.fileManager.setUbiquitous(false, itemAt: cloudURL, destinationURL: cloudURL)
//    } catch let error {
//        debugPrint("\(error)")
//    }
//
//}
//
//debugPrint("")
