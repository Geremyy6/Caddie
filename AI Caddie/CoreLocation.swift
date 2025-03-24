//
//  CoreLocation.swift
//  AI Caddie
//
//  Created by GermanRamosGarcia on 24.03.2025.
//

import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var shots: [Shot] = []
    @Published var lastDistance: Double = 0.0
    @Published var suggestedClub: String = ""
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
    
    func registerShot() {
        guard let currentLocation = userLocation else { return }
        if let lastShot = shots.last {
            let distance = calculateDistance(from: lastShot.coordinate, to: currentLocation)
            lastDistance = distance
           // suggestedClub = suggestClub(for: distance)
        }
        shots.append(Shot(coordinate: currentLocation))
    }
    
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    /*func suggestClub(for distance: Double) -> String {
        // Load saved club distances from AppStorage
        guard let clubData = UserDefaults.standard.string(forKey: "clubData"),
              let decodedData = clubData.data(using: .utf8),
              let clubDistances = try? JSONDecoder().decode([String: String].self, from: decodedData) else {
            return "Club data not available"
        }
        
        // Convert user-defined distances to a sorted array
        let sortedClubs = clubDistances.compactMap { key, value -> (String, Double)? in
            if let dist = Double(value) {
                return (key, dist)
            }
            return nil
        }
        .sorted { $0.1 > $1.1 } // Sort clubs from longest to shortest distance
        
        // Find the best club for the given distance
        for (club, clubDistance) in sortedClubs {
            if distance >= clubDistance {
                return club
            }
        }
        
        return sortedClubs.last?.0 ?? "Driver" // Default to longest club if nothing matches
    }*/
}

struct Shot: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

