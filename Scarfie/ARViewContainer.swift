import ARKit
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    @Binding var isFaceDetected: Bool // Binding to track face detection status

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return arView
        }

        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        arView.session.run(configuration)

        // Attach ARSession delegate
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(isFaceDetected: $isFaceDetected, arView: nil)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        @Binding var isFaceDetected: Bool
        private var detectionTimer: Timer?
        var arView: ARView?

        init(isFaceDetected: Binding<Bool>, arView: ARView?) {
            _isFaceDetected = isFaceDetected
            self.arView = arView
        }

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let arView = arView else { return }

            let faceAnchors = anchors.compactMap { $0 as? ARFaceAnchor }

            DispatchQueue.main.async {
                self.isFaceDetected = !faceAnchors.isEmpty
            }

            // Add or update the 3D scarf model
            for faceAnchor in faceAnchors {
                if let scarfEntity = arView.scene.findEntity(named: "Scarf") {
                    // Update existing scarf position
                    scarfEntity.transform = Transform(matrix: faceAnchor.transform)
                } else {
                    // Load and add a new scarf model
                    guard let scarfEntity = try? Entity.load(named: "ScarfModel") else {
                        print("Failed to load scarf model.")
                        continue
                    }
                    scarfEntity.name = "Scarf"
                    scarfEntity.transform = Transform(matrix: faceAnchor.transform)
                    let anchorEntity = AnchorEntity(anchor: faceAnchor)
                    anchorEntity.addChild(scarfEntity)
                    arView.scene.addAnchor(anchorEntity)
                }
            }

            // Reset detection state if no updates
            resetDetectionTimer()
        }

        private func resetDetectionTimer() {
            detectionTimer?.invalidate()
            detectionTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isFaceDetected = false
                }
            }
        }
    }
}
