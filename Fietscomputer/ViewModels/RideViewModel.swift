//
//  RideViewModel.swift
//  Fietscomputer
//
//  Created by Grigory Avdyushin on 19/06/2020.
//  Copyright © 2020 Grigory Avdyushin. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class RideViewModel {

    let ride: Ride

    var uuid: UUID
    var date: String
    var title: String

    var distance: String
    var duration: String
    var avgSpeed: String
    var maxSpeed: String
    var elevationGain: String
    var power: String
    var energy: String
    var weightLoss: String

    lazy var locations: [CLLocation] = {
        self.ride.locations()
    }()

    let elevationGainValue: CLLocationDistance
    lazy var elevations: [CLLocationDistance] = {
        self.locations.map { $0.altitude }
    }()

    let avgSpeedValue: CLLocationSpeed
    lazy var speed: [CLLocationDistance] = {
        self.locations.map { $0.speed }
    }()

    let distanceLabel = Strings.distance
    let durationLabel = Strings.duration
    let avgSpeedLabel = Strings.avg_speed
    let maxSpeedLabel = Strings.max_speed
    let elevGainLabel = Strings.elevation_gain
    let powerLabel = Strings.avg_power
    let energyLabel = Strings.energy_output
    let weightLossLabel = Strings.weight_loss
    let mapRegion: MKCoordinateRegion

    var mapSize: CGSize { CGSize(width: 120*3, height: 80*3) }

    init(ride: Ride) {
        self.ride = ride
        self.uuid = ride.id!
        date = Self.date(ride.createdAt)
        title = ride.name ?? Strings.unnamed_ride
        let summary = ride.asRideSummary()
        distance = Self.distance(summary.distance)
        duration = Self.duration(summary.duration)
        avgSpeedValue = summary.avgSpeed
        let avgSpeedPair = Self.speed(summary.avgSpeed)
        avgSpeed = avgSpeedPair.value + " " + avgSpeedPair.units
        let maxSpeedPair = Self.speed(summary.maxSpeed)
        maxSpeed = maxSpeedPair.value + " " + maxSpeedPair.units
        elevationGainValue = summary.elevationGain
        elevationGain = Self.elevation(summary.elevationGain)
        let powerPair = Self.power(power: summary.avgSpeed)
        power = powerPair.value + " " + powerPair.units
        let energyPair = Self.energy(power: summary.avgPower, duration: summary.duration)
        energy = energyPair.value + " " + energyPair.units
        let weightPair = Self.weight(power: summary.avgPower, duration: summary.duration)
        weightLoss = weightPair.value + " " + weightPair.units
        mapRegion = ride.track?.region?.asMKCoordinateRegion(scale: (1.2, 1.2)) ?? MKCoordinateRegion()
    }

    func mapProcessor() -> MapSnapshotProcessor {
        RideTrackDrawer({ [unowned self] in self.locations })
    }

    static func date(_ value: Date?) -> String {
        guard let value = value else { return "" }
        let date = Formatters.relativeDateFormatter.localizedString(fromTimeInterval: value.timeIntervalSinceNow)
        if value.timeIntervalSinceNow > -60*60*24 {
            return date
        } else {
            let time = Formatters.timeFormatter.string(from: value)
            return [date, Strings.at, time].joined(separator: " ")
        }
    }

    static func elevation(_ value: Double?) -> String {
        Formatters.distanceFormatter.string(from: Measurement(value: value ?? 0, unit: UnitLength.meters))
    }

    static func distance(_ value: Double?) -> String {
        let kilometres = Measurement(value: value ?? 0, unit: UnitLength.meters).converted(to: .kilometers)
        return Formatters.distanceFormatter.string(from: kilometres)
    }

    static func duration(_ value: Double?) -> String {
        Formatters.elapsedFormatter.string(from: value ?? 0)!
    }

    static func speed(_ value: Double?) -> ValueUnitPair {
        let mps = Measurement(value: value ?? 0, unit: UnitSpeed.metersPerSecond)
        let kph = mps.converted(to: UnitSpeed.kilometersPerHour)
        return Formatters.formatted(from: kph)
    }

    static func power(power: Double) -> ValueUnitPair {
        let watt = Measurement(value: power, unit: UnitPower.watts)
        return Formatters.formatted(from: watt)
    }

    static func energy(power: Double, duration: Double) -> ValueUnitPair {
        let kilojoule = Energy.energy(
            power: Measurement(value: power, unit: .watts),
            duration: Measurement(value: duration, unit: .seconds)
        )
        let kcal = kilojoule.converted(to: .kilocalories)
        return Formatters.formatted(from: kcal)
    }

    static func weight(power: Double, duration: Double) -> ValueUnitPair {
        let kilojoule = Energy.energy(
            power: Measurement(value: power, unit: .watts),
            duration: Measurement(value: duration, unit: .seconds)
        )
        let kilograms = Weight.loss(energy: kilojoule)
        return Formatters.formatted(from: kilograms)
    }
}
