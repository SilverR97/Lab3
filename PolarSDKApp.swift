//
//  PolarSDKApp.swift
//  PolarSDK
//
//  Created by Reinaldo Plata P on 11/29/24.
//

import SwiftUI

@main
struct PolarSDKApp: App {
    var body: some Scene {
        WindowGroup {
            let deviceId = "B50A8D2B"//"C07A2A29" // Reemplaza esto con el ID real de tu dispositivo Polar
            
                        let viewModel = SensorViewModel(deviceId: deviceId) // Inicializa el viewModel con deviceId
                        HomeView(viewModel: viewModel) // Pasa el viewModel a ContentView
        }
    }
}
