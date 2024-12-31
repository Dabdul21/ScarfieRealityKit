import ARKit
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    @Binding var isFaceDetected: Bool // Binding to track face detection status
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Check for face tracking support
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return arView
        }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        arView.session.run(configuration)
        
        // Add ARSession delegate to capture face data
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isFaceDetected: $isFaceDetected)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        @Binding var isFaceDetected: Bool // Binding to update the UI state
        private var detectionTimer: Timer?
        
        // Initializer for the Coordinator
        init(isFaceDetected: Binding<Bool>) {
            _isFaceDetected = isFaceDetected
        }
        
        // ARSessionDelegate method that listens for updates to AR anchors
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            // Check if any of the anchors are ARFaceAnchor
            let faceDetected = anchors.contains { $0 is ARFaceAnchor }
            
            // Log face detection status and data if a face is detected
            if faceDetected {
                for anchor in anchors {
                    if let faceAnchor = anchor as? ARFaceAnchor {
                        print("Detected face at transform: \(faceAnchor.transform)")
                        print("Face blend shapes: \(faceAnchor.blendShapes)")
                    }
                }
            }
            
            // Update the state variable on the main thread
            DispatchQueue.main.async {
                self.isFaceDetected = faceDetected
            }
            
            // Reset the timer to clear the detection state if no updates arrive
            resetDetectionTimer()
        }
        
        // Method to reset detection state after a delay
        private func resetDetectionTimer() {
            // Invalidate any existing timer
            detectionTimer?.invalidate()
            
            // Start a new timer change 0.5 to make longer or shorter
            detectionTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isFaceDetected = false
                }
            }
        }
    }
}
