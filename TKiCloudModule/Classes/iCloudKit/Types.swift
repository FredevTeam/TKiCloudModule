//
//  Types.swift
//  TKiCloudModule
//
//  Created by 🐶 on 2021/11/30.
//

import Foundation



#if os(macOS)

public typealias Image  = NSImage

#else

import UIKit

public typealias Image = UIImage


#endif
