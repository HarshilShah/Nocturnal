//
//  SunriseManager.swift
//  Nocturnal
//
//  Created by Patrick Perini on 9/26/18.
//  Copyright © 2018 Harshil Shah. All rights reserved.
//

import CoreLocation

class SunriseManager: NSObject {
    let locationManager: CLLocationManager
    private(set) var location: CLLocation? = nil
    private var solarInfoDidChange: ((Date?, Date?) -> Void)?
    
    private var solarInfo: Solar? {
        guard let location = self.location else { return nil }
        return Solar(coordinate: location.coordinate)
    }
    
    var sunriseDate: Date? { return self.solarInfo?.sunrise }
    var sunsetDate: Date? { return self.solarInfo?.sunset }
    var isNight: Bool? { return self.solarInfo?.isNighttime }
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func start(handler: @escaping (Date?, Date?) -> Void) {
        self.solarInfoDidChange = handler
        self.locationManager.startUpdatingLocation()
    }
    
    func stop() {
        self.locationManager.stopUpdatingLocation()
    }
}

extension SunriseManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.max(by: { $0.accuracy > $1.accuracy })
        self.solarInfoDidChange?(self.sunriseDate, self.sunsetDate)
    }
}

extension CLLocation {
    var accuracy: CLLocationAccuracy {
        guard self.horizontalAccuracy > 0 && self.verticalAccuracy > 0 else { return CLLocationAccuracy(Int.max) }
        return (self.horizontalAccuracy * self.verticalAccuracy) / 2.0
    }
}
