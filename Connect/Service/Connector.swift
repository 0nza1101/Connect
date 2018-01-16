//
//  Connector.swift
//  Connect
//
//  Created by Jordan on 25/12/2017.
//  Copyright © 2017 Jordan. All rights reserved.
//

import Foundation
import CoreLocation
import MultipeerConnectivity

public class Connector {
    let service: MPCService
    let ownPeerID: MCPeerID
    
    init(identifier: String, myPeerIDName: String) {
        let peerID = MCPeerID(displayName: myPeerIDName)
        self.ownPeerID = peerID
        
        service = MPCService(with: identifier, as: peerID)
        service.startSvc()
    }
    
    //Message
    
    func send(text: String) -> Void {
        let dictionary = ["text": text]
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try service.send(data: dataToSend)
        }
        catch {
            print("Can't send the message to the other peer.")
        }
    }
    
    func send(location: CLLocation) -> Void {
        let dictionary = ["location": location]
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try service.send(data: dataToSend)
        }
        catch {
            print("Can't send the message to the other peer.")
        }
    }
    
    func send(image: UIImage) -> Void {
        let dictionary = ["image": image]
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try service.send(data: dataToSend)
        }
        catch {
            print("Can't send the message to the other peer.")
        }
    }
    
    func send(disconnect: String) -> Void {
        let dictionary = ["disconnect": disconnect]
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try service.send(data: dataToSend)
        }
        catch {
            print("Can't send the message to the other peer.")
        }
    }

    func send(videoCall: String) -> Void {
        let dictionary = ["videoCall": videoCall]
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try service.send(data: dataToSend)
        }
        catch {
            print("Can't send the message to the other peer.")
        }
    }
    
    //Stream
    
    func sendStream(image: UIImage) {
        let img = UIImageJPEGRepresentation(image, 0.1)
        do {
            if let imageData = img {
                try service.send(data: imageData)
            }
        }
        catch {
            print("Can't send the message to the other peer.")
        }
    }
    
}
