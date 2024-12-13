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
    
    @Published var filteredAngles: AngleData = AngleData(pitch: 0.0, roll: 0.0)
    @Published var compFilteredAngles: AngleData = AngleData(pitch: 0.0, roll: 0.0)
    
    @Published var accelerometerHistory: [(String, Double)] = []
    @Published var gyroscopeHistory: [(String, Double)] = []
    @Published var angleHistory: [(Date, Double, Double)] = []
    @Published var compAngleHistory: [(Date, Double, Double)] = []
    
    @Published var isCollecting: Bool = false
    
    private let model: PolarSensorModel
    private let mainModel = MainModel()
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
                
                // Update history with the new raw data
                self?.updateHistory(with: sensorData)
                
                // Process angles and update angle history
                self?.processAngles(from: sensorData)
                
                // Log history updates
                print("Updated History - Angle History: \(self?.angleHistory.count ?? 0) entries, Comp Angle History: \(self?.compAngleHistory.count ?? 0) entries")
            }
            .store(in: &cancellables)
    }
    
    func startStreaming() {
        model.startStreaming()
        isCollecting = true
    }
    
    func stopStreaming() {
        model.stopStream()
        isCollecting = false
        // Optionally, you can process data after stopping
        processData()
    }
    
    func saveData() {
        let sensorData = SensorDataBlu(
            accelerometer: accelerometerDataBlu,
            gyroscope: gyroscopeDataBlu
        )
        model.saveData(sensorData)
    }
    
    // Update history with new accelerometer and gyroscope data
    private func updateHistory(with data: SensorDataBlu) {
        // Update accelerometer and gyroscope history with new data
        accelerometerHistory.append(("X", data.accelerometer.x))
        accelerometerHistory.append(("Y", data.accelerometer.y))
        accelerometerHistory.append(("Z", data.accelerometer.z))
        
        gyroscopeHistory.append(("X", data.gyroscope.x))
        gyroscopeHistory.append(("Y", data.gyroscope.y))
        gyroscopeHistory.append(("Z", data.gyroscope.z))
        
        // Limit history size (optional)
        if accelerometerHistory.count > 300 { accelerometerHistory.removeFirst(3) }
        if gyroscopeHistory.count > 300 { gyroscopeHistory.removeFirst(3) }
    }
    
    // Process angles using MainModel
    private func processAngles(from data: SensorDataBlu) {
        let accelData = SensorData(x: data.accelerometer.x, y: data.accelerometer.y, z: data.accelerometer.z)
        let gyroData = SensorData(x: data.gyroscope.x, y: data.gyroscope.y, z: data.gyroscope.z)
        
        // Process angles using the MainModel
        let angleDataPair = mainModel.processSensorData(accelData, accelData: accelData, gyroData: gyroData)
        
        // Update filtered angles and histories
        self.filteredAngles = angleDataPair.emwaFilteredAngles
        self.updateAngleHistory(with: angleDataPair.emwaFilteredAngles)
        
        self.compFilteredAngles = angleDataPair.compFilteredAngles
        self.updateCompAngleHistory(with: angleDataPair.compFilteredAngles)
        
        print("Processed angles - EMWA: \(angleDataPair.emwaFilteredAngles), Complementary: \(angleDataPair.compFilteredAngles)")
    }
    
    // Store angles with timestamps
    private func updateAngleHistory(with angles: AngleData) {
        angleHistory.append((Date(), angles.pitch, angles.roll))
        if angleHistory.count > 300 {
            angleHistory.removeFirst()
        }
    }
    
    // Store complementary angles with timestamps
    private func updateCompAngleHistory(with angles: AngleData) {
        compAngleHistory.append((Date(), angles.pitch, angles.roll))
        if compAngleHistory.count > 300 {
            compAngleHistory.removeFirst()
        }
    }
    
    // Process data manually when needed
    func processData() {
        let accelData = SensorData(x: accelerometerDataBlu.x, y: accelerometerDataBlu.y, z: accelerometerDataBlu.z)
        let gyroData = SensorData(x: gyroscopeDataBlu.x, y: gyroscopeDataBlu.y, z: gyroscopeDataBlu.z)
        
        // Process angles using MainModel
        let angleDataPair = mainModel.processSensorData(accelData, accelData: accelData, gyroData: gyroData)
        
        // Update filtered angles and histories
        self.filteredAngles = angleDataPair.emwaFilteredAngles
        self.updateAngleHistory(with: angleDataPair.emwaFilteredAngles)
        
        self.compFilteredAngles = angleDataPair.compFilteredAngles
        self.updateCompAngleHistory(with: angleDataPair.compFilteredAngles)
    }

     
    /*
    @Published var accelerometerDataBlu: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var gyroscopeDataBlu: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var filteredAngles: AngleData = AngleData(pitch: 0.0, roll: 0.0)
    @Published var compFilteredAngles: AngleData = AngleData(pitch: 0.0, roll: 0.0)
    
    @Published var accelerometerHistory: [(String, Double)] = []
    @Published var gyroscopeHistory: [(String, Double)] = []
    @Published var angleHistory: [(Date, Double, Double)] = []
    @Published var compAngleHistory: [(Date, Double, Double)] = []
    
    @Published var isCollecting: Bool = false
    
    private let model: PolarSensorModel
    private let mainModel = MainModel()  // The instance of your MainModel for processing data
    private var cancellables = Set<AnyCancellable>()
    var deviceId: String {
        model.deviceId
    }
    init(deviceId: String) {
        model = PolarSensorModel(deviceId: deviceId)
        
        // Subscribe to sensor data from PolarSensorModel
        model.sensorDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sensorData in
                print("Received new sensor data")
                self?.accelerometerDataBlu = sensorData.accelerometer
                self?.gyroscopeDataBlu = sensorData.gyroscope
                // Log updates
                print("Updated ViewModel - Acc: \(self?.accelerometerDataBlu ?? (0, 0, 0)), Gyro: \(self?.gyroscopeDataBlu ?? (0, 0, 0))")
                
                // Update history with the new raw data
                self?.updateHistory(with: sensorData)
                
                // Process angles and update angle history
                self?.processAngles(from: sensorData)
                
                // Log history updates
                print("Updated History - Angle History: \(self?.angleHistory.count ?? 0) entries, Comp Angle History: \(self?.compAngleHistory.count ?? 0) entries")
            }
            .store(in: &cancellables)
    }
    
    func startStreaming() {
        model.startStreaming()
        isCollecting = true
        print("Started streaming data")
        let dummyData = SensorDataBlu(accelerometer: (x: 0.1, y: 0.2, z: 0.3), gyroscope: (x: 0.1, y: 0.2, z: 0.3))
        print("Publishing sensor data: \(dummyData)") // Add this to check if data is being sent

    }
    
    func stopStreaming() {
        model.stopStream()
        isCollecting = false
    }
    
    func saveData() {
        let sensorData = SensorDataBlu(
            accelerometer: accelerometerDataBlu,
            gyroscope: gyroscopeDataBlu
        )
        model.saveData(sensorData)
    }
    
    private func updateHistory(with data: SensorDataBlu) {
        // Update accelerometer and gyroscope history with new data
        accelerometerHistory.append(("X", data.accelerometer.x))
        accelerometerHistory.append(("Y", data.accelerometer.y))
        accelerometerHistory.append(("Z", data.accelerometer.z))
        
        gyroscopeHistory.append(("X", data.gyroscope.x))
        gyroscopeHistory.append(("Y", data.gyroscope.y))
        gyroscopeHistory.append(("Z", data.gyroscope.z))
        
        // Limit history size (optional)
        if accelerometerHistory.count > 300 { accelerometerHistory.removeFirst(3) }
        if gyroscopeHistory.count > 300 { gyroscopeHistory.removeFirst(3) }
    }
    
    private func processAngles(from data: SensorDataBlu) {
        // Convert SensorDataBlu to SensorData
        let accelData = convertToSensorData(from: data.accelerometer)
        let gyroData = convertToSensorData(from: data.gyroscope)
        //let accelData = SensorData(x: data.accelerometer.x, y: data.accelerometer.y, z: data.accelerometer.z)
        //let gyroData = SensorData(x: data.gyroscope.x, y: data.gyroscope.y, z: data.gyroscope.z)
        
        // Process angles using the MainModel
        let angleDataPair = mainModel.processSensorData(accelData, accelData: accelData, gyroData: gyroData)
        
        // Update filtered angles and histories
        self.filteredAngles = angleDataPair.emwaFilteredAngles
        self.updateAngleHistory(with: angleDataPair.emwaFilteredAngles)
        
        self.compFilteredAngles = angleDataPair.compFilteredAngles
        self.updateCompAngleHistory(with: angleDataPair.compFilteredAngles)
        
        print("Processed angles - EMWA: \(angleDataPair.emwaFilteredAngles), Complementary: \(angleDataPair.compFilteredAngles)")
    }
    
    private func updateAngleHistory(with angles: AngleData) {
        // Store angles with timestamps
        angleHistory.append((Date(), angles.pitch, angles.roll))
        if angleHistory.count > 300 {
            angleHistory.removeFirst()
        }
    }
    
    private func updateCompAngleHistory(with angles: AngleData) {
        compAngleHistory.append((Date(), angles.pitch, angles.roll))
        if compAngleHistory.count > 300 {
            compAngleHistory.removeFirst()
        }
    }
    
    // Convert SensorDataBlu to SensorData for use in the MainModel
    private func convertToSensorData(from data: (x: Double, y: Double, z: Double)) -> SensorData {
        return SensorData(x: data.x, y: data.y, z: data.z)
    }
    
    */
}
