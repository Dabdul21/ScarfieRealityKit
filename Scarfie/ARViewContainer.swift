import ARKit
import RealityKit
import SwiftUI

//sets up an arview
struct ARViewContainer: UIViewRepresentable {
    @Binding var isFaceDetected: Bool // Binding to track face detection status
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // check for face tracking support
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return arView
        }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true //is used to provide scene lighting information
        arView.session.run(configuration) //starts the configuration
        
        // Add ARSession delegate to capture face data
        arView.session.delegate = context.coordinator //tells the app where to send updates (face movement) and                                                         coordinator handles the rest
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    //assigns Coordinator as a delegate to listen for face detection.
    func makeCoordinator() -> Coordinator {
        return Coordinator(isFaceDetected: $isFaceDetected)
    }
    
//listens for face events and updates binding whwnever ARKit finds something it will tell this class
    class Coordinator: NSObject, ARSessionDelegate {
        @Binding var isFaceDetected: Bool // Binding to update the UI state
        private var detectionTimer: Timer?
        
        // Initializer for the Coordinator
        init(isFaceDetected: Binding<Bool>) {
            _isFaceDetected = isFaceDetected // uses _ so it asssigns the value to backing storage
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
            
            // updates the @bidning variable
            DispatchQueue.main.async {
                self.isFaceDetected = faceDetected
            }
            
            // Resets the timer to clear the detection state if no updates arrive
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
