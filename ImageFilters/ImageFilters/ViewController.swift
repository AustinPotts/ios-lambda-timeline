//
//  ViewController.swift
//  ImageFilters
//
//  Created by Austin Potts on 3/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ViewController: UIViewController {
    
    
    //MARK: - Properties
    private var originalImage: UIImage?{
        didSet {
            
            guard let originalImage = originalImage else {return}
            var scaledSize = imageViewer.bounds.size
            let scale = UIScreen.main.scale //1x 2x or 3x
            
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
            
        }
    }
    
    
    private var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    
    
    private var context = CIContext(options: nil)
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalImage = imageViewer.image
        
    }
   
    //MARK: - Methods
    
    func filterImage(_ image: UIImage) -> UIImage? {
        
        // UImage > CGImage > CIIMage
        
        guard let cgImage = image.cgImage else {return nil}
        
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.brightness = brightnessSlider.value
        filter.contrast = contrastSlider.value
        filter.saturation = saturationSlider.value
        
        guard let outputCIimage = filter.outputImage else { return nil }
        
        
        
        // Then you will have to do the reverse
        
        //Render the image (apply the filter to the image) i.e baking cookies in overn
        
        guard let outputCGImage = context.createCGImage(outputCIimage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
        
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func updateImage(){
           
          if let scaledImage = scaledImage {
             imageViewer.image = filterImage(scaledImage)
           } else {
               imageViewer.image = nil // allows us to clear out the image
           }
           
       }
    
    private func presentImagePickerController(){
          
          guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
              return print("Error the phot library is unavailable")
          }
          
          let imagePicker = UIImagePickerController()
          
          imagePicker.sourceType = .photoLibrary
          
          imagePicker.delegate = self
          
          present(imagePicker, animated: true)
          
          
      }
    

  //MARK: - Outlets
    
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var imageViewer: UIImageView!
    
    
    
    @IBAction func selectImageTapped(_ sender: Any) {
         presentImagePickerController()
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        savePhoto()
    }
    
    private func savePhoto() {
         guard let originalImage = originalImage else { return }
     
        // If you dont flatten, the image could rotate
         guard let processedImage = self.filterImage(originalImage.flattened) else { return }
         PHPhotoLibrary.requestAuthorization { (status) in
             
             // Gives us permission to acccess the library
             guard status == .authorized else { return }
             // Let the library know we are going to make changes
             PHPhotoLibrary.shared().performChanges({
                 // Make a new photo creation request
                 PHAssetCreationRequest.creationRequestForAsset(from: processedImage)
             }, completionHandler: { (success, error) in
                 if let error = error {
                     NSLog("Error saving photo: \(error)")
                     return
                 }
                 DispatchQueue.main.async {
                     print("Saved image to Photo Library")
                 }
             })
         }
     }
    
    
    //MARK: - Slider Events
    @IBAction func brightnessChanged(_ sender: UISlider) {
         
                updateImage()
        
    }
    
    @IBAction func contrastChanged(_ sender: Any) {
                updateImage()

    }
    
    @IBAction func saturationChanged(_ sender: Any) {
                updateImage()

    }
    
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Picked image")
        
        if let image = info[.originalImage] as? UIImage{
            originalImage = image
        }
        picker.dismiss(animated: true)
    }
    
}
