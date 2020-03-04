//
//  HomeViewController.swift
//  ARKitFaceTrackingTutorial
//
//  Created by Vijay Parmar on 04/03/20.
//  Copyright © 2020 Evgeniy Antonov. All rights reserved.
//

let appName = "App Title"

import UIKit
class HomeViewController: UIViewController {

    @IBOutlet weak var btnOpenCamera :UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnOpenCamera.layer.cornerRadius = 25
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = appName
    }
    
    @IBAction func btnActionOpenCamera(_ sender : UIButton){
        
        if #available(iOS 13.0, *) {
            if let cameraVC = storyboard?.instantiateViewController(identifier: "CameraViewController")as? CameraViewController{
                self.navigationController?.pushViewController(cameraVC, animated: true)
            }
        } else {
           
            self.globalAlert(msg: "Your Application Not Compatible")
            
        }
        
    }
    
}
