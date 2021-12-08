//
//  ViewController.swift
//  TKiCloudModule-iOS
//
//  Created by 🐶 on 2021/11/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import TKiCloudModule

class iCloudViewController: UIViewController {

    private let tableView = UITableView.init(frame: .zero, style: .plain)
    
    private var dataSources:[NSMetadataItem] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "iCloud Test"
        view.backgroundColor = UIColor.white
        installSubviews()
        
        iCloud.default.delegate = self
    }
}

extension iCloudViewController {
    private func installSubviews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Add", style: .plain, target: self, action: #selector(addButtonAction))
        
        
    }
    
    @objc private func addButtonAction() {
        let add = AddViewController.init()
        self.navigationController?.pushViewController(add, animated: true)
    }
    
}


extension iCloudViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = dataSources[indexPath.row]
        if let name = item.value(forAttribute: NSMetadataItemFSNameKey) as? String {
            cell.textLabel?.text = name
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
}

extension iCloudViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = dataSources[indexPath.row]
//        guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL else {
//            return
//        }
//        var dir: ObjCBool = false
//        FileManager.default.fileExists(atPath: url.path, isDirectory: &dir)
//
//        if dir.boolValue {
//            return
//        }
//
//
//
//        let show = ShowViewController.init()
//        show.item = item
//        self.navigationController?.pushViewController( show, animated: true)
    }
}





extension iCloudViewController: iCloudDelegate {
    func cloud(_ cloud: iCloud, syncDocument path: String, faieldByError error: Error?) {
        debugPrint("\(error.debugDescription)")
    }
    
    func cloud(_ cloud: iCloud, didFinishInitializingWith ubiquityToken: Any?) {
        debugPrint("\(#function)")
    }
    
    func cloud(_ cloud: iCloud, didChangedUbiquityToken newToken: Any?, oldToken: Any?) {
        debugPrint("\(#function)")
    }
    
    func cloud(_ cloud: iCloud, syncDidFinish files: [NSMetadataItem]) {
        debugPrint("\(#function)")
        dataSources.removeAll()
        dataSources.append(contentsOf: cloud.list)
    }
    
    func cloud(_ cloud: iCloud, syncChanged type: iCloud.SyncType, onContent files: [NSMetadataItem]) {
        files.forEach { item in
            if let path = item.value(forAttribute: NSMetadataItemPathKey) as? String {
                debugPrint("\(type):\(path)")
            }
        }
        dataSources.removeAll()
        dataSources.append(contentsOf: cloud.list)
    }

    func cloud(_ cloud: iCloud, conflictBetween cloudFile: String, localFile: String) {
        debugPrint("\(#function)")
    }
    
    
}

