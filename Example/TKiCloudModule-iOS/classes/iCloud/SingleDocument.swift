//
//  SingleDocument.swift
//  TKiCloudModule-iOS
//
//  Created by 🐶 on 2021/12/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import TKiCloudModule

class SingleDocument: UIDocument , Document {
    var content: String = ""
    
    func update(_ content: String) {
        self.content = content
    }
    
    typealias Value = String
    
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        self.content = String.init(data: contents as! Data, encoding: .utf8) ?? ""
    }
    
    override func contents(forType typeName: String) throws -> Any {
        return self.content.data(using: .utf8) ?? Data.init()
    }
}
