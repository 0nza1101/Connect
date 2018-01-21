//
//  ViewController.swift
//  Connect
//
//  Created by Jordan on 24/12/2017.
//  Copyright © 2017 Jordan. All rights reserved.
//

import UIKit
import Foundation
import MultipeerConnectivity

var connector = Connector(identifier: "ynovB3", myPeerIDName: UIDevice.current.name)

class PeersTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Bind table refresh on service custom callback
        connector.service.foundedPeers = refreshTable
        connector.service.lostPeers = refreshTable
        connector.service.invitationReceived = invitationWasReceived
        connector.service.connectedWith = connectedWithPeer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshTable() {
        print("Refreshing table data")
        tableView.reloadData()
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        OperationQueue.main.addOperation { () in
            let chatRoom = ChatRoomViewController()
            chatRoom.recipientUserName = peerID.displayName
            self.navigationController?.pushViewController(chatRoom, animated: true)
        }
    }
    
    func invitationWasReceived(from: String){
        let alertController = UIAlertController(title: "", message: "\(from) wants to chat with you.", preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { (action:UIAlertAction) in
            connector.service.invitationHandler(true, connector.service.session)
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction) in
            connector.service.invitationHandler(false, connector.service.session)
        }
        
        alertController.addAction(acceptAction)
        alertController.addAction(declineAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connector.service.foundPeers.count
    }

    
   /*override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Found Peers"
    } */
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath)
        
        cell.textLabel?.text = connector.service.foundPeers[indexPath.row].displayName
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeer = connector.service.foundPeers[indexPath.row] as MCPeerID
        connector.service.serviceBrowser.invitePeer(selectedPeer, to: connector.service.session, withContext: nil, timeout: 20)
        tableView.deselectRow(at: indexPath, animated: true)
    }


}

