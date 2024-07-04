//
//  ViewController.swift
//  FoodDetection
//
//  Created by Maliha on 2/7/24.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        //imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            photoImageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("couldn't convert UI image to CI image")
            }
            detect(image: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage){
     
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: MLModelConfiguration()).model) else {
            fatalError("Loading core ML model failed")
        }
        
        let request = VNCoreMLRequest(model: model){(request,error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            //print(results)
            
            if let firstResults = results.first{
                if firstResults.identifier.contains("burger"){
                    self.navigationItem.title = "Burger!"
                } else {
                    self.navigationItem.title = "not a burger!"
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

