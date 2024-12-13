//
//  Untitled.swift
//  PolarSDK
//
//  Created by Reinaldo Plata P on 12/11/24.
//
import Foundation

class MainModel {
    private var pitchFilter = EMWAFilter(alpha: 0.1)
    private var rollFilter = EMWAFilter(alpha: 0.1)
    private var complementaryFilter = ComplementaryFilter(alpha: 0.98)
    
    @Published var filteredPitch: Double = 0.0
    @Published var filteredRoll: Double = 0.0
    
    @Published var compFilteredPitch: Double = 0.0
    @Published var compFilteredRoll: Double = 0.0
    
    @Published var rawPitch: Double = 0.0
    @Published var rawRoll: Double = 0.0

    func processSensorData(_ data: SensorData, accelData: SensorData, gyroData: SensorData) -> AngleDataPair{
        let rawAngles = calculateAngles(from: data)
        // Emwa filtering
        let filteredPitch = pitchFilter.filter(newValue: rawAngles.pitch)
        let filteredRoll = rollFilter.filter(newValue: rawAngles.roll)
        // Complmentary filter
        let complementaryAngles = complementaryFilter.CompFilter(accelData: accelData, gyroData: gyroData)
            // Update filtered values
        DispatchQueue.main.async {
            self.rawPitch = rawAngles.pitch
            self.rawRoll = rawAngles.roll
            self.filteredPitch = filteredPitch
            self.filteredRoll = filteredRoll
            self.compFilteredPitch = complementaryAngles.pitch
            self.compFilteredRoll = complementaryAngles.roll
        }
        return AngleDataPair(emwaFilteredAngles: AngleData(pitch: filteredPitch, roll: filteredRoll), compFilteredAngles: AngleData(pitch:compFilteredPitch, roll: compFilteredRoll))
        }

    private func calculateAngles(from data: SensorData) -> AngleData {
        let pitch = atan2(data.y, sqrt(data.x * data.x + data.z * data.z)) * 180 / .pi
        let roll = atan2(-data.x, sqrt(data.y * data.y + data.z * data.z)) * 180 / .pi
        return AngleData(pitch: pitch, roll: roll)
    }
}
