//
//  iCloudKit+Share.swift
//  Pods
//
//  Created by 🐶 on 2021/12/8.
//

import Foundation
import CloudKit

private let default_share_zone_name = "_defaultZone"
extension iCloudKit {

    public func share(record r: CKRecord, zone name:String? = nil, _ complation: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        // 1. 查看share : UICloudSharingControllerDelegatezo
//        ne 是否存储， 不存在则创建
        let zoneId = CKRecordZone.ID.init(zoneName: name ?? default_share_zone_name, ownerName: CKCurrentUserDefaultName)
        fetchAll(database: .private) { [weak self] (zones, error) in
            if let error = error {
                complation(nil, error)
                return
            }

            if zones.contains(where: {$0.zoneID == zoneId}) {
                self?.shareRecord(record: r, complation)
            }else {
                self?.save(zone: CKRecordZone.init(zoneID: zoneId), database: .private) { [weak self] (result, error) in
                    if let error = error {
                        complation(nil, error)
                        return
                    }
                    self?.shareRecord(record: r, complation)
                }
            }
        }
    }
    
    
    /**
     perRecordProgressBlock:  进度回调，没处理一个 就回调一次
     perRecordCompletionBlock:  每个Record传输完成的回调
     modifyRecordsCompletionBlock:  Operation结束后的闭包回调
     */
    private func shareRecord(record r: CKRecord, _ complation: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        
        let shareRecord = CKShare.init(rootRecord: r)
        
//        通过 CKModifyRecordsOperation 保存根记录 和 分享记录
        let operation = CKModifyRecordsOperation.init(recordsToSave: [shareRecord], recordIDsToDelete: nil)
        
//        每个Record传输完成的回调
        operation.perRecordCompletionBlock = { (record, error) in
            // 分享记录 保存成功后可以在这获取到该分享的 url
                if let shareRecord = record as? CKShare, let url = shareRecord.url {
                    complation(url, nil)
                }else {
                    complation(nil, error)
                }
        }
        database(.private).add(operation)
    }
    
//    也可以直接获取 分享记录的 url、参与者 等信息，可以通过这些信息删除、新增参与者
    public func sharedAbout(_ record: CKRecord, _ complation:@escaping (_ url: URL?, _ participants:[CKShare.Participant], _ error: Error?) -> Void) {
        guard let sharedReference = record.share else {
            complation(nil, [],iCloudKitError.notShared)
            return
        }
        fetch(recordId: sharedReference.recordID, database: .private) { (record, error) in
            if let error = error {
                complation(nil, [], error)
                return
            }
            if let shareRecord = record as? CKShare {
                complation(shareRecord.url, shareRecord.participants, error)
            }else {
                complation(nil, [], iCloudKitError.notShared)
            }
        }
    }
    
    
    public func removeShare(_ record: CKRecord, _ participant:CKShare.Participant, _ complation:@escaping (_ result: Bool, _ error: Error?) -> Void) {
        guard let sharedReference = record.share else {
            complation(false,iCloudKitError.notShared)
            return
        }
        fetch(recordId: sharedReference.recordID, database: .private) { (record, error) in
            if let error = error {
                complation(false, error)
                return
            }
            if let shareRecord = record as? CKShare {
                shareRecord.removeParticipant(participant)
                complation(true, nil)
            }else {
                complation(false, error)
            }
        }
    }
}
