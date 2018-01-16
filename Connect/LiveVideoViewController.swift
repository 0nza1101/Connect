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
    var outputVideoStream: OutputStream?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
        
        connector.service.streamReceived = streamReceived
        
        outputVideoStream = connector.startStream(streamName: "liveVideo")
        if let outputStream = outputVideoStream {
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
        if let outputStream = outputVideoStream {
            outputStream.close()
            outputStream.remove(from: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }
        outputVideoStream = nil
        
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
    
    func sendStreamImage(_ image: UIImage){
        if let outputStream = outputVideoStream {
            print("Sending image into the stream")
            let dictionary = ["live": image]
            let dataToStream = NSKeyedArchiver.archivedData(withRootObject: dictionary)
            _ = outputStream.write(data: dataToStream)
        }
    }
    
    @IBAction func CancelVideoCall(_ sender: Any) {
        closeView()
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
extension OutputStream {
    func write(data: Data) -> Int {
        return data.withUnsafeBytes { write($0, maxLength: data.count) }
    }
}

extension InputStream {
    func read(data: inout Data) -> Int {
        return data.withUnsafeMutableBytes { read($0, maxLength: data.count) }
    }
}

extension LiveVideoViewController : StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event){
        switch(eventCode){
        case Stream.Event.hasBytesAvailable:
            //READING
            print("Reading image from the stream")
            let inputStream = aStream as! InputStream
            let maxReadLength = 4096// Maybe need to be changed
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            let data = Data(bytes: buffer, count: numberOfBytesRead)
            
            let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]
            if let image = dataDictionary["live"] {
                print("Got an image")
                streamView.image = (image as! UIImage)
            }
            
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
        sendStreamImage(image)
    }
}
