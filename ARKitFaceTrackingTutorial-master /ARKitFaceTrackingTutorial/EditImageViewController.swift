//
//  EditImageViewController.swift
//  ARKitFaceTrackingTutorial
//
//  Created by Vijay Parmar on 04/03/20.
//  Copyright © 2020 Evgeniy Antonov. All rights reserved.
//

import UIKit
import IGRPhotoTweaks
import iOSPhotoEditor
class EditImageViewController: UIViewController {

    @IBOutlet weak var imgPreview: UIImageView!
    
    var imgCapturedPic = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        imgPreview.image = imgCapturedPic
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = "Edit Image"
    }
    
    
    @IBAction func btnActionShareImage(_ sender: UIButton) {
           let imageShare = [ imgPreview.image! ]
                  let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
                  activityViewController.popoverPresentationController?.sourceView = self.view
                  self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnActionSave(_ sender: UIButton) {
    
        UIImageWriteToSavedPhotosAlbum(imgPreview.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    @IBAction func btnActionCrop(_ sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ExampleCropViewController")as! ExampleCropViewController
              vc.image = imgPreview.image
              vc.delegate = self
              self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func btnActionEdit(_ sender: UIButton) {
        
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))

               //PhotoEditorDelegate
               photoEditor.photoEditorDelegate = self

               //The image to be edited
                  photoEditor.image = imgPreview.image

           //Stickers that the user will choose from to add on the image
            
                for i in 1...11{
                     photoEditor.stickers.append(UIImage(named: "st\(i)")!)
                }
               photoEditor.modalPresentationStyle = .overFullScreen
               //Present the View Controller
               present(photoEditor, animated: true, completion: nil)
        
    }

}


extension EditImageViewController: IGRPhotoTweakViewControllerDelegate {
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        imgPreview.image = croppedImage
        _ = controller.navigationController?.popViewController(animated: true)
    }

    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        _ = controller.navigationController?.popViewController(animated: true)
    }
}


extension EditImageViewController:PhotoEditorDelegate{
    func doneEditing(image: UIImage) {
        self.imgPreview.image = image
    }
    
    func canceledEditing() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
