//
//  CameraPreview.swift
//  VideoRecorder-Afternoon
//
//  Created by Austin Potts on 3/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

import AVFoundation

class CameraPreview: UIView {
    
    // Defaults to CALayer class
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPlayerView: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { return videoPlayerView.session }
        set { videoPlayerView.session = newValue }
    }
}
