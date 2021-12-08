//
//  Extensions.swift
//  Pods
//
//  Created by 🐶 on 2021/12/8.
//

import Foundation

extension Mirror {
    func typeOfProperty(_ name: String) -> Any.Type {
        var mirror = self
        for child in mirror.children {
            if child.label! == name {
                return  type(of: child.value)
            }
        }
        while let parent = mirror.superclassMirror {
            for child in parent.children {
                if child.label! == name {
                    return type(of: child.value)
                }
            }
            mirror = parent
        }
        return NSNull.Type.self
    }
}

func propertyList<T>(entity:T) -> [(name:String, type:Any.Type,value:Any)] {
    let mirror = Mirror.init(reflecting: entity)
    var array = [(name:String, type:Any.Type,value:Any)]()
    for case let (label?, anyValue) in mirror.children {
        let type = mirror.typeOfProperty(label)
        array.append((name: label, type:type,value:anyValue))
    }
    return array
}

#if os(macOS)

extension NSImage {
    var cgImage: CGImage? {
        guard let imageData = self.tiffRepresentation else { return nil }
        guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
    }
}

extension NSImage {
    var ciImage: CIImage? {
        guard let imageData = self.tiffRepresentation else { return nil }
        return CIImage(data: imageData)
    }
}

extension CGImage {
    var nsImage: NSImage? {
        let size = CGSize(width: self.width, height: self.height)
        return NSImage(cgImage: self, size: size)
    }
}

extension CGImage {
    var ciImage: CIImage {
        return CIImage(cgImage: self)
    }
}
extension CIImage {
    var nsImage: NSImage {
        let rep = NSCIImageRep(ciImage: self)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}

extension CIImage {
    var cgImage: CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(self, from: self.extent)
    }
}

#endif
