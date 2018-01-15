//
//  LiveVideoViewController.swift
//  Connect
//
//  Created by Jordan on 14/01/2018.
//  Copyright © 2018 Jordan. All rights reserved.
//

import UIKit

class LiveVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

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
