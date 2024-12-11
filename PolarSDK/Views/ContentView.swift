//
//  ContentView.swift
//  PolarSDK
//
//  Created by Reinaldo Plata P on 11/29/24.
//

import SwiftUI
import PolarBleSdk

struct ContentView: View {
    @StateObject private var viewModel =  SensorViewModel(deviceId: "C07A2A29")
       
    init(deviceId: String) {
            _viewModel = StateObject(wrappedValue: SensorViewModel(deviceId: deviceId))
        }
    
       var body: some View {
           VStack {
               Text("Polar APK app test")
               Spacer().frame(height: 100)
               Text("Accelerometer data")
               Text("X: \(viewModel.accelerometerDataBlu.x)")
               Text("Y: \(viewModel.accelerometerDataBlu.y)")
               Text("Z: \(viewModel.accelerometerDataBlu.z)")
               
               Text("Gyroscope data")
               Text("X: \(viewModel.gyroscopeDataBlu.x)")
               Text("Y: \(viewModel.gyroscopeDataBlu.y)")
               Text("Z: \(viewModel.gyroscopeDataBlu.z)")
               
               Spacer().frame(height: 100)
               Button("Start Streaming") {
                   viewModel.startStreaming()
               }
               
               Spacer().frame(height: 100)
               Button("Stop Streaming") {
                   viewModel.stopStreaming()
               }
           }
       }
   }
/*struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SensorViewModel(deviceId: "123443") // Asegúrate de inicializar correctamente el viewModel
        ContentView(viewModel: viewModel) // Añadir el nombre del parámetro `viewModel`
    }
}
*/
