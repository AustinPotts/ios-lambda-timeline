//
//  ViewController.swift
//  VideoRecorder-Afternoon
//
//  Created by Austin Potts on 3/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestPermissionAndShowCamera()
    }
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            requestPermission()
            // First time user has seen the dialog, we don't have permission
        case .restricted:
            fatalError("Inform the user they cannot use the camera due to parental controls")
            // parental controls restrict access to camera
        case .denied:
            fatalError("Inform the user to enable camera access in settings")
            // we asked for permission and they said no
        case .authorized:
            showCamera()
            // we asked for permission and they said yes
        default:
            fatalError("Unexpected status")
        }
    }
    private func requestPermission() {
        
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
              guard granted else {
                  fatalError("Tell user they need to enable Privacy for Video/Camera/Microphone")
              }
            
            // With API we arent guarteed what thread we're on
              DispatchQueue.main.async { [weak self] in
                  self?.showCamera()
              }
          }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "ShowCamera", sender: self)
    }
}
