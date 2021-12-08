//
//  iCloudType.swift
//  Pods
//
//  Created by 🐶 on 2021/12/8.
//

import Foundation


#if os(macOS)

public typealias _Document = NSDocument

#else


public typealias _Document = UIDocument


#endif
