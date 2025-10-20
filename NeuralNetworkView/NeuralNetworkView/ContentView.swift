//
//  ContentView.swift
//  NeuralNetworkView
//
//  Created by Emilie on 19/10/2025.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        NeuralNetworkView()
            .edgesIgnoringSafeArea(.all) // Pour que le réseau prenne tout l'écran
    }
}

#Preview {
    ContentView()
}
