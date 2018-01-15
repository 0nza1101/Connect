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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func streamReceived(stream: InputStream, streamName: String, peer: MCPeerID) {
        stream.delegate = self
        stream.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        stream.open()
    }
}

//MARK : Stream event 🔢
extension LiveVideoViewController : StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event){
        switch(eventCode){
        case Stream.Event.hasBytesAvailable:
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

    }
}
