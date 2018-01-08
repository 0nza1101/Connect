//
//  Connector.swift
//  Connect
//
//  Created by Jordan on 25/12/2017.
//  Copyright © 2017 Jordan. All rights reserved.
//

import Foundation
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
    
    func send(text: String) -> Void {
        let myNSString = text as NSString
        let dataToSend = myNSString.data(using: String.Encoding.utf8.rawValue)!
        do {
            try service.send(data: dataToSend)
        }
        catch {
            print("Can't send the message to the other peer.")
        }
    }
    
}
