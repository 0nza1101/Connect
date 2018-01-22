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
    
    //Messages
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
    
    //Locations
    func send(location: CLLocation) -> Void {
        let dictionary = ["location": location]
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try service.send(data: dataToSend)
        }
        catch {
            print("Can't send location message to the other peer.")
        }
    }
    
    //Images
    func send(image: UIImage) -> Void {
        let dictionary = ["image": image]
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try service.send(data: dataToSend)
        }
        catch {
            print("Can't send images message to the other peer.")
        }
    }
    
    //Disconnect
    func send(disconnect: String) -> Void {
        let dictionary = ["disconnect": disconnect]
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try service.send(data: dataToSend)
        }
        catch {
            print("Can't send disconnect message to the other peer.")
        }
    }
    
    //Videocall invitation
    func send(videoCall: String) -> Void {
        let dictionary = ["videoCall": videoCall]
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try service.send(data: dataToSend)
        }
        catch {
            print("Can't send videocall invitation to the other peer.")
        }
    }
    
    //Video stream
    func sendStream(image: UIImage) {
        let img = UIImageJPEGRepresentation(image, 0.1)
        let dictionary = ["video": img]
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try service.send(data: dataToSend)
        }
        catch {
            print("Can't send image stream to the other peer.")
        }
    }
    
    func send(hangUp: String) -> Void {
        let dictionary = ["hangup": hangUp]
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try service.send(data: dataToSend)
        }
        catch {
            print("Can't send hangup message to the other peer.")
        }
    }
    
}
