//
//  iCloudKit+Zones.swift
//  Pods
//
//  Created by 🐶 on 2021/12/8.
//

import Foundation
import CloudKit

extension iCloudKit {
    
    public func save(zone: CKRecordZone, database type: CKDataBaseType, _ completion:@escaping (_ result: Bool, _ error: Error?) -> Void) {
        
        if type != .private {
            completion(false, iCloudKitError.notSupportType(type: type))
            return
        }
        
        if zone.zoneID == CKRecordZone.default().zoneID {
            completion(false, iCloudKitError.notSupportSave(value: zone))
            return
        }
        
        
        
        database(type).save(zone) { zone, error in
            completion(zone != nil, error)
        }
        
    }
    
    public func fetch(zone id: CKRecordZone.ID, database type: CKDataBaseType, _ completion:@escaping (_ zone: CKRecordZone?, _ error: Error?) -> Void) {
        
        database(type).fetch(withRecordZoneID: id) { zone, error in
            completion(zone, error)
        }
        
    }
    
    
    public func fetchAll(database type: CKDataBaseType, _ completion:@escaping (_ zone: [CKRecordZone], _ error: Error?) -> Void) {
        
        
        database(type).fetchAllRecordZones { zones, error in
            completion(zones ?? [] , error)
        }
        
    }
    
    
    public func delete(zone id: CKRecordZone.ID, database type: CKDataBaseType, _ completion:@escaping (_ result:Bool, _ id: CKRecordZone.ID?, _ error: Error?)-> Void) {
        
        if type != .private {
            
            completion(false, nil, iCloudKitError.notSupportType(type: type))
            return
        }
        if id == CKRecordZone.default().zoneID {
            completion(false, nil, iCloudKitError.notSupportDelate(value: id))
            return
        }
        
        database(type).delete(withRecordZoneID: id) { zoneID, error in
            completion(zoneID != nil, id, error)
        }
        
    }
    
}
