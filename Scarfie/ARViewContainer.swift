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
        @Binding var isFaceDetected: Bool

        init(isFaceDetected: Binding<Bool>) {
            _isFaceDetected = isFaceDetected
        }

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            var faceDetected = false
            for anchor in anchors {
                if anchor is ARFaceAnchor {
                    faceDetected = true
                    break
                }
            }
            DispatchQueue.main.async {
                self.isFaceDetected = faceDetected
            }
        }
    }
}
