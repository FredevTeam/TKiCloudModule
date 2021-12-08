//
//  iCloud+Exts.swift
//  TKiCloudModule
//
//  Created by 🐶 on 2021/12/2.
//

import Foundation

extension iCloud {
    struct Information {
        var size:UInt64
        var type: String?
        var create: Date?
        var modified:Date?
        var permissions:Int
        var extensionHidden: Bool
        var isImmutable:Bool
        var appendOnly:Bool
        var accountName:String?
        var accountId: Int64?
    }
    
    
    func attributes(document nameOrPath: String) -> Information? {
        do {
            let attributes: NSDictionary = try FileManager.default.attributesOfItem(atPath: ubiquitous.path) as NSDictionary
            return Information.init(size: attributes.fileSize(),
                                        type: attributes.fileType(),
                                        create: attributes.fileCreationDate(),
                                        modified: attributes.fileModificationDate(),
                                        permissions: attributes.filePosixPermissions(),
                                        extensionHidden: attributes.fileExtensionHidden(),
                                        isImmutable: attributes.fileIsImmutable(),
                                        appendOnly: attributes.fileIsAppendOnly(),
                                        accountName: attributes.fileOwnerAccountName(),
                                    accountId: attributes.fileOwnerAccountID()?.int64Value)
        } catch _ {
            return nil
        }
    }
}






extension iCloud {
    
    /// 是否存在iCloud中
    /// - Parameter nameOrPath: nameOrPath
    /// - Returns: description
    public func exitsInCloud(document nameOrPath: String) -> Bool {
        if nameOrPath.isEmpty {
            return false
        }

        if let cloudURL = cloud?.appendingPathComponent(nameOrPath), fileManager.isUbiquitousItem(at: cloudURL) {
            return true
        }
        return false
    }
}

extension iCloud {
    func verify(string: String) -> String {
        if string.first == "/" {
            return String(string.dropFirst())
        }
        return string
    }
}
