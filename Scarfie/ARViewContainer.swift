import ARKit
import RealityKit
import SwiftUI
import Vision

// This struct sets up an ARView that will use face tracking and then sends frames to be classified.
struct ARViewContainer: UIViewRepresentable {
    @Binding var isFaceDetected: Bool             // Binding to track face detection status
    @Binding var predictionResult: String           // Binding to track the ML prediction result

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Check for face tracking support
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return arView
        }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true // light estimation enabled
        arView.session.run(configuration)
        
        
        
        let faceAnchor = AnchorEntity(.face) //creating a face anchor
        
        //Containter Temp
        let testBox = ModelEntity(mesh: .generateBox(size: 0.05))
        testBox.position = [0, 0.1,0]
        testBox.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
         
        faceAnchor.addChild(testBox)
        arView.scene.anchors.append(faceAnchor)
        
        do {
            let loadedEntity = try Entity.load(named: "ScarfModel") // This returns a generic Entity

            //ModelEntity to apply material
            if let scarfModel = loadedEntity as? ModelEntity {
                scarfModel.position = [0, 0.2, 0]
                scarfModel.scale = [2.0, 2.0, 2.0]
                scarfModel.model?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
                faceAnchor.addChild(scarfModel)
                print("Scarf model loaded and added scene")
            } else {
                print("Loaded entity is not a ModelEntity")
            }

        } catch {
            print("Failed to load scarf model: \(error)")
        }

        
        // Set the AR session delegate to our Coordinator
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    // Create the Coordinator and pass both bindings
    func makeCoordinator() -> Coordinator {
        return Coordinator(isFaceDetected: $isFaceDetected, predictionResult: $predictionResult)
    }
    
    //Handles frame updates, and detects the face. Acts as the ARSessionDelegate
    class Coordinator: NSObject, ARSessionDelegate {
        @Binding var isFaceDetected: Bool             // Binding to update the face detection status
        @Binding var predictionResult: String           // Binding to update the ML prediction result
        private var detectionTimer: Timer?
        private var isProcessingFrame: Bool = false

        
        // Coordinator initializer
        init(isFaceDetected: Binding<Bool>, predictionResult: Binding<String>) {
            _isFaceDetected = isFaceDetected
            _predictionResult = predictionResult
        }
        
        //called when anchors in the AR session are updated
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            let faceDetected = anchors.contains { $0 is ARFaceAnchor }
            
            //MARK: AI Classification - Comment out to turn it off
//            if faceDetected, !isProcessingFrame {
//                isProcessingFrame = true  // block processing until the current fram is finished
//                
//                // Offload heavy work to a background thread.
//                DispatchQueue.global(qos: .userInitiated).async {
//                    //
//                    //get the current AR Frame and covert the capture pixel buffer to UIImage
//                    if let frame = session.currentFrame,
//                       let image = UIImage(pixelBuffer: frame.capturedImage) {
//                        
//                        // Scale the image to a lower resolution before classifying
//                        let targetSize = CGSize(width: 224, height: 224)
//                        let scaledImage = image.scaled(to: targetSize) ?? image
//                        
//                            //classifying the img using the model
//                        self.classify(image: scaledImage) {
//                            // Reset the flag in the completion handler on the main thread.
//                            DispatchQueue.main.async {
//                                self.isProcessingFrame = false
//                            }
//                        }
//                    } else {
//                        // In case of failure to get an image reset the flag on the main thread.
//                        DispatchQueue.main.async {
//                            self.isProcessingFrame = false
//                        }
//                    }
//                }
//            }
//            
            // Update the UI on the main thread with the face detection status.
            DispatchQueue.main.async {
                self.isFaceDetected = faceDetected
            }
            
            resetDetectionTimer()
        }


        
        // Reset the detection state after a short delay when needed
        private func resetDetectionTimer() {
            detectionTimer?.invalidate()
            detectionTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isFaceDetected = false
                }
            }
        }
        
        //Core ML CLASSIFICATION
//        Handles converting the image to CIImage, setting up and executing the Core ML request, and then updating the prediction result.
        func classify(image: UIImage, completion: @escaping () -> Void = {}) {
            guard let model = try? VNCoreMLModel(for: ImgClassfier().model),
                  let ciImage = CIImage(image: image) else {
                print("Model or image conversion failed")
                completion()  // Reset flag on failure
                return
            }
            
            let request = VNCoreMLRequest(model: model) { request, error in
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    print("No results")
                    completion()
                    return
                }
                DispatchQueue.main.async {
                    self.predictionResult = "\(topResult.identifier) (\(Int(topResult.confidence * 100))%)"
                }
                print("Prediction: \(topResult.identifier) (\(Int(topResult.confidence * 100))%)")
                completion()
            }
            //just a request handler for the img
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            try? handler.perform([request])
        }

    }
}

// UIImage extension to convert CVPixelBuffer to UIImage
extension UIImage {
    convenience init?(pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        self.init(cgImage: cgImage)
    }
}

//Scales down the image to a new size reducing the commputatiion load needed to classify
extension UIImage {
    func scaled(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

