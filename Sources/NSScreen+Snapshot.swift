//
//  NSScreen+Snapshot.swift
//  Nocturnal
//
//  Created by Harshil Shah on 06/11/18.
//  Copyright © 2018 Harshil Shah. All rights reserved.
//

import Cocoa

extension NSScreen {
    
    func snapshot() -> NSImage {
        guard let cgImage = CGWindowListCreateImage(frame, .optionOnScreenOnly, kCGNullWindowID, .bestResolution) else {
            fatalError("Couldn't take a snapshot")
        }
        
        let bitmapRepresentation = NSBitmapImageRep(cgImage: cgImage)
        let image = NSImage()
        image.addRepresentation(bitmapRepresentation)
        return image
    }
    
}
