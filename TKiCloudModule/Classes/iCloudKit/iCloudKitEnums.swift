//
//  iCloudKitEnums.swift
//  Pods
//
//  Created by 🐶 on 2021/12/8.
//


import Foundation
import CloudKit



public enum CKDataBaseType {
    case `public`
    case `private`
    case shared

    
    var scope: CKDatabase.Scope {
        switch self {
        case .shared:
            return .shared
        case .private:
            return .private
        case .public:
            return .public
        }
    }
}




public enum iCloudKitError: Error {
    case notSupportType(type: CKDataBaseType)
    case notSupportSave(value: Any)
    case notSupportDelate(value: Any)
    case conversionError(value: Any)
    case notShared
}


extension iCloudKitError: CustomDebugStringConvertible {
    public var debugDescription: String {
        return descString()
    }
}

extension iCloudKitError: CustomStringConvertible {
    public var description: String {
        return descString()
    }
}

extension iCloudKitError {
    private func descString() -> String {
        switch self {
        default:
            break
        }
        return ""
    }
}
