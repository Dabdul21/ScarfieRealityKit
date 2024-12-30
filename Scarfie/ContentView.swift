//
//  ContentView.swift
//  Scarfie
//
//  Created by Dayan Abdulla on 12/2/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Embed ARViewContainer
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)

            // Add a basic overlay or buttons here camera shows up here
            VStack {
                Spacer()
                Text("Scanning for a scarf...")
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
