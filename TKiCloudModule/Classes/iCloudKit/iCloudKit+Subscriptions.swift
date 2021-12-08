//
//  iCloudKit+Subscriptions.swift
//  Pods
//
//  Created by 🐶 on 2021/12/8.
//

import Foundation
import CloudKit

//创建Zone
//订阅 数据库变化
//在 App 启动的时候获取记录然后显示给用户
//推送用户本地的变化
//周期性执行第三步和第四步 (数据推拉)
//用户最小化应用时(App进入后台)推拉一次
//用户启动App的时候(App进入前台)时推拉一次

extension iCloudKit {
    
    public func save<T: CKSubscription>(subscription: T , database type: CKDataBaseType,_ complation:@escaping (_ result: Bool, _ error: Error?) ->Void) {
        
        if subscription is CKDatabaseSubscription, type == .public {
            complation(false, iCloudKitError.notSupportType(type: type))
            return
        }
        
        if subscription is CKRecordZoneSubscription, type != .private {
            complation(false, iCloudKitError.notSupportType(type: type))
            return
        }
        
        if subscription is CKQuerySubscription, type == .shared {
            complation(false, iCloudKitError.notSupportType(type: type))
            return
        }
        
        
        database(type).save(subscription) { sub, error  in
            if let  error = error {
                complation(false, error)
                return
            }
            
            complation(true, nil)
        }
    }
    
    public func save( database type: CKDataBaseType, recordType: CKRecord.RecordType, predicate: NSPredicate,subscriptionID: CKSubscription.ID = UUID().uuidString,options querySubscriptionOptions: CKQuerySubscription.Options = [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion], _ complation:@escaping (_ result: Bool, _ error: Error?) ->Void) {
        
        
        
        
        let subscription = CKQuerySubscription(recordType: recordType,
                                                           predicate: predicate,
                                                           subscriptionID: subscriptionID,
                                                           options:querySubscriptionOptions)
     
        let notificationInfo =  CKSubscription.NotificationInfo.init()
        notificationInfo.shouldSendContentAvailable = true
        
        subscription.notificationInfo = notificationInfo
        database(type).save(subscription) { sub, error  in
            if let  error = error {
                complation(false, error)
                return
            }
            
            complation(true, nil)
        }
    }
    
    
    
    
    
    
    
    
    public func fetch<T:CKSubscription>(subscriptionId id: CKSubscription.ID, database type: CKDataBaseType, _ complation:@escaping (_ model: T?, _ error: Error?)-> Void) {
        
        database(type).fetch(withSubscriptionID: id) { sub, error in
            if let  error = error {
                complation(nil, error)
                return
            }
            complation(sub as? T, nil)
        }

    }
    
    public func fetchAll<T:CKSubscription>(database type: CKDataBaseType,use operation:Bool = true, _ complation:@escaping (_ model: [T]?, _ error: Error?)-> Void) {
       
        if !operation {
            database(type).fetchAllSubscriptions { (subs, error) in
                if let error = error {
                    complation(nil, error)
                    return
                }
                complation(subs as?[T], nil)
            }
        }
        
        let operation = CKFetchSubscriptionsOperation.fetchAllSubscriptionsOperation()
        operation.fetchSubscriptionCompletionBlock = { subs, error in
            if let error = error {
                complation(nil, error)
                return
            }
            
            let values = subs?.values.map({ (sub) -> CKSubscription in
                return sub
            })
            
            complation((values as? [T]) ?? [], nil)
        }
        database(type).add(operation)
    }
    
    
    public func delete(subscriptionId id: CKSubscription.ID,database type: CKDataBaseType,  _ complation:@escaping (_ result:Bool, _ id: CKSubscription.ID?, _ error: Error?)-> Void) {
          
           database(type).delete(withSubscriptionID: id) { (id, error) in
               complation(id != nil ,id, error)
           }
       }
       
       
   public func delete(subscription ids: [CKSubscription.ID],database type: CKDataBaseType,  _ complation:@escaping (_ result:Bool, _ id: [CKSubscription.ID]?, _ error: Error?)-> Void) {
      
     
       let operation = CKModifySubscriptionsOperation.init(subscriptionsToSave: nil, subscriptionIDsToDelete: ids)
       operation.modifySubscriptionsCompletionBlock = { subs, ids, error in
           guard let ids = ids else {
               complation(false, nil, error)
               return
           }
           complation(true, ids, nil)
       }
       database(type).add(operation)
   }
    
    
    public func delete(subscriptionId ids: [CKSubscription.ID],database type: CKDataBaseType,  _ complation:@escaping (_ result:Bool, _ id: [CKSubscription.ID]?, _ error: Error?)-> Void) {

        let operation = CKModifySubscriptionsOperation.init(subscriptionsToSave: nil, subscriptionIDsToDelete: ids)
        operation.modifySubscriptionsCompletionBlock = { subs, ids, error in
            guard let ids = ids else {
                complation(false, nil, error)
                return
            }
            complation(true, ids, nil)
        }
        database(type).add(operation)
    }
    
}
