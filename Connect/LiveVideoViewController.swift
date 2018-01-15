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
    var outputStream: OutputStream?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
        
        connector.service.streamReceived = streamReceived
        
        outputStream = connector.startStream(streamName: "liveVideo")
        if let outputStream = outputStream {
            outputStream.delegate = self
            outputStream.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
            outputStream.open()
        }
        
        styleCaptureButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
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
    
    func closeView() {
        if let outputStream = outputStream{
            outputStream.close()
            outputStream.remove(from: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }
        outputStream = nil
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromBottom
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: false)
    }
    
    func styleCaptureButton() {
        stopVideoCall.layer.borderColor = UIColor.white.cgColor
        stopVideoCall.layer.borderWidth = 2
        stopVideoCall.layer.cornerRadius = min(stopVideoCall.frame.width, stopVideoCall.frame.height) / 2
    }
    
    func streamReceived(stream: InputStream, streamName: String, peer: MCPeerID) {
        stream.delegate = self
        stream.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        stream.open()
    }
    
    @IBAction func CancelVideoCall(_ sender: Any) {
        closeView()
        //TODO : Stop the stream
    }

    @IBAction func switchCamera(_ sender: Any) {
        frameExtractor.flipCamera()
        if toogleFlipCamera.currentImage == UIImage(named: "Rear Camera Icon"){
            toogleFlipCamera.setImage(#imageLiteral(resourceName: "Front Camera Icon"), for: .normal)
        }
        else{
            toogleFlipCamera.setImage(#imageLiteral(resourceName: "Rear Camera Icon"), for: .normal)
        }
    }
}

//MARK : Stream event 🔢
extension LiveVideoViewController : StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event){
        switch(eventCode){
        case Stream.Event.hasBytesAvailable:
            //TODO: ADD READING
            break
        //input
        case Stream.Event.hasSpaceAvailable:
            break
        //output
        default:
            break
        }
    }
}

extension LiveVideoViewController: FrameExtractorDelegate {
    
    func captured(image: UIImage) {
        userView.image = image
        let data = NSKeyedArchiver.archivedData(withRootObject: image)
        if let outputStream = outputStream{
            //outputStream.write(UnsafeMutablePointer(data.bytes), maxLength: data.length)
        }
    }
}
