//
//  AppDelegate.swift
//  Nocturnal
//
//  Created by Harshil Shah on 25/09/18.
//  Copyright © 2018 Harshil Shah. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private let sunriseManager: SunriseManager = SunriseManager()
    private var sunTimers: (Timer?, Timer?) = (nil, nil)
    private var dailyTimer: Timer!
    private lazy var followSun: Bool = UserDefaults.standard.bool(forKey: "ToggleWithSunset")
    
    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }()
    
    private lazy var menu: NSMenu = {
        let menu = NSMenu()
        menu.addItem(withTitle: "Toggle with Sunset",
                     action: #selector(toggleFollowSun),
                     keyEquivalent: "t")
        menu.addItem(withTitle: "Quit",
                     action: #selector(NSApplication.terminate),
                     keyEquivalent: "q")
        menu.items.first?.state = followSun ? .on : .off
        return menu
    }()
    
    @objc private func toggleFollowSun() {
        followSun = !followSun
        UserDefaults.standard.set(followSun, forKey: "ToggleWithSunset")
        menu.items.first?.state = followSun ? .on : .off
        updateFollowingSun()
    }
    
    private func updateFollowingSun() {
        guard followSun else { return }
        sunriseManager.start(handler: sunriseAndSunsetChanged)
        dailyTimer = Timer(timeInterval: 86400, repeats: true) { (_) in
            self.sunriseAndSunsetChanged(sunrise: self.sunriseManager.sunriseDate,
                                         sunset: self.sunriseManager.sunsetDate)
        }
        RunLoop.main.add(dailyTimer, forMode: .common)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.target = self
        statusItem.button?.action = #selector(itemWasClicked(_:))
        statusItem.button?.sendAction(on: [.leftMouseDown, .rightMouseUp])
        statusItem.button?.image = NSImage(named: NSImage.Name("MenuBarIcon"))
        
        self.updateFollowingSun()
    }
    
    private func sunriseAndSunsetChanged(sunrise: Date?, sunset: Date?) {
        guard let sunrise = sunrise, let sunset = sunset else { return }
        
        sunTimers.0?.invalidate()
        sunTimers.1?.invalidate()
        
        let sunriseTimer = Timer(fire: sunrise, interval: 0, repeats: false) { (timer) in
            self.toggleTheme(on: false)
        }
        
        let sunsetTimer = Timer(fire: sunset, interval: 0, repeats: false) { (timer) in
            self.toggleTheme(on: true)
        }
        
        [sunriseTimer, sunsetTimer].forEach { RunLoop.main.add($0, forMode: .common) }
        sunTimers = (sunriseTimer, sunsetTimer)
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
    
    private func toggleTheme(on: Bool? = nil) {
        let value: String
        if let on = on {
            value = on ? "true" : "false"
        } else {
            value = "not dark mode"
        }
        
        let script = """
        tell application "System Events"
            tell appearance preferences
                set dark mode to \(value)
            end tell
        end tell
        """
        
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }

}
