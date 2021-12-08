//
//  iCloud+Errors.swift
//  TKiCloudModule
//
//  Created by 🐶 on 2021/12/1.
//

import Foundation

public enum iCloudError: Error {
    case nameOrPathEmpty(path: String)
    case pathNotExits(path: String)
    case saveFailed(path: String)
    case closeError
    case fileExits(path: String)
    case cloudUnusual
    case error(message: String)
    case conflict(lft: String, rft: String)
}



extension iCloudError: CustomDebugStringConvertible {
    public var debugDescription: String {
        return descString()
    }
}

extension iCloudError: CustomStringConvertible {
    public var description: String {
        return descString()
    }
}

extension iCloudError {
    private func descString() -> String {
        switch self {
        case .nameOrPathEmpty(let path):
            return " \(path) is empty "
            case .pathNotExits(path: let path):
                return "\(path) file or dir is not exits"
            case .saveFailed(path: let path):
                return "\(path) save Failed"
            case .closeError:
                return  "document close error"
            case .fileExits(path: let path):
                return "\(path) file exits"
            case .cloudUnusual:
                return "cloud is not support"
            case .error:
                return "server error"
            case .conflict:
                return "file conflict"
        }
        return ""
    }
}
