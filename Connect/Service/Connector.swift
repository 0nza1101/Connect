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
    
    func send(dictionaryWithData dictionary: Dictionary<String, String>) -> Void {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try service.send(data: dataToSend)
        }
        catch {}
    }
    
}
