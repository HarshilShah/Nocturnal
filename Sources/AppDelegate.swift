//
//  AppDelegate.swift
//  Nocturnal
//
//  Created by Harshil Shah on 25/09/18.
//  Copyright © 2018 Harshil Shah. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.behavior = .terminationOnRemoval
        statusItem.button?.target = self
        statusItem.button?.action = #selector(itemWasClicked(_:))
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusItem.button?.image = NSImage(named: NSImage.Name("MenuBarIcon"))
    }
    
    @objc private func itemWasClicked(_: NSStatusBarButton) {
        toggleTheme()
    }
    
    private func toggleTheme() {
        let script = """
        tell application "System Events"
            tell appearance preferences
                set dark mode to not dark mode
            end tell
        end tell
        """
        
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }
    
}
