//
//  File.swift
//  TKiCloudModule
//
//  Created by 🐶 on 2021/11/29.
//

import Foundation


public protocol Document {
    associatedtype Value
    var content: Value { get }
    func update(_ content: Value)
}


extension iCloud {
    public enum SyncType {
        case add
        case remove
        case change
    }
}



public protocol iCloudStatus: AnyObject {
    // iCloud 初始化完成并可用
    func cloud(_ cloud: iCloud, didFinishInitializingWith ubiquityToken: Any?)
    // iCloud状态发生更改/需要判断是否可用
    func cloud(_ cloud: iCloud, didChangedUbiquityToken newToken: Any?, oldToken: Any?)
}

// 同步状态发生更改
public protocol iCloudSync: AnyObject {

    func cloud(_ cloud: iCloud, syncDidFinish files:[NSMetadataItem])
    func cloud(_ cloud: iCloud, syncChanged type: iCloud.SyncType, onContent files:[NSMetadataItem])
    func cloud(_ cloud: iCloud, syncDocument path: String, faieldByError error: Error?)
}
public protocol iCloudConflict: AnyObject {
    // 冲突
    func cloud(_ cloud: iCloud, conflictBetween cloudFile:String, localFile: String)
}


public typealias iCloudDelegate = iCloudStatus & iCloudSync & iCloudConflict



public struct SeatOptions: OptionSet {
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    
    public static let local  = SeatOptions(rawValue: 1 << 0)
    public static let cloud  = SeatOptions(rawValue: 1 << 1)
}


struct CloudDocument : Hashable {
    var item: NSMetadataItem
    var name: String = ""
    var path: String = ""
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.path)
    }
    
    var hashValue: Int {
        var hasher = Hasher.init()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
    
    static func == (lhs: CloudDocument, rhs: CloudDocument) -> Bool {
        return lhs.item == rhs.item && lhs.name == rhs.name && lhs.path == rhs.path
    }
    
}

