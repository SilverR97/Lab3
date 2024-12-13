//
//  HomeView.swift
//  PolarSDK
//
//  Created by Reinaldo Plata P on 12/3/24.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: SensorViewModel
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "figure.cooldown")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.tint)
                    .padding()
                    .frame(width: 100, height: 120)
                
                Text("Welcome! \n Please select the sensors you would like to use.")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer().frame(height: 300)
                //navigation links
                HStack {
                    NavigationLink(destination: DeviceSensView()) {
                        Text("Device sensors")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    Spacer().frame(width: 70)
                    NavigationLink(destination: ContentView(deviceId: viewModel.deviceId)) {
                        Text("Bluetooth sensor")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                
            }
            .navigationTitle("Home") // Título en la barra de navegación
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

//#Preview {
//    HomeView()
//}
