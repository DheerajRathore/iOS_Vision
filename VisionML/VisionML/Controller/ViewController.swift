//
//  ViewController.swift
//  VisionML
//
//  Created by Dheeraj Singh Rathore on 11/09/21.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUPCaptaureSession()
    }
    
    
    private func setUPCaptaureSession(){
      
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("frame:", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        //download the models from https://developer.apple.com/machine-learning/
        //Resnet50().model
        guard let model = try? VNCoreMLModel(for:  Resnet50.init(configuration: MLModelConfiguration.init()).model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in

            if let error = err{
                print(error.localizedDescription)
                return
            }
//            print(finishedReq.results)

            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }

            guard let firstObservation = results.first else { return }

            print(firstObservation.identifier, firstObservation.confidence)

            DispatchQueue.main.async {
                //self.identifierLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
            }

        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }


}

