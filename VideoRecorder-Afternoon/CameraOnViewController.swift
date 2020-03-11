//
//  CameraOnViewController.swift
//  VideoRecorder-Afternoon
//
//  Created by Austin Potts on 3/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraOnViewController: UIViewController {
    
    
    //TODO: Add Capture Session
    lazy var captureSession = AVCaptureSession()
    
    
    //TODO: Add Movie Output
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    
    //Player
    var player: AVPlayer!
    


    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreview!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Resize camera preview to fill the entire screen
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        setUpCaptureSession()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession.startRunning()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        captureSession.stopRunning()
    }
    
    private func setUpCaptureSession(){
        let camera = bestCamera()
        
        //open
        captureSession.beginConfiguration()
        
        //Add inputs
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else { fatalError("Cant create camera with current input") }
        
        captureSession.addInput(cameraInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080 //1080p
        }
        
        
        //TODO: Add Microphone
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(audioInput) else {
                fatalError("Can't create and add input from microphone")
        }
        captureSession.addInput(audioInput)
        
        
        
        
        //TODO: Add Outputs
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Cannot save movie to capture session")
        }
        captureSession.addOutput(fileOutput)
        
        
        
        //close
        captureSession.commitConfiguration()
        
        cameraView.session = captureSession
        
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }
    
    private func bestCamera() -> AVCaptureDevice {

        // ultra wide lens 0.5
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        }
        
        
        // wide angle lens (available on all iphones)
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        
        //Fatal Error if none of these exist
        fatalError("No cameras on device ")
        
        
    }
    

    @IBAction func recordButtonPressed(_ sender: Any) {
        
        toggleRecord()

    }
    
    private func toggleRecord(){
        if fileOutput.isRecording {
            fileOutput.stopRecording()
            print("Stopped Recording")
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    /// Creates a new file URL in the documents directory
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
    
    //Play Movie
    func playMovie(url: URL) {
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        var topRect = view.bounds
        topRect.size.height = topRect.height / 4
        topRect.size.width = topRect.width / 4
        topRect.origin.y = view.layoutMargins.top

        playerLayer.frame = topRect
        view.layer.addSublayer(playerLayer)

        player.play()
    }
    
    func replayMovie() {
        guard let player = player else { return }

        //Seek to beginning first
        player.seek(to: CMTime.zero)
        //CMTime(seconds: 2, preferredTimescale: 30) // 30 Frames per second (FPS)
        
        //play from beginning
        player.play()
    }
    
    @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
    print("tap")
        // Ended state
    switch(tapGesture.state) {
        
    case .ended:
        replayMovie()
    default:
        print("Handled other states: \(tapGesture.state)")
    }
    
    
  }
}

extension CameraOnViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if let error = error {
            print("Error saving video: \(error)")
        }
        
        updateViews()
        
        
        //Play Movie: TODO
        playMovie(url: outputFileURL)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
    
    
    
    
}

