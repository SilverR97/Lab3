//
//  PolarSensorModel.swift
//  PolarSDK
//
//  Created by Reinaldo Plata P on 12/1/24.
//

import Foundation
import PolarBleSdk
import Combine
import RxSwift

class PolarSensorModel: PolarBleApiObserver {
    
    // Cambia 'let' a 'var' para que sea mutable
    private var api = PolarBleApiDefaultImpl.polarImplementation(DispatchQueue.main, features: [.feature_polar_online_streaming])
    public let deviceId: String
    private let disposeBag = DisposeBag()
    
    private let sensorDataSubject = PassthroughSubject<SensorDataBlu, Never>()
    var sensorDataPublisher: AnyPublisher<SensorDataBlu, Never> {
        sensorDataSubject.eraseToAnyPublisher()
    }
    
    @Published var accelerometerHistory: [(Date, Double, Double, Double)] = []
    @Published var gyroscopeHistory: [(Date, Double, Double, Double)] = []
    
    init(deviceId: String) {
            self.deviceId = deviceId
            self.api = PolarBleApiDefaultImpl.polarImplementation(DispatchQueue.main, features: [.feature_polar_sdk_mode])
            self.api.observer = self
    }
    
    func deviceConnected(_ identifier: PolarBleSdk.PolarDeviceInfo) {
        print("device connected called: \(identifier.deviceId)")
    }
    
    func startStreaming() {
        do {
            try api.connectToDevice(deviceId)
            print("startStreaming: called")
            requestStreamSettings()
        } catch {
            print("Error al conectar al dispositivo: \(error)")
        }
    }
    
    // Implementación de los métodos requeridos por PolarBleApiObserver
    func deviceConnecting(_ polarDeviceInfo: PolarDeviceInfo) {
        print("Dispositivo conectándose: \(polarDeviceInfo.deviceId)")
    }

    private func requestStreamSettings() {
        api.requestStreamSettings(deviceId, feature: .acc)
            .subscribe(
                onSuccess: { [weak self] settings in
                    print("Configuraciones del acelerómetro recibidas: \(settings)")
                    self?.startAccStream(with: settings)
                },
                onFailure: { error in
                    print("Error al solicitar configuraciones del acelerómetro: \(error)")
                }
            )
            .disposed(by: disposeBag)
        
        api.requestStreamSettings(deviceId, feature: .gyro)
            .subscribe(
                onSuccess: { [weak self] settings in
                    print("Configuraciones del giroscopio recibidas: \(settings)")
                    self?.startGyroStream(with: settings)
                },
                onFailure: { error in
                    print("Error al solicitar configuraciones del giroscopio: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }
        
    private func startAccStream(with settings: PolarSensorSetting) {
        api.startAccStreaming(deviceId, settings: settings)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] data in
                    guard let sample = data.samples.last else { return }
                    let accData = (Double(sample.x), Double(sample.y), Double(sample.z))
                    self?.updateSensorData(acc: accData)
                },
                onError: { error in
                    print("Error en la transmisión del acelerómetro: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }
        
    private func startGyroStream(with settings: PolarSensorSetting) {
        api.startGyroStreaming(deviceId, settings: settings)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] data in
                    guard let sample = data.samples.last else { return }
                    let gyroData = (Double(sample.x), Double(sample.y), Double(sample.z))
                    self?.updateSensorData(gyro: gyroData)
                },
                onError: { error in
                    print("Error en la transmisión del giroscopio: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }
        
    private func updateSensorData(acc: (Double, Double, Double)? = nil, gyro: (Double, Double, Double)? = nil) {
        var currentData = SensorDataBlu(accelerometer: (0, 0, 0), gyroscope: (0, 0, 0))
        
        if let acc = acc {
            currentData.accelerometer = acc
            print("Nuevos datos del acelerómetro: \(acc)")
        }
        
        if let gyro = gyro {
            currentData.gyroscope = gyro
            print("Nuevos datos del giroscopio: \(gyro)")
        }
        
        sensorDataSubject.send(currentData)
    }
    
    private func saveData(_ data: SensorDataBlu) {
        // Implementa aquí la lógica para guardar los datos en un archivo.
    }

    
    
    func deviceDisconnected(_ polarDeviceInfo: PolarDeviceInfo) {
        print("Dispositivo desconectado: \(polarDeviceInfo.deviceId)")
    }

    func deviceDisconnected(_ identifier: PolarDeviceInfo, pairingError: Bool) {
        print("Dispositivo desconectado: \(identifier.deviceId), error de emparejamiento: \(pairingError)")
    }
    
    func blePowerOn() {
        print("Bluetooth encendido")
    }
    
    func blePowerOff() {
        print("Bluetooth apagado")
    }
    
    func stopStream() {
        do{
            try api.disconnectFromDevice(deviceId)
            print("Device disconnected")
        } catch {
            print("Error disconnecting device: \(error)")
        }
    }
}

struct SensorDataBlu {
    var accelerometer: (x: Double, y: Double, z: Double)
    var gyroscope: (x: Double, y: Double, z: Double)
}
