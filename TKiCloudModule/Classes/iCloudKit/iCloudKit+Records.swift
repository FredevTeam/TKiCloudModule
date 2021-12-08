//
//  iCloudKit+Records.swift
//  Pods
//
//  Created by 🐶 on 2021/12/8.
//

import Foundation
import CloudKit
import CoreFoundation

#if os(iOS)
import UIKit

#endif

#if os(macOS)
import AppKit
#endif


extension iCloudKit {
    private func convert<T>(_ value: T , record type: CKRecord.RecordType, recordId: CKRecord.ID? = CKRecord.ID()) -> CKRecord? {
        let record = CKRecord.init(recordType: type, recordID: recordId ?? CKRecord.ID())
        
        var ignores:[String] = []
        if let i = value as? Ignore {
            ignores.append(contentsOf: i.ignore)
        }
        
        let propertys = propertyList(entity: value).filter({ !ignores.contains($0.name)})
        
        
        func size(_ data: Data) -> Float {
            let bcf = ByteCountFormatter.init()
            bcf.allowedUnits = [.useMB]
            bcf.countStyle = .binary
            return (bcf.string(fromByteCount: Int64(data.count)) as NSString).floatValue
        }
        
        for item in propertys {
            
            if item.type == Image.self, let asset = convert_imageToAsset(item.value as! Image)  {
                record.setValue(asset, forKey: item.name)
                continue
            }
            
            if item.type == CGImage.self {
                let cgimage = item.value as! CGImage
                if  let asset = convert_imageToAsset(Image.init(cgImage: cgimage, size: .zero)) {
                    record.setValue(asset, forKey: item.name)
                    continue
                }
                
            }
            
            if item.type == CIImage.self {
                let ciimage = item.value as! CIImage
                let ciimageRep = NSCIImageRep.init(ciImage: ciimage)
                let image = NSImage.init(size: ciimageRep.size)
                image.addRepresentation(ciimageRep)
                if  let asset = convert_imageToAsset(image) {
                    record.setValue(asset, forKey: item.name)
                    continue
                }
                
            }
            
            
            if item.type == Data.self || item.type == NSData.self {
                if size(item.value as! Data) > 0.8, let asset = convert_DataToAsset(item.value as! Data) {
                    record.setValue(asset, forKey: item.name)
                }else {
                    record.setValue(item.value, forKey: item.name)
                }
                
                continue
            }
            
            record.setValue(item.value, forKey: item.name)
        }
        
        
        return record
    }
    
    private func convert<T:Record>(_ record: CKRecord) ->T? {
        
        let model = T.init()
        
        var ignores:[String] = []
        if let i = model as? Ignore {
            ignores.append(contentsOf: i.ignore)
        }
        
        let propertys = propertyList(entity: model).filter({ !ignores.contains($0.name)})
        
        for item in propertys {
            let value = record.value(forKey: item.name)
            
            if value is CKAsset, item.type == Image.self {
                if let image = convert_AssetToImage(value as! CKAsset) {
                    model.set(image, for: item.name)
                }
                continue
            }
            if value is CKAsset, item.type == CGImage.self {
                if let image = convert_AssetToImage(value as! CKAsset) {
                    model.set(image.cgImage, for: item.name)
                }
                continue
            }
            
            if value is CKAsset, item.type == CIImage.self {
                if let image = convert_AssetToImage(value as! CKAsset)  {
                    model.set(image.ciImage, for: item.name)
                }
                continue
            }
            
            if value is CKAsset, (item.type == Data.self || item.type == NSData.self) {
                model.set(convert_AssetToData(value as! CKAsset), for: item.name)
                continue
            }
            model.set(value , for: item.name)
        }
        

        
        return model
    }
    
    
    private func update<T>(_ value: T, record: inout CKRecord) {
        
        var ignores:[String] = []
        if let i = value as? Ignore {
            ignores.append(contentsOf: i.ignore)
        }
        
        let propertys = propertyList(entity: value).filter({!ignores.contains($0.name)})
        
        propertys.forEach { (name: String, type: Any.Type, value: Any) in
            record.setValue(value, forKey: name)
        }
        
    }
    
    
    private func convert_imageToAsset(_ image: Image) -> CKAsset? {
        
        #if os(macOS)
        if let data = image.tiffRepresentation, let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")  {
            
            try? data.write(to: url, options: [])
            return CKAsset.init(fileURL: url)
        }
        #endif

        
        #if os(iOS)
        if let data = image.pngData(), let url = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).first?.appendingPathComponent(NSUUID().uuidString+".dat") {
            try? data.write(to: url, options: [])
            return CKAsset.init(fileURL: url)
        }
        
        #endif
        
        return nil
    }
    
    private func convert_AssetToImage(_ asset: CKAsset) -> Image? {
        let image = Image.init(contentsOfFile: asset.fileURL.path)
        return image
    }
    
    private func convert_DataToAsset(_ data: Data) -> CKAsset? {
     
        #if os(macOS)
        if let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat") {
            try? data.write(to: url, options: [])
            return CKAsset.init(fileURL: url)
        }
        #endif


        #if os(iOS)
        if let url = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).first?.appendingPathComponent(NSUUID().uuidString+".dat") {
            try? data.write(to: url, options: [])
            return CKAsset.init(fileURL: url)
        }

        #endif
        return nil
    }
    
    private func convert_AssetToData(_ asset: CKAsset) -> Data {
        return (try? Data.init(contentsOf: asset.fileURL, options: [])) ?? Data.init()
    }
    
    
}

// MARK: -SAVE
extension iCloudKit {
    public func save<T: Record>(recordType: CKRecord.RecordType,
                                database type: CKDataBaseType,
                                model: T,
                                recordID:CKRecord.ID? = nil,
                                _ complation:@escaping (_ result: Bool, _ error: Error?) ->Void) {
        
        guard let record = convert(model, record: recordType, recordId: recordID) else {
            complation(false, iCloudKitError.conversionError(value: model))
            return
        }
        
        database(type).save(record) { record, error in
            complation(record != nil, error)
        }
    }
    public func save<T: Record>(recordType: CKRecord.RecordType,
                                database type: CKDataBaseType,
                                model: T,
                                zoneID:CKRecordZone.ID? = nil,
                                _ complation:@escaping (_ result: Bool, _ error: Error?) ->Void) {
        
        let recordID = CKRecord.ID.init(recordName: recordType, zoneID: zoneID ?? CKRecordZone.ID.default)
        
        guard let record = convert(model, record: recordType, recordId: recordID) else {
            complation(false, iCloudKitError.conversionError(value: model))
            return
        }
        
        database(type).save(record) { record, error in
            complation(record != nil, error)
        }
    }
    
    public func save<T:Record>(recordType: CKRecord.RecordType,
                     database type: CKDataBaseType,
                     models: [T],
                     zoneID:CKRecordZone.ID? = nil,
                               _ complation:@escaping (_  ids: [CKRecord.ID]?, _ error: Error?) ->Void) {
        
    }
    
    public func save(records: [CKRecord],
                     database type: CKDataBaseType,
                               _ complation:@escaping (_  ids: [CKRecord.ID]?, _ error: Error?) ->Void) {
        
        let operation = CKModifyRecordsOperation.init(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .ifServerRecordUnchanged
        operation.queuePriority = .high
        operation.qualityOfService = .userInitiated
        
        operation.modifyRecordsCompletionBlock = { records, recordIds, error in
            if let error = error {
               complation(nil, error)
               return
           }
           complation(recordIds, nil)
        }
        
        database(type).add(operation)
        
    }
    
    
}


// MARK: FETCH
extension iCloudKit {
    public func fetch(recordId id: CKRecord.ID,database type: CKDataBaseType,  _ complation:@escaping (_ record: CKRecord?, _ error: Error?)-> Void) {

        database(type).fetch(withRecordID: id) {(record, error) in
            complation(record, error)
        }
    }
    
    public func fetch<T: Record>(recordId id: CKRecord.ID,database type: CKDataBaseType,  _ complation:@escaping (_ model: T?, _ error: Error?)-> Void) {

        database(type).fetch(withRecordID: id) { [weak self] record, error in
            if let self = self, let record = record, let model:T = self.convert(record) {
                complation(model, nil)
                return
            }
            complation(nil, error)
        }
    }
    public func fetahAll<T:Record>(type: CKDataBaseType, zoneID:CKRecordZone.ID? = nil,_ complation:@escaping (_ model: [T]?, _ error: Error?)-> Void) {
        
    }
    
    
    public func query<T:Record>(_ predicate: NSPredicate,
                                         database type: CKDataBaseType,
                                         recordType name: String,
                                         use operation: Bool = true,
                                         zone: CKRecordZone.ID? = nil,
                                         complation:@escaping (_ models:[T], _ error: Error?)->Void) {
        
         func compltion_func(records: [CKRecord]?, error: Error?) -> [T]? {
            if let _ = error {
                return nil
            }
            var results:[T] = []
            records?.forEach({ (record) in
                if let model:T = self.convert(record) {
                    results.append(model)
                }
            })
            return results
        }

        let query = CKQuery.init(recordType: name, predicate: predicate)
        
        if !operation {
            // 查询集合数据
            database(type).perform(query, inZoneWith: zone) {(records, error) in
                complation(compltion_func(records: records, error: error) ?? [], error)
            }
            return
        }
        
        var results = [T].init()
        let operation = CKQueryOperation.init(query: query)
        operation.resultsLimit = 20
        let fetchedBlock = { (record: CKRecord) -> Void in
            if let rs = compltion_func(records: [record], error: nil) {
                results.append(contentsOf: rs)
            }
        }
        operation.recordFetchedBlock = fetchedBlock
        
        
        let complationBlock = { [weak self] (cursor: CKQueryOperation.Cursor?, error: Error?) -> Void in
            if let cursor = cursor {
                let containOperation = CKQueryOperation.init(cursor: cursor)
                containOperation.queryCompletionBlock = operation.queryCompletionBlock
                containOperation.recordFetchedBlock = fetchedBlock
                containOperation.resultsLimit = operation.resultsLimit
                self?.database(type).add(operation)
            } else {
                complation(results, nil)
            }
        }
        
        
        operation.queryCompletionBlock = complationBlock
        database(type).add(operation)
    }
    
}


// MARK: delete
extension iCloudKit {
    public func delete(recordId id: CKRecord.ID,database type: CKDataBaseType, _ complation:@escaping (_ result:Bool, _ id: CKRecord.ID?, _ error: Error?)-> Void) {
        
        database(type).delete(withRecordID: id) { (record, error) in
            complation(record != nil ,record, error)
        }
    }
    
    public func delete(record IDs:[CKRecord.ID], database type: CKDataBaseType,_ complation:@escaping (_ result:Bool, _ ids: [CKRecord.ID]?, _ error: Error?)-> Void) {
                
        let operation = CKModifyRecordsOperation.init(recordsToSave: nil, recordIDsToDelete: IDs)
        operation.savePolicy = .ifServerRecordUnchanged
        operation.queuePriority = .high
        operation.qualityOfService = .userInitiated

        operation.modifyRecordsCompletionBlock = { records, recordIds, error in
            if let error = error {
                complation(false, nil, error)
                return
            }
            complation(true, recordIds, nil)
        }
        database(type).add(operation)
    }
    
}






















