//
//  iCloudKit.swift
//  Pods
//
//  Created by 🐶 on 2021/12/8.
//

import Foundation
import CloudKit



private var icloudKitsDic = [String: iCloudKit].init()

public class iCloudKit {
    
    public static let `default` = iCloudKit.init(nil)
    public weak var delegate: iCloudKitDelegate?
    
    var changeZoneIds:[CKRecordZone.ID] = []
    
    private(set) var container:CKContainer = CKContainer.default()
    private init(_ identifier: String?) {
        if  let id = identifier {
            container = CKContainer.init(identifier: id)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(accountChange), name: .CKAccountChanged, object: self)
    }
}
extension iCloudKit {
    @objc private func accountChange() {
        checkAccountStatus { [weak self] status, error in
            guard let self = self else {
                return
            }
            self.delegate?.cloudKit(self, changedAccount: status, error: error)
        }
    }
}
extension iCloudKit {
    public static func kit(with identifier: String) -> iCloudKit {
        if let value = icloudKitsDic[identifier] {
            return value
        }
        let kit = iCloudKit.init(identifier)
        icloudKitsDic.updateValue(kit, forKey: identifier)
        return kit
    }
}

extension iCloudKit {
    public func database(_ with: CKDataBaseType) -> CKDatabase {
        return self.container.database(with: with.scope)
    }
    public var containerIdentifier: String? {
        return container.containerIdentifier
    }
}
