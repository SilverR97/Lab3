//
//  PolarVM.swift
//  PolarSDK
//
//  Created by Reinaldo Plata P on 11/29/24.
//
import Foundation
import Combine

class SensorViewModel: ObservableObject {
    @Published var accelerometerDataBlu: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var gyroscopeDataBlu: (x: Double, y: Double, z: Double) = (0, 0, 0)
    
    private let model: PolarSensorModel
    private var cancellables = Set<AnyCancellable>()
    
    var deviceId: String {
            model.deviceId
        }
    init(deviceId: String) {
        model = PolarSensorModel(deviceId: deviceId)
        
        model.sensorDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sensorData in
                print("Received new sensor data")
                self?.accelerometerDataBlu = sensorData.accelerometer
                self?.gyroscopeDataBlu = sensorData.gyroscope
                print("Updated ViewModel - Acc: \(self?.accelerometerDataBlu), Gyro: \(self?.gyroscopeDataBlu)")
            }
            .store(in: &cancellables)
        
    }
    
    func startStreaming() {
        model.startStreaming()
    }
    
    func stopStreaming() {
        model.stopStream()
    }
}
