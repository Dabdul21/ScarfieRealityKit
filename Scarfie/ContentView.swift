import SwiftUI

struct ContentView: View {
    @State private var isFaceDetected: Bool = false // Tracks face detection status

    var body: some View {
        ZStack {
            // Embed ARViewContainer
            ARViewContainer(isFaceDetected: $isFaceDetected)
                .edgesIgnoringSafeArea(.all)

            // Overlay to indicate status
            VStack {
                Spacer()
                Text(isFaceDetected ? "Face Detected!" : "Scanning for a face...")
                    .padding()
                    .background(isFaceDetected ? Color.green.opacity(0.7) : Color.black.opacity(0.5))
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
