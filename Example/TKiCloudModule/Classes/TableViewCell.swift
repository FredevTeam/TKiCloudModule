//
//  TableViewCell.swift
//  TKiCloudModule_Example
//
//  Created by 🐶 on 2021/12/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Cocoa
import PLExtensionsModule
import SnapKit

class TableViewCell : NSView {
    // TODO: UI
    let titleLabel = CocoaLabel.init()
    let parentPathLabel = CocoaLabel.init()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        installSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension TableViewCell {
    private func installSubviews() {
        
        titleLabel.backgroundColor = NSColor.green
        titleLabel.textColor = NSColor.white
        addSubview(titleLabel)
        parentPathLabel.maximumNumberOfLines = 20
        parentPathLabel.backgroundColor = NSColor.magenta
        parentPathLabel.textColor = NSColor.white
        addSubview(parentPathLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        parentPathLabel.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
        }

    }
}
