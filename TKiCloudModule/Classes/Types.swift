//
//  Types.swift
//  TKiCloudModule
//
//  Created by 🐶 on 2021/11/30.
//

import Foundation


#if os(macOS)

public typealias _Document = NSDocument

#else


public typealias _Document = UIDocument


#endif
