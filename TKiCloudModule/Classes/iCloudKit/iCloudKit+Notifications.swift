//
//  iCloudKit+Notifications.swift
//  Pods
//
//  Created by 🐶 on 2021/12/8.
//

import Foundation
import UserNotifications
import CloudKit


private let serverChangeTokenKey = "TKiCloudModule_ServerChangeToken"

#if os(iOS)

extension iCloudKit {
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        updateWithNotificationUserInfo(userInfo: userInfo)
    }
    func application( _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        updateWithNotificationUserInfo(userInfo: userInfo)
        completionHandler(.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        updateWithNotificationUserInfo(userInfo: notification.request.content.userInfo)
        completionHandler([])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        updateWithNotificationUserInfo(userInfo: response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let acceptShareOperation: CKAcceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        
        acceptShareOperation.qualityOfService = .userInteractive
        acceptShareOperation.perShareCompletionBlock = { meta, share, error in
            print("share was accepted")
        }
        acceptShareOperation.acceptSharesCompletionBlock = { error in
            /// Send your user to where they need to go in your app
        }
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptShareOperation)
    }
    
}


#endif



#if os(macOS)

extension iCloudKit {
    public func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        updateWithNotificationUserInfo(userInfo: userInfo)
    }
//    func application( _ application: NSApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//                      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        updateWithNotificationUserInfo(userInfo)
//        completionHandler(.newData)
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        updateWithNotificationUserInfo(notification.request.content.userInfo)
//        completionHandler([])
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        updateWithNotificationUserInfo(response.notification.request.content.userInfo)
//        completionHandler()
//    }
}



#endif


extension iCloudKit {
    private func updateWithNotificationUserInfo(userInfo:[AnyHashable: Any]) {
        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        if let _ = cloudKitNotification.subscriptionID {
            
            switch cloudKitNotification.notificationType {
                
            case .query:
                break
            case .recordZone:
                break
            case .readNotification:
                break
            case .database:
                break
            }

        }

    }
}



extension iCloudKit {
    
    // 下拉
    private func asyncPull() {
        
        let changesOperation = CKFetchDatabaseChangesOperation.init(previousServerChangeToken: changeToken())
        changesOperation.fetchAllChanges = true
        
        
        // 保存所有有改变的 zoneID
        changesOperation.recordZoneWithIDChangedBlock = { [weak self] zoneID in
            self?.changeZoneIds.append(zoneID)
        }
        
        // 删除本地的数据
        changesOperation.recordZoneWithIDWasDeletedBlock = { zoneID in
                                                            
        }
        // token 更新
        changesOperation.changeTokenUpdatedBlock = { token in
             
        }
        
        changesOperation.fetchDatabaseChangesCompletionBlock = { [weak self] (newToken: CKServerChangeToken?, more: Bool, error: Error?) in
            // 如果上面 changesOperation.fetchAllChanges = false， 那么 changes 有可能会分段返回
            // 这里的 more 就用来标识后面是否还有 changes
              
            // 在这个缓存 token 下次使用
            // 用官方的话说就是 saving the change token at the end of the operation
                                                                
            // 根据 changedZoneIDs 获取 zone 中 record 的改变
            if !more {
                self?.fetchZoneChanges(recordZoneIDs: self?.changeZoneIds ?? [])
                self?.changeZoneIds.removeAll()
            }
           
        }
        
        self.database(.private).add(changesOperation)
        
    }
}



extension iCloudKit {
    private func fetchZoneChanges(recordZoneIDs: [CKRecordZone.ID]) {
        // 可以通过 optionsByRecordZoneID 设置 token、resultLimit 等
        let options = CKFetchRecordZoneChangesOperation.ZoneOptions()
            options.previousServerChangeToken = changeToken()
        let changesOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: recordZoneIDs, optionsByRecordZoneID: nil)
        changesOperation.fetchAllChanges = true
        changesOperation.qualityOfService = .background
        
        // record 改变
        changesOperation.recordChangedBlock = { record in
                                               
        }
        // record 删除
        changesOperation.recordWithIDWasDeletedBlock = { (recordID, recordType) in
                                                        
        }
        // 某个 zone 的 changToken 更新
        changesOperation.recordZoneChangeTokensUpdatedBlock = { (zoneID, token, tokenData) in
            guard let changeToken = token else {
                return
            }
                
            let changeTokenData = NSKeyedArchiver.archivedData(withRootObject: changeToken)
            UserDefaults.standard.set(changeTokenData, forKey: serverChangeTokenKey)
        }
        // 某个 zone 的 fetchChanges 操作完成
        changesOperation.recordZoneFetchCompletionBlock = { (zoneID, token, tokenData, moreComing, error) in
            // 在这个缓存 token 下次使用
            // 用官方的话说就是 saving the change token at the end of the operation
            guard error == nil else {
                return
            }
            guard let changeToken = token else {
                return
            }

            let changeTokenData = NSKeyedArchiver.archivedData(withRootObject: changeToken)
            UserDefaults.standard.set(changeTokenData, forKey: serverChangeTokenKey)
        }
        // 所有 zone 的 fetchChanges 操作完成
        changesOperation.fetchRecordZoneChangesCompletionBlock = { error in
            guard error == nil else {
                return
            }
        }
        
        database(.private).add(changesOperation)
    }
    
    
    private func changeToken() -> CKServerChangeToken? {
        var changeToken: CKServerChangeToken? = nil
        let changeTokenData = UserDefaults.standard.data(forKey: serverChangeTokenKey)
        if let data = changeTokenData {
            changeToken = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken
        }
        return changeToken
    }
}
