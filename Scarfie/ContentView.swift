import SwiftUI

struct ContentView: View {
    @State private var isFaceDetected: Bool = false
    @State private var selectedScarf: String = "ScarfModel" // Default scarf model

    var body: some View {
        ZStack {
            ARViewContainer(isFaceDetected: $isFaceDetected)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                // Dynamic status text
                Text(isFaceDetected ? "Face Detected!" : "Scanning for a face...")
                    .padding()
                    .background(isFaceDetected ? Color.green.opacity(0.7) : Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()

                // Scarf selection buttons
                HStack {
                    Button(action: { selectedScarf = "ScarfModel" }) {
                        Text("Scarf 1")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: { selectedScarf = "ScarfModel2" }) {
                        Text("Scarf 2")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
