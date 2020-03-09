//
//  ViewController.swift
//  ImageFilters
//
//  Created by Austin Potts on 3/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

  //MARK: - Outlets
    
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var imageViewer: UIImageView!
    
    
    
    @IBAction func selectImageTapped(_ sender: Any) {
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
    
    //MARK: - Slider Events
    @IBAction func brightnessChanged(_ sender: UISlider) {

   
        
    }
    
    @IBAction func contrastChanged(_ sender: Any) {


    }
    
    @IBAction func saturationChanged(_ sender: Any) {
        

    }
    
    
}

