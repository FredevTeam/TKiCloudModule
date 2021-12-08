//
//  iCloud.swift
//  TKiCloudModule
//
//  Created by 🐶 on 2021/11/29.
//

import Foundation


private var iclouds = [String: iCloud].init()

public class iCloud {
    
    public static let `default` = iCloud.init()
    
    
    let queue = DispatchQueue.init(label: "com.icloudmodule.queue", qos: .background)
    public let fileManager = FileManager.init()
    let query = NSMetadataQuery.init()
    
    
    private var oldToken: Any? = nil
    private(set) var cloudDocuments:Set<CloudDocument> = [] {
        didSet {
            async()
        }
    }
    
    
    public weak var delegate: iCloudDelegate?
    
    
    public private(set) var local:URL
    public private(set) var cloud: URL? = nil
    public private(set) var ubiquityContainer: URL? {
        didSet {
            if let ubiquityContainer = ubiquityContainer {
                self.cloud = ubiquityContainer.appendingPathComponent("Documents")
            }
        }
    }
    
    
    
    
    
    private init(_ identifier: String? = nil) {
        self.local = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).first!
        #if os(macOS)
        if let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String, !isSandboxEnvironment() {
            self.local.appendPathComponent(name)
        }
        #endif

        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        try? fileManager.createDirectory(at: local, withIntermediateDirectories: true, attributes: nil)
        
        
        queue.async {
            self.ubiquityContainer = self.fileManager.url(forUbiquityContainerIdentifier: identifier)
            self.oldToken = self.fileManager.ubiquityIdentityToken
            
            
            DispatchQueue.main.async {
                
                if let _ = self.oldToken {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.availabilityChange(_:)), name: .NSUbiquityIdentityDidChange, object: self)
                    self.delegate?.cloud(self, didFinishInitializingWith: self.oldToken)
                    self.startMonitor()
                }else {
                    
                    self.delegate?.cloud(self, didChangedUbiquityToken: nil, oldToken: self.oldToken)
                }
                
            }
            
        }
        
    }
}

extension iCloud {
    var ubiquitous: URL {
        return self.cloud ?? self.local
    }
}

extension iCloud {
    @objc private func availabilityChange(_ noti: Notification) {
        let newToken = self.fileManager.ubiquityIdentityToken
        self.delegate?.cloud(self, didChangedUbiquityToken: newToken, oldToken: self.oldToken)
        self.oldToken = newToken
    }
}



extension iCloud {
    private func startMonitor() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.startGathering(_:)), name: NSNotification.Name.NSMetadataQueryDidStartGathering, object: self.query)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateGathering(_:)), name: NSNotification.Name.NSMetadataQueryDidUpdate, object: self.query)
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishGathering(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: self.query)
        DispatchQueue.main.async {
            self.query.start()
        }
    }
    @objc private func startGathering(_ notifi: Notification) {
        
    }
    @objc private func updateGathering(_ notifi: Notification) {
        queue.async {
            self.query.disableUpdates()
            defer {
                self.query.enableUpdates()
            }
            guard let userInfo = notifi.userInfo else {
                return
            }
            
            if let items = userInfo[NSMetadataQueryUpdateAddedItemsKey] as? [NSMetadataItem] {
                let citems:[CloudDocument] = items.compactMap { item in
                    if let name = item.value(forAttribute: NSMetadataItemFSNameKey) as? String ,let path = item.value(forAttribute: NSMetadataItemPathKey) as? String {
                        return CloudDocument.init(item: item, name: name, path: path)
                    }
                    return nil
                }
                
                self.cloudDocuments.formUnion(citems)
                self.delegate?.cloud(self, syncChanged: .add, onContent: items)
            }
            if let items = userInfo[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem] {
                let citems:[CloudDocument] = items.compactMap { item in
                    if let name = item.value(forAttribute: NSMetadataItemFSNameKey) as? String ,let path = item.value(forAttribute: NSMetadataItemPathKey) as? String {
                        return CloudDocument.init(item: item, name: name, path: path)
                    }
                    return nil
                }
                
                self.cloudDocuments.subtract(citems)
                self.delegate?.cloud(self, syncChanged: .remove, onContent: items)
            }
            if let items = userInfo[NSMetadataQueryUpdateChangedItemsKey] as? [NSMetadataItem] {
                let citems:[CloudDocument] = items.compactMap { item in
                    if let name = item.value(forAttribute: NSMetadataItemFSNameKey) as? String ,let path = item.value(forAttribute: NSMetadataItemPathKey) as? String {
                        return CloudDocument.init(item: item, name: name, path: path)
                    }
                    return nil
                }
                self.cloudDocuments.formUnion(citems)
                self.delegate?.cloud(self, syncChanged: .remove, onContent: items)
            }
            
        }
    }
    @objc private func finishGathering(_ notifi: Notification) {
        queue.async {
            self.query.disableUpdates()
            defer {
                self.query.enableUpdates()
            }
            
            var items:[NSMetadataItem] = []
            
            let citems:[CloudDocument] = self.query.results.compactMap { item in
                if let item = item as? NSMetadataItem {
                    items.append(item)
                    if let name = item.value(forAttribute: NSMetadataItemFSNameKey) as? String ,let path = item.value(forAttribute: NSMetadataItemPathKey) as? String {
                        return CloudDocument.init(item: item, name: name, path: path)
                    }
                }
                return nil
            }
            
            self.cloudDocuments.formUnion(citems)
            self.delegate?.cloud(self, syncDidFinish: items)
        }
    }
}


#if os(macOS)
extension iCloud {

    private func isSandboxEnvironment() -> Bool {
        let environ = ProcessInfo.processInfo.environment
        return (nil != environ["APP_SANDBOX_CONTAINER_ID"])
    }
}

#endif


