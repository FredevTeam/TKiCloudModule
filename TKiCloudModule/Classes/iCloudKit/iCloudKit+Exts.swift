//
//  iCloudKit+Exts.swift
//  Pods
//
//  Created by 🐶 on 2021/12/8.
//

import Foundation
import CloudKit


extension iCloudKit {
    /// 查询当前icloud kit status
    /// - Parameter complation: complation
    public func checkAccountStatus(complation: @escaping (CKAccountStatus, Error?) -> Void) {
        self.container.accountStatus(completionHandler: complation)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func status() async -> CKAccountStatus {
        return (try? await self.container.accountStatus()) ?? .temporarilyUnavailable
    }
}






extension iCloudKit {
    
    public func add(database type: CKDataBaseType,  _ operation:CKDatabaseOperation)  {
        database(type).add(operation)
    }
    
    
}


