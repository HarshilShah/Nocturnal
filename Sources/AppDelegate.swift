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
    
    private var overlays: [NSWindow] = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.isVisible = true
        statusItem.behavior = [.removalAllowed, .terminationOnRemoval]
        statusItem.button?.target = self
        statusItem.button?.action = #selector(itemWasClicked(_:))
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusItem.button?.image = NSImage(named: NSImage.Name("MenuBarIcon"))
    }
    
    @objc private func itemWasClicked(_: NSStatusBarButton) {
        setupOverlays()
        toggleTheme()
        fadeOutOverlays()
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
    
    private func setupOverlays() {
        overlays = NSScreen.screens.map { screen in
            let imageView = NSImageView(image: screen.snapshot())
            let overlay = NSWindow(contentRect: screen.frame,
                                   styleMask: .borderless,
                                   backing: .buffered,
                                   defer: false,
                                   screen: screen)
            overlay.isReleasedWhenClosed = false
            overlay.level = .screenSaver
            overlay.contentView = imageView
            overlay.makeKeyAndOrderFront(nil)
            return overlay
        }
    }
    
    private func fadeOutOverlays() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.4
                self.overlays.forEach {
                    $0.animator().alphaValue = 0
                }
            }, completionHandler: {
                self.overlays.forEach {
                    $0.resignKey()
                    $0.close()
                }
                self.overlays.removeAll()
            })
        }
    }
    
}
