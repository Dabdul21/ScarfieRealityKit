//
//  ContentView.swift
//  Main UI view with AR integration and status display
//

import SwiftUI

struct ContentView: View {
    @State private var isFaceDetected: Bool = false         // Tracks face detection status
    @State private var predictionResult: String = ""          // Tracks the ML prediction result

    var body: some View {
        ZStack {
            // Embed ARViewContainer and pass both bindings
            ARViewContainer(isFaceDetected: $isFaceDetected, predictionResult: $predictionResult)
                .edgesIgnoringSafeArea(.all)

            // Overlay to indicate face detection and prediction
            VStack {
                Spacer()
                // Display face detection status
                Text(isFaceDetected ? "Face Detected!" : "Scanning...")
                    .padding()
                    .background(isFaceDetected ? Color.green.opacity(0.7) : Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                    .animation(.easeInOut, value: isFaceDetected)
                
                // Display ML prediction result once available
                if !predictionResult.isEmpty {
                    Text("ML Prediction: \(predictionResult)")
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
