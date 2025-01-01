//
//  TODO.swift
//  Scarfie
//
//  Created by Dayan Abdulla on 12/30/24.
//
//
//Now that it detects faces and will switch UI when a face is not detected you will need the following things:

//Models of scarves
//Loading a 3D model of a scarf.
//Attaching it to the face anchor detected by ARKit.
//train model
//find pictures
//figure out coreml
//find datapoints
//add scarf ui
//add welcome screen
//maybe app icon

//--------------------------------------
//              TO-DO LIST CHAT GPT
/*  Phase 1: Setup Basic Face and Head Detection

     1. Integrate ARKit for Face Tracking:
 Ensure ARKit detects faces reliably using ARFaceTrackingConfiguration.
 Test face detection with the current implementation to confirm functionality.

        2. Capture Camera Frames for Analysis:
 Use ARSessionDelegate to retrieve frames (ARFrame.capturedImage) for further analysis.
 Convert frames to a format suitable for image analysis, such as CIImage.


    Phase 2: Implement Scarf Detection
 
    3. Choose a Machine Learning Approach:
 Option 1: Train a custom Core ML model to detect headscarves.
 Collect a dataset of images with and without headscarves.
 Train a model using tools like TensorFlow or Create ML, exporting it as .mlmodel.
 
 Option 2: Use a pre-trained object detection model like YOLO or MobileNet.
 Fine-tune it to recognize headscarves.










*/
