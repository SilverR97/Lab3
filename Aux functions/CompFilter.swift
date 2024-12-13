//
//  CompFilter.swift
//  PolarSDK
//
//  Created by Reinaldo Plata P on 12/11/24.
//

import Foundation

class ComplementaryFilter{
    
    private var lastUpdateTime: TimeInterval = Date().timeIntervalSince1970
    private var gyroPitch: Double = 0.0
    private var gyroRoll: Double = 0.0
    private let alpha: Double // Filter coefficient, typically between 0.90 and 0.98
    
    init(alpha: Double = 0.98) {
            self.alpha = alpha
    }
    
    func CompFilter(accelData: SensorData, gyroData: SensorData) -> AngleData{
        let currentTime = Date().timeIntervalSince1970
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        // angles of accelerometer
        let accelPitch = atan2(accelData.y, sqrt(accelData.x * accelData.x + accelData.z * accelData.z)) * (180 / .pi) * (180 / .pi)
        let accelRoll = atan2(-accelData.x, sqrt(accelData.y * accelData.y + accelData.z * accelData.z)) * (180 / .pi) * (180 / .pi)
        
        gyroPitch += gyroData.y * dt
        gyroRoll += gyroData.x * dt
        
        // Apply complementary filter formula
        let filteredPitch = alpha * gyroPitch + (1 - alpha) * accelPitch
        let filteredRoll = alpha * gyroRoll + (1 - alpha) * accelRoll
        return AngleData(pitch: filteredPitch, roll: filteredRoll)
    }
    
    
}
