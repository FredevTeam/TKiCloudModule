//
//  iCloudKitProtocol.swift
//  Pods
//
//  Created by 🐶 on 2021/12/8.
//

import Foundation


import CloudKit

public protocol iCloudKitDelegate: AnyObject {
    func cloudKit(_ cloudKit: iCloudKit, changedAccount status:CKAccountStatus, error: Error?)
}



public protocol Record {
    init()
    func set(_ value: Any?, for key: String)
}


public protocol Ignore {
    var ignore:[String] {get}
}

extension Ignore {
    var ignore:[String] {
        return []
    }
}
