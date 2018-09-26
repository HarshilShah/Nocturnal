//
//  AppDelegate.swift
//  NightTime
//
//  Created by Harshil Shah on 25/09/18.
//  Copyright © 2018 Harshil Shah. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }()
    
    private lazy var menu: NSMenu = {
        let menu = NSMenu()
        menu.addItem(withTitle: "Quit NightTime",
                     action: #selector(NSApplication.terminate),
                     keyEquivalent: "q")
        return menu
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.target = self
        statusItem.button?.action = #selector(itemWasClicked(_:))
        statusItem.button?.sendAction(on: [.leftMouseDown, .rightMouseUp])
        statusItem.button?.image = NSImage(named: NSImage.Name("MenuBarIcon"))
    }
    
    @objc private func itemWasClicked(_: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            return
        }
        
        if event.type == .rightMouseUp || event.modifierFlags.contains(.option) {
            toggleTheme()
        } else {
            showMenu()
        }
    }
    
    private func showMenu() {
        statusItem.menu = menu
        statusItem.popUpMenu(menu)
        statusItem.menu = nil
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
