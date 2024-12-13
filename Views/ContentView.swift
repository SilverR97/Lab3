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
    @State private var timeLimit: TimeInterval = 10.0
    init(deviceId: String) {
        _viewModel = StateObject(wrappedValue: SensorViewModel(deviceId: deviceId))
    }
    
    var body: some View {
        Text("Polar APK app test")
        Image(systemName: "iphone.circle.fill")
            .resizable(resizingMode: .stretch)
            .foregroundStyle(.tint)
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            .frame(width: 150.0, height: 150.0)
        Text("Device sensors measurements")
            .font(.title)
        VStack(alignment: .leading){
            Text("Accelerometer data")
                .font(.title2)
                .fontWeight(.bold)
            Text("X:\(viewModel.accelerometerDataBlu.x, specifier: "%.2f")")
            Text("Y: \(viewModel.accelerometerDataBlu.y, specifier: "%.2f")")
            Text("Z: \(viewModel.accelerometerDataBlu.z, specifier: "%.2f")")
            
            Spacer().frame(height: 20)
            
            Text("Gyroscope data")
                .font(.title2)
                .fontWeight(.bold)
            Text("X: \(viewModel.gyroscopeDataBlu.x, specifier: "%.2f")")
            Text("Y: \(viewModel.gyroscopeDataBlu.y, specifier: "%.2f")")
            Text("Z: \(viewModel.gyroscopeDataBlu.z, specifier: "%.2f")")
        }
        .padding()
        Spacer().frame(height: 20)
        // Charts for accelerometer and gyroscope
        
        HStack {
            VStack{
                Text("Algorithm 1 Chart")
                    .font(.title2)
                    .fontWeight(.bold)
                
                AngleChartView(pitchData: viewModel.angleHistory.map { ($0.0, $0.1) })
                    .frame(height: 300)
                    .padding()
            }
            
            VStack{
                Text("Algorithm 2 Chart")
                    .font(.title2)
                    .fontWeight(.bold)
                
                AngleChartView(pitchData: viewModel.compAngleHistory.map { ($0.0, $0.1) })
                    .frame(height: 300)
                    .padding()
            }
        }
        
        
        Spacer().frame(height: 20)
        HStack {
            Button("Start") {
                viewModel.startStreaming()
            }
            .disabled(viewModel.isCollecting)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("Stop") {
                viewModel.stopStreaming()
            }
            //.disabled(!viewModel.isCollecting)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
            
        }
        .padding()
        Spacer().frame(height: 10)
        
        // Save Data Button
        Button(action: {
            //viewModel.saveData()
        }) {
            Text("Save Data")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
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
