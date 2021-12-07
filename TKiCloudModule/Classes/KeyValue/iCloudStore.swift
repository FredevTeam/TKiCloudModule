//
//  iCloudStore.swift
//  Pods-TKiCloudModule_Example
//
//  Created by 🐶 on 2021/11/29.
//

import Foundation

public protocol iCloudStoreDelegate: AnyObject {
    func cloudStore(_ cloudStore: iCloudStore, keyValueChange reson:iCloudStore.KeyValueStoreChangeReason?, change keys:[String]?)
}


public class iCloudStore {
    public static let instance = iCloudStore.init()
    
    public weak var delegate:iCloudStoreDelegate?
    
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeExternally(_ :)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: nil)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension iCloudStore {
    @objc private func didChangeExternally(_ notification: Notification) {
        if let userInfo = notification.userInfo, let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int, let changeKey = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] {
            self.delegate?.cloudStore(self, keyValueChange: KeyValueStoreChangeReason.init(rawValue: reason), change: changeKey)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }
}


extension iCloudStore {

    public func set<T>(_ value: T, key: String) {
        NSUbiquitousKeyValueStore.default.set(value, forKey: key)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    public func value<T>(_ key: String) -> T? {
        let value = NSUbiquitousKeyValueStore.default.object(forKey: key) as? T
        NSUbiquitousKeyValueStore.default.synchronize()
        return value
    }
    
    @discardableResult
    public func remove(_ key: String) -> Bool {
        NSUbiquitousKeyValueStore.default.removeObject(forKey: key)
        NSUbiquitousKeyValueStore.default.synchronize()
        return false
    }
   
    
    public var dictionaryRepresentation: [String : Any] {
        return NSUbiquitousKeyValueStore.default.dictionaryRepresentation
    }
}


extension iCloudStore {
    public enum KeyValueStoreChangeReason : Int {
        case ServerChange
        case InitialSyncChange
        case QuotaViolationChange
        case AccountChange
        
        public init?(rawValue: Int) {
            switch rawValue {
            case NSUbiquitousKeyValueStoreServerChange:
                self = KeyValueStoreChangeReason.ServerChange
            case NSUbiquitousKeyValueStoreInitialSyncChange:
                self = .InitialSyncChange
            case NSUbiquitousKeyValueStoreQuotaViolationChange:
                self = .QuotaViolationChange
            case NSUbiquitousKeyValueStoreAccountChange:
                self = .AccountChange
            default:
                return nil
            }
        }
    }
}


extension iCloudStore: CustomDebugStringConvertible {
    public var debugDescription: String {
        let string =
            """
            Key-Value:
                * 最大总键值存储大小为1 MB（每个用户）
                * 一个键值对不能大于1 MB
                * 您最多可以存储1024个键值对
                * 使用UTF-8编码，密钥不能大于64个字节
                * NSUbiquitousKeyValueStoreChangeReasonKey 获取数据更改的原因
                * NSUbiquitousKeyValueStoreChangedKeysKey 获取已更改数据的密钥
            Document:
                
            """
        
        return string
    }
}
