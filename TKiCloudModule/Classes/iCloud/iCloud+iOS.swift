//
//  iCloud+iOS.swift
//  TKiCloudModule
//
//  Created by 🐶 on 2021/11/30.
//

import Foundation
#if os(iOS)

// MARK: SAVE
extension iCloud {
    
    
    
    /// 创建并保存文档
    /// - Parameters:
    ///   - type: document class type
    ///   - nameOrPath: 名称或相对路径
    ///   - content: 内容
    ///   - completion: 回调
    public func save<T:Document>(_ type: T.Type, _ nameOrPath: String, content: T.Value, completion:@escaping (_ document: T?,_ content: T.Value, _ error: Error?)-> Void) where T:_Document {
        let _nameOrPath = verify(string: nameOrPath)
        
        guard !nameOrPath.isEmpty else {
            completion(nil, content, iCloudError.nameOrPathEmpty(path: _nameOrPath))
            return
        }
        guard let cloud = cloud else {
            completion(nil, content, iCloudError.cloudUnusual)
            return
        }
        let fileURL = cloud.appendingPathComponent(_nameOrPath)
        try? self.fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        
        guard !self.fileManager.fileExists(atPath: fileURL.path) else {
            completion(nil, content, iCloudError.fileExits(path: fileURL.path))
            return
        }
        
        queue.async {
            let document = T.init(fileURL: fileURL)
            document.update(content)
            document.updateChangeCount(.done)


            
            try? self.fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)

            document.save(to: fileURL, for: self.fileManager.fileExists(atPath: fileURL.path) ? .forOverwriting : .forCreating) { success in
                if success {
                    
                    document.close { closed in
                        if closed {
                            try? self.fileManager.setUbiquitous(true, itemAt: fileURL, destinationURL: fileURL)
                            completion(document, content, nil)
                            return
                        }
                        
                        completion(nil, content, iCloudError.closeError)
                    }
                    
                }else {
                    completion(nil, content, iCloudError.saveFailed(path: fileURL.path))
                }
            }
        }
    }
    
    
    
    
    /// 保存文件
    /// - Parameters:
    ///   - document: documnet
    ///   - nameOrPath: nameOrPath
    ///   - overwrites: 如果存在时，是否覆盖
    ///   - completion: completion
    public func save(_ document: _Document,_ nameOrPath: String,ifExitoverwrites overwrites:Bool = false, completion: @escaping (_ error: Error?) ->Void) {
        let _nameOrPath = verify(string: nameOrPath)
        
        guard !nameOrPath.isEmpty else {
            completion(iCloudError.nameOrPathEmpty(path: _nameOrPath))
            return
        }
        guard let cloud = cloud else {
            completion(iCloudError.cloudUnusual)
            return
        }
        let fileURL = cloud.appendingPathComponent(_nameOrPath)
        
        if !overwrites {
            guard !self.fileManager.fileExists(atPath: fileURL.path) else {
                completion(iCloudError.fileExits(path: fileURL.path))
                return
            }
        }

        
        try? self.fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        
        
        document.updateChangeCount(.done)
        document.save(to: fileURL, for: self.fileManager.fileExists(atPath: fileURL.path) ? .forOverwriting : .forCreating) { success in
            if success {
                
                document.close { closed in
                    if closed {
                        try? self.fileManager.setUbiquitous(true, itemAt: fileURL, destinationURL: fileURL)
                        completion(nil)
                        return
                    }
                    
                    completion( iCloudError.closeError)
                }
                
            }else {
                completion(iCloudError.saveFailed(path: fileURL.path))
            }
        }
        
        
        
    }
    
    
    
    /// 上传本地文件到远端
    /// - Parameters:
    ///   - type: document class type
    ///   - seat: 保存位置
    ///   - path: other 路径
    public func upload<T: Document>(_ type: T.Type, _ path: URL,_ nameOrPath: String,  completion:(_ error: Error?) -> Void) {
        
        let _nameOrPath = verify(string: nameOrPath)
        
        guard let cloud = cloud else {
            completion(iCloudError.cloudUnusual)
            return
        }
        
        guard !_nameOrPath.isEmpty else {
            completion(iCloudError.nameOrPathEmpty(path: nameOrPath))
            return
        }
        
        
        if !fileManager.fileExists(atPath: path.path) {
            completion(iCloudError.pathNotExits(path: path.path))
            return
        }
        // TODO: 如果开启沙盒
        let localUrl = self.local.appendingPathComponent(_nameOrPath)
        //沙盒中已经存在同名文件
        if localUrl.path != path.path {
            if fileManager.fileExists(atPath: localUrl.path) {
                completion(iCloudError.fileExits(path: localUrl.path))
                return
            }
        }
        
       
        
        let cloudUrl = cloud.appendingPathComponent(_nameOrPath)
        if fileManager.fileExists(atPath: cloudUrl.path) {
            completion(iCloudError.fileExits(path: path.path))
            return
        }
        
        
        do {
            try fileManager.createDirectory(at: localUrl.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            try fileManager.copyItem(at: path, to: localUrl)
            try fileManager.createDirectory(at: cloudUrl.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            try fileManager.setUbiquitous(true, itemAt: localUrl, destinationURL: cloudUrl)
        } catch let error {
            completion(error)
        }
    }
    
}



// MARK: open
extension iCloud {
    
    /// 打开一个文稿
    /// - Parameters:
    ///   - type: document 类型
    ///   - newNameOrPath: 名称
    ///   - create: 不存在时是否创建一个新的
    ///   - completion: 回调
    public func open<T: Document>(_ type:T.Type, document nameOrPath: String, ifNotExitsWith created: Bool, completion:@escaping (_ document: T?, _ error: Error?) -> Void) where T:_Document {
        
        let _nameOrPath = verify(string: nameOrPath)
        
        
        guard let cloud = cloud else {
            completion(nil,iCloudError.cloudUnusual)
            return
        }
        
        guard !nameOrPath.isEmpty else {
            completion(nil,iCloudError.nameOrPathEmpty(path: nameOrPath))
            return
        }
        
        
        var fileURL = URL.init(fileURLWithPath: _nameOrPath)
        if !fileManager.fileExists(atPath: fileURL.path) {
            fileURL = cloud.appendingPathComponent(_nameOrPath)
        }
         
        
        if fileManager.fileExists(atPath: fileURL.path) {

            let document = T.init(fileURL: fileURL)
            document.updateChangeCount(.done)
            completion(document, nil)
            
        }else {
            let document = T.init()
            document.updateChangeCount(.done)
            
            document.save(to: fileURL, for: self.fileManager.fileExists(atPath: fileURL.path) ? .forOverwriting : .forCreating) { success in
                if success {
                    
                    document.close { closed in
                        if closed {
                            try? self.fileManager.setUbiquitous(true, itemAt: fileURL, destinationURL: fileURL)
                            completion(document, nil)
                            return
                        }
                        
                        completion(nil, iCloudError.closeError)
                    }
                    
                }else {
                    completion(nil, iCloudError.saveFailed(path: fileURL.path))
                }
            }
            
        }
        
    }
}


// MARK: rename/copy
extension iCloud {
    /// 重命名
    /// - Parameters:
    ///   - nameOrPath: 名称
    ///   - newNameOrPath: 新的名称
    ///   - completion: completion
    public func rename(document nameOrPath: String, with newNameOrPath: String, completion:(_ error: Error?) -> Void) {
        
        let _nameOrPath = verify(string: nameOrPath)
        let _newNameOrPath = verify(string: newNameOrPath)
      
        guard let cloud = cloud else {
            completion(iCloudError.cloudUnusual)
            return
        }
        
        guard !_nameOrPath.isEmpty else {
            completion(iCloudError.nameOrPathEmpty(path: nameOrPath))
            return
        }
        guard !_newNameOrPath.isEmpty else {
            completion(iCloudError.nameOrPathEmpty(path: newNameOrPath))
            return
        }
        
        let oldUrl = cloud.appendingPathComponent(_nameOrPath)
        let newUrl = cloud.appendingPathComponent(_newNameOrPath)
        
        if !fileManager.fileExists(atPath: oldUrl.path) {
            completion(iCloudError.pathNotExits(path: oldUrl.path))
            return
        }
        
        if fileManager.fileExists(atPath: newUrl.path) {
            completion(iCloudError.fileExits(path: newUrl.path))
            return
        }
        
        
        var writingError: NSError? = nil
        let coordinator = NSFileCoordinator.init(filePresenter: nil)
        coordinator.coordinate(writingItemAt: oldUrl, options: .forMoving, writingItemAt: newUrl, options: .forMoving, error: &writingError) { old, new in
            do {
                try self.fileManager.createDirectory(at: newUrl.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                try self.fileManager.moveItem(at: old, to: new)
                try self.fileManager.setUbiquitous(true, itemAt: new, destinationURL: new)
                completion(nil)
            } catch let error {
                completion(error)
            }
        }
        
        if let error = writingError {
            completion(error)
        }
        
    }
    
    
    /// 文档复制
    /// - Parameters:
    ///   - nameOrPath: name
    ///   - newNameOrPath: newName
    ///   - completion: completion
    public func duplicate(document nameOrPath: String, with newNameOrPath: String, completion:(_ error: Error?) ->Void) {
        
        let _nameOrPath = verify(string: nameOrPath)
        let _newNameOrPath = verify(string: newNameOrPath)
        
        guard let cloud = cloud else {
            completion(iCloudError.cloudUnusual)
            return
        }
        
        guard !_nameOrPath.isEmpty else {
            completion(iCloudError.nameOrPathEmpty(path: _nameOrPath))
            return
        }
        guard !_newNameOrPath.isEmpty else {
            completion(iCloudError.nameOrPathEmpty(path: _newNameOrPath))
            return
        }
        
        let oldUrl = cloud.appendingPathComponent(_nameOrPath)
        let newUrl = cloud.appendingPathComponent(_newNameOrPath)
        
        
        if !fileManager.fileExists(atPath: oldUrl.path) {
             completion(iCloudError.pathNotExits(path: oldUrl.path))
            return
        }
        if fileManager.fileExists(atPath: newUrl.path) {
            completion(iCloudError.fileExits(path: newUrl.path))
            return
        }
        
        do {
            try fileManager.copyItem(at: oldUrl, to: newUrl)
            try fileManager.setUbiquitous(true, itemAt: newUrl, destinationURL: newUrl)
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
}

// MARK: delete
extension iCloud {
    /// 删除文件
    /// - Parameters:
    ///   - type: local。仅删除本地的/ cloud 仅删除云端的， [local，cloud] 同时删除云端和本地的
    ///   - name: 文件名
    ///   - completion: completion
    public func delete(document nameOrPath: String, _ type: SeatOptions, completion:(_ error: Error?) -> Void) {
        let _nameOrPath = verify(string: nameOrPath)
        guard let cloud = cloud else {
            completion(iCloudError.cloudUnusual)
            return
        }
        guard !_nameOrPath.isEmpty else {
            completion(iCloudError.nameOrPathEmpty(path: _nameOrPath))
            return
        }
        
        let cloudUrl = cloud.appendingPathComponent(_nameOrPath)
        let localUrl = local.appendingPathComponent(_nameOrPath)
        
        do {
            switch type {
            case .local:
                if fileManager.fileExists(atPath: localUrl.path) {
                    let fileCoordinator = NSFileCoordinator.init(filePresenter: nil)
                    fileCoordinator.coordinate(writingItemAt: localUrl, options: .forDeleting, error: nil) { url in
                        do {
                            try self.fileManager.removeItem(at: localUrl)
                            try self.fileManager.evictUbiquitousItem(at: cloudUrl)
                            completion(nil)
                        } catch let error  {
                            completion(error)
                        }
                    }
                }else {
                    try self.fileManager.evictUbiquitousItem(at: cloudUrl)
                    completion(nil)
                }
                break
            case .cloud:
                if fileManager.fileExists(atPath: localUrl.path) {
                    completion(iCloudError.fileExits(path: localUrl.path))
                    return
                }
                
                
                try fileManager.startDownloadingUbiquitousItem(at: cloudUrl)
                
                var status: URLUbiquitousItemDownloadingStatus = .notDownloaded
                let startTime = CFAbsoluteTimeGetCurrent()
                var currentTime = CFAbsoluteTimeGetCurrent()
            
                while status != .current || currentTime - startTime != 60 * 2 {
                    status = try cloudUrl.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey]).ubiquitousItemDownloadingStatus ?? .notDownloaded
                    currentTime =  CFAbsoluteTimeGetCurrent()
                }
                
                if status != .current {
                    // 此处err 是等待超时，请稍后再试
                    completion(iCloudError.error(message: "download file fail or timeout."))
                    return
                }
                
                try fileManager.copyItem(at: cloudUrl, to: localUrl)
                
                let fileCoordinator = NSFileCoordinator.init(filePresenter: nil)
                fileCoordinator.coordinate(writingItemAt: cloudUrl, options: .forDeleting, error: nil) { url in
                    do {
                        try self.fileManager.removeItem(at: cloudUrl)
                        completion(nil)
                    } catch let error  {
                        completion(error)
                    }
                }
                break
            case [.local, .cloud]:
                try fileManager.removeItem(at: localUrl)
                try fileManager.removeItem(at: cloudUrl)
                break
            default:
                completion(iCloudError.error(message: "not supoort"))
                break
            }
            
        } catch let error {
            completion(error)
        }

    }
    
    /// 从iCloud中驱逐， 同时会保存副本到本地
    /// - Parameters:
    ///   - name: 文件名称 或者相对path
    ///   - completion: completion
    public func evict<T>(_ document: T.Type,nameOrPath: String, completion:(_ localPath: String?,_ error: Error?) -> Void) where T:_Document {
        
        let _nameOrPath = verify(string: nameOrPath)
        
        guard let cloud = cloud else {
            completion(nil,iCloudError.cloudUnusual)
            return
        }
        guard !_nameOrPath.isEmpty else {
            completion(nil,iCloudError.nameOrPathEmpty(path: _nameOrPath))
            return
        }
        
        let cloudUrl = cloud.appendingPathComponent(_nameOrPath)
        let localUrl = local.appendingPathComponent(_nameOrPath)
        
        
        do {
            if !fileManager.fileExists(atPath: localUrl.path) {
                try fileManager.setUbiquitous(false, itemAt: cloudUrl, destinationURL: localUrl)
                completion(localUrl.path, nil)
            }else {
                
                let localDocument = T.init(fileURL: localUrl)
                let localDate = localDocument.fileModificationDate
                
                let cloudDocument = T.init(fileURL: cloudUrl)
                let cloudDate = cloudDocument.fileModificationDate
                
                guard let localD = localDate, let cloudD = cloudDate else {
                    completion(nil, iCloudError.error(message: "server error"))
                    return
                }
                
                switch localD.compare(cloudD) {
                case .orderedAscending:
                    // local < cloud
                    try fileManager.removeItem(at: localUrl)
                    try fileManager.setUbiquitous(false, itemAt: cloudUrl, destinationURL: localUrl)
                    completion(localUrl.path, nil)
                case .orderedSame:
                    if fileManager.contentsEqual(atPath: localUrl.path, andPath: cloudUrl.path) {
                        try fileManager.removeItem(at: cloudUrl)
                        completion(localUrl.path, nil)
                    }else {
                        // TODO: local 存在同名文件，但是文件内容不相同
                        self.delegate?.cloud(self, conflictBetween: cloudUrl.path, localFile: localUrl.path)
                        completion(nil, iCloudError.conflict(lp: cloudUrl.path, rp: localUrl.path))
                        return
                    }
                    break
                case .orderedDescending:
                    // local > cloud
                    try fileManager.removeItem(at: cloudUrl)
                    completion(localUrl.path, nil)
                    break
                }
                
            }
        } catch let error {
            completion(nil,error)
        }
        
    }
}

// MARK: share
extension iCloud {
    
    /// 分享文件(前提是必须是iCloud中的文件)
    /// - Parameters:
    ///   - name: 文件名
    ///   - completion: completion
    public func share(document nameOrPath: String, completion:(_ shared:URL?, _ expirationDate:Date?,_ error: Error? ) -> Void) {
        
        let _nameOrPath = verify(string: nameOrPath)
        
        guard let cloud = cloud else {
            completion(nil, nil, iCloudError.cloudUnusual)
            return
        }
        
        guard !_nameOrPath.isEmpty else {
            completion(nil, nil, iCloudError.nameOrPathEmpty(path: nameOrPath))
            return
        }
        
        let fileUrl = cloud.appendingPathComponent(_nameOrPath)
        if !fileManager.fileExists(atPath: fileUrl.path) {
             completion(nil, nil,iCloudError.pathNotExits(path: fileUrl.path))
            return
        }
        
        var date: NSDate? = NSDate.init()
        do {
            let url = try fileManager.url(forPublishingUbiquitousItemAt: fileUrl, expiration: &date)
            completion(url, date as Date?, nil)
        } catch let error {
            completion(nil, nil, error)
        }
        
    }
}


// MARK: 冲突处理
extension iCloud {
    /// 指定文档的所有冲突版本
    /// - Parameter nameOrPath: nameOrPath
    /// - Returns: description
    public func unresolvedConflictingVersions(document nameOrPath:String) -> ([NSFileVersion], Error?) {
        
        guard let _ = cloud else {
            return ([], iCloudError.cloudUnusual)
        }
        
        guard !nameOrPath.isEmpty else {
            return ([], iCloudError.nameOrPathEmpty(path: nameOrPath))
        }
        
        let fileUrl = self.ubiquitous.appendingPathComponent(nameOrPath)
        if !fileManager.fileExists(atPath: fileUrl.path) {
            return ([], iCloudError.pathNotExits(path: fileUrl.path))
        }
        var versions: [NSFileVersion] = []
        if let v = NSFileVersion.currentVersionOfItem(at: fileUrl) {
            versions.append(v)
        }
        versions.append(contentsOf: NSFileVersion.otherVersionsOfItem(at: fileUrl) ?? [])
        
        return (versions, nil)
        
        
    }
    /// 解决储存在 iCloud 中的文件的文稿冲突
    /// - Parameters:
    ///   - nameOrPath: nameOrPath
    ///   - version: version
    /// - Returns: description
    public func resolveConflict(document nameOrPath:String, forTargetFile version: NSFileVersion) -> (Bool,Error?) {
        
        
        guard let _ = cloud else {
            return (false, iCloudError.cloudUnusual)
        }
        
        guard !nameOrPath.isEmpty else {
            return (false, iCloudError.nameOrPathEmpty(path: nameOrPath))
        }
        
        let fileUrl = self.ubiquitous.appendingPathComponent(nameOrPath)
        if !fileManager.fileExists(atPath: fileUrl.path) {
            return (false, iCloudError.pathNotExits(path: fileUrl.path))
        }
        
        if let currentVersion = NSFileVersion.currentVersionOfItem(at: fileUrl), currentVersion != version {
            do {
                try version.replaceItem(at: fileUrl, options: .byMoving)
                try NSFileVersion.removeOtherVersionsOfItem(at: fileUrl)
                
                NSFileVersion.unresolvedConflictVersionsOfItem(at:fileUrl)?.forEach({ v in
                    v.isResolved = true
                })

            } catch let error {
                return (false, error)
            }
        }
        
        
        return (false, nil)
        
    }
}

extension iCloud {
    
    /// 将iCloud中文件到出到其他地方
    /// - Parameters:
    ///   - nameOrPath: nameOrPath description
    ///   - path: path description
    ///   - completion: completion description
    public func export(_ nameOrPath: String, path: URL, completion:(_ newUrl: URL?, _ error: Error? ) ->Void) {
        guard let cloud = cloud else {
            completion (nil,iCloudError.cloudUnusual)
            return
        }
        let _nameOrPath = verify(string: nameOrPath)
        
        guard !_nameOrPath.isEmpty else {
            completion (nil, iCloudError.nameOrPathEmpty(path: _nameOrPath))
            return
        }
        
        let cloudUrl = cloud.appendingPathComponent(_nameOrPath)
        if fileManager.fileExists(atPath: cloudUrl.path) && !fileManager.isUbiquitousItem(at: cloudUrl) {
            completion(nil, iCloudError.pathNotExits(path: cloudUrl.path))
            return
        }
        
        
        if fileManager.fileExists(atPath: path.path) {
            completion(nil, iCloudError.fileExits(path: path.path))
            return
        }
        
        
        // TODO: 文件内容
        do {
            var status: URLUbiquitousItemDownloadingStatus = .notDownloaded
            let startTime = CFAbsoluteTimeGetCurrent()
            var currentTime = CFAbsoluteTimeGetCurrent()
        
            while status != .current || currentTime - startTime != 60 * 2 {
                status = try cloudUrl.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey]).ubiquitousItemDownloadingStatus ?? .notDownloaded
                currentTime =  CFAbsoluteTimeGetCurrent()
            }
            
            if status != .current {
                completion(nil, iCloudError.error(message: ""))
                return
            }
            
            try fileManager.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            try fileManager.copyItem(at: cloudUrl, to: path)
            
            completion(path, nil)
            
        } catch let error {
            completion(nil, error)
        }
    }
}


extension iCloud {
    public func async() {
        
        guard let cloud = cloud else {
            return
        }
            
        let locals = localDocumentRelativePath()
        let clouds = cloudDocumentRelativePath()
        
        let intersections = Array(Set.init(locals).subtracting(clouds))
        
        for item in intersections {
            let localUrl = self.local.appendingPathComponent(item)
            let cloudUrl = cloud.appendingPathComponent(item)
            
            do {
                try fileManager.setUbiquitous(true, itemAt: localUrl, destinationURL: cloudUrl)
            } catch let error {
                self.delegate?.cloud(self, syncDocument: localUrl.path, faieldByError: error)
            }
        }
    
        let items = self.cloudDocuments
        for item in items {
            if let status = item.item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? URLUbiquitousItemDownloadingStatus,let url = item.item.value(forAttribute: NSMetadataItemURLKey) as? URL, status == .notDownloaded {
                do {
                    try fileManager.startDownloadingUbiquitousItem(at: url)
                } catch let error {
                    self.delegate?.cloud(self, syncDocument: url.path, faieldByError: error)
                }
            }
        }
        
    }
}

extension iCloud {
    
    private func localDocumentRelativePath() -> [String] {
        
        let localItems = self.fileManager.subpaths(atPath: self.local.path) ?? []
        let items:[String] = localItems.compactMap { string in
            var newString = string.replacingOccurrences(of: local.relativePath, with: "")
            if newString.prefix(1) == "/" {
                newString.removeFirst()
            }
            return newString
        }
        return items
        
    }
    private func cloudDocumentRelativePath() -> [String] {
        
        guard let cloud = cloud else {
            return []
        }
        
        let items:[String] = self.cloudDocuments.compactMap { item in
            
            var string = item.path.replacingOccurrences(of: cloud.relativePath, with: "")
            if string.prefix(1) == "/" {
                string.removeFirst()
            }
            return string
        }
        
        return items
    }
}



#endif
