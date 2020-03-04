//
//  ViewController.swift
//  ARKitFaceTrackingTutorial
//
//  Created by Evgeniy Antonov on 4/23/19.
//  Copyright © 2019 Evgeniy Antonov. All rights reserved.
//

import UIKit
import ARKit
import ReplayKit

private let planeWidth: CGFloat = 0.13
private let planeHeight: CGFloat = 0.06
private let nodeYPosition: Float = 0.022
private let minPositionDistance: Float = 0.0025
private let minScaling: CGFloat = 0.025
private let cellIdentifier = "GlassesCollectionViewCell"
private let glassesCount = 22
private let animationDuration: TimeInterval = 0.25
private let cornerRadius: CGFloat = 10

class CameraViewController: UIViewController,RPPreviewViewControllerDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var glassesView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var calibrationView: UIView!
    @IBOutlet weak var calibrationTransparentView: UIView!
    @IBOutlet weak var collectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var calibrationBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var calibrationButton: UIButton!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var cameraStackBottom: NSLayoutConstraint!
    @IBOutlet weak var stackCamera: UIStackView!
    var recState = false
    private let glassesPlane = SCNPlane(width: planeWidth, height: planeHeight)
    private let glassesNode = SCNNode()
    
    private var scaling: CGFloat = 1
    
    private var isCollecionOpened = false {
        didSet {
            updateCollectionPosition()
        }
    }
    private var isCalibrationOpened = false {
        didSet {
            updateCalibrationPosition()
        }
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else {
            alertLabel.text = "Face tracking is not supported on this device"
            
            return
        }
        
        sceneView.delegate = self
        
        setupCollectionView()
        setupCalibrationView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.navigationItem.title = "Camera"
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionBottomConstraint.constant = -glassesView.bounds.size.height
    }
    
    private func setupCalibrationView() {
        calibrationTransparentView.layer.cornerRadius = cornerRadius
        calibrationBottomConstraint.constant = -calibrationView.bounds.size.height
    }
    
    private func updateGlasses(with index: Int) {
        let imageName = "glasses\(index)"
        glassesPlane.firstMaterial?.diffuse.contents = UIImage(named: imageName)
    }
    
    private func updateCollectionPosition() {
        collectionBottomConstraint.constant = isCollecionOpened ? 0 : -glassesView.bounds.size.height
        UIView.animate(withDuration: animationDuration) {
            self.calibrationButton.alpha = self.isCollecionOpened ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCalibrationPosition() {
        calibrationBottomConstraint.constant = isCalibrationOpened ? 0 : -calibrationView.bounds.size.height
        UIView.animate(withDuration: animationDuration) {
            self.collectionButton.alpha = self.isCalibrationOpened ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateSize() {
        glassesPlane.width = scaling * planeWidth
        glassesPlane.height = scaling * planeHeight
    }
    
    // MARK: - Actions
    
    @IBAction func collectionDidTap(_ sender: UIButton) {
        isCollecionOpened = !isCollecionOpened
        updateCon()
    }
    
    @IBAction func calibrationDidTap(_ sender: UIButton) {
        isCalibrationOpened = !isCalibrationOpened
    }
    
    @IBAction func sceneViewDidTap(_ sender: UITapGestureRecognizer) {
        isCollecionOpened = false
        isCalibrationOpened = false
        stackCamera.isHidden = false
    }
    
    func updateCon(){
           if isCollecionOpened{
            stackCamera.isHidden = true
               
           }else{
           stackCamera.isHidden = false
           }
       }
    
    @IBAction func upDidTap(_ sender: UIButton) {
        glassesNode.position.y += minPositionDistance
    }
    
    @IBAction func downDidTap(_ sender: UIButton) {
        glassesNode.position.y -= minPositionDistance
    }
    
    @IBAction func leftDidTap(_ sender: UIButton) {
        glassesNode.position.x -= minPositionDistance
    }
    
    @IBAction func rightDidTap(_ sender: UIButton) {
        glassesNode.position.x += minPositionDistance
    }
    
    @IBAction func farDidTap(_ sender: UIButton) {
        glassesNode.position.z += minPositionDistance
    }
    
    @IBAction func closerDidTap(_ sender: UIButton) {
        glassesNode.position.z -= minPositionDistance
    }
    
    @IBAction func biggerDidTap(_ sender: UIButton) {
        scaling += minScaling
        updateSize()
    }
    
    @IBAction func smallerDidTap(_ sender: UIButton) {
        scaling -= minScaling
        updateSize()
    }
    
    fileprivate func recordScreen(){
          let recorder =  RPScreenRecorder.shared()
      if !recorder.isRecording{
          recorder.startRecording { (error) in
              guard error == nil else{
                self.btnStart.setImage(UIImage(named: "video-camera"), for: .normal)
                  print("Failed to start recording")
                  return
              }
            }
          }
      
      }
     fileprivate func stopRecordScreen(){
        let recorder = RPScreenRecorder.shared()
            recorder.stopRecording { (previewVC, error) in
          if let previewVC = previewVC{
              previewVC.previewControllerDelegate = self
              self.present(previewVC, animated: true, completion: nil)
          }
          if let error = error{
              print(error)
          }
      }
       
      }
      func recordState(){
          if recState{
            btnStart.setImage(UIImage(named: "video-camera-stop"), for: .normal)
           
          }else{
               btnStart.setImage(UIImage(named: "video-camera"), for: .normal)
          }
          
      }
    
    
    @IBAction func capture(_ sender: UIButton) {
       
            recState = !recState
            recordState()
            if recState{
                    recordScreen()
            }else{
                   stopRecordScreen()
                 
            }
    }
    
    @available(iOS 13.0, *)
    @IBAction func picapture(_ sender: UIButton) {
        
        let img =  UIImage.init(view: sceneView)
              
            let alert = UIAlertController(title: "", message: "Image Captured 😎 \n Do you want to edit captured image?", preferredStyle: .alert)
        
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                            UIImageWriteToSavedPhotosAlbum(img, self, nil, nil)
               }))
        
              alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
           
                if let editVC = self.storyboard?.instantiateViewController(identifier: "EditImageViewController")as? EditImageViewController{
                    editVC.imgCapturedPic = img
                self.navigationController?.pushViewController(editVC, animated: true)
            }
        }))
    
       self.present(alert, animated: true, completion: nil)
     
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true, completion: nil)
        
    }
    
}

extension CameraViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else {
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeometry)
        faceNode.geometry?.firstMaterial?.transparency = 0
        
        glassesPlane.firstMaterial?.isDoubleSided = true
        updateGlasses(with: 0)
        
        glassesNode.position.z = faceNode.boundingBox.max.z * 3 / 4
        glassesNode.position.y = nodeYPosition
        glassesNode.geometry = glassesPlane

        faceNode.addChildNode(glassesNode)
        
        return faceNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
}

extension CameraViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return glassesCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GlassesCollectionViewCell
        let imageName = "glasses\(indexPath.row)"
        cell.setup(with: imageName)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateGlasses(with: indexPath.row)
    }
}

extension UIImage{
    convenience init(view: UIView) {

    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.init(cgImage: (image?.cgImage)!)

  }
}

