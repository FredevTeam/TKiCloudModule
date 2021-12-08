//
//  CocoaDocument.swift
//  TKiCloudModule-iOS
//
//  Created by 🐶 on 2021/12/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import TKiCloudModule


class CocoaDocument: NSDocument {
    var content: String = ""
    
    func update(_ content: String) {
        self.content = content
    }
    
    typealias Value = String
    
    
    override func data(ofType typeName: String) throws -> Data {
        return content.data(using: .utf8) ?? Data.init()
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        self.content = String.init(data: data, encoding: .utf8) ?? ""
    }
}


extension CocoaDocument:Document {
    
}
