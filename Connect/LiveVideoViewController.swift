//
//  LiveVideoViewController.swift
//  Connect
//
//  Created by Jordan on 14/01/2018.
//  Copyright © 2018 Jordan. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class LiveVideoViewController: UIViewController {
    
    @IBOutlet weak var toogleFlipCamera: UIButton!
    @IBOutlet weak var stopVideoCall: UIButton!
    
    @IBOutlet weak var userView: UIImageView!
    @IBOutlet weak var streamView: UIImageView!
    
    var frameExtractor: FrameExtractor!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self

        styleCaptureButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
        
        connector.service.dataReceived = dataReceived
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataReceived(data: Data, peer: MCPeerID) {
        let image = UIImage(data: data)
        streamView.image = image
    }
    
    func closeView() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromBottom
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: false)
    }
    
    func styleCaptureButton() {
        stopVideoCall.image
        stopVideoCall.layer.borderColor = UIColor.white.cgColor
        stopVideoCall.layer.borderWidth = 2
        stopVideoCall.layer.cornerRadius = min(stopVideoCall.frame.width, stopVideoCall.frame.height) / 2
    }
    
    @IBAction func CancelVideoCall(_ sender: Any) {
        closeView()
    }

    @IBAction func switchCamera(_ sender: Any) {
        frameExtractor.flipCamera()
        if toogleFlipCamera.currentImage == UIImage(named: "Rear Camera Icon"){
            toogleFlipCamera.setImage(#imageLiteral(resourceName: "Rear Camera Icon"), for: .normal)
        }
        else{
            toogleFlipCamera.setImage(#imageLiteral(resourceName: "Front Camera Icon"), for: .normal)
        }
    }
}

//MARK : FrameExtractor 🔢
extension LiveVideoViewController: FrameExtractorDelegate {
    
    func captured(image: UIImage) {
        userView.image = image
        DispatchQueue.main.async {
            connector.sendStream(image: image)
        }
    }
}
