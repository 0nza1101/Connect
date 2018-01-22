//
//  ViewController.swift
//  Connect
//
//  Created by Jordan on 24/12/2017.
//  Copyright © 2017 Jordan. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import Foundation
import MultipeerConnectivity

var connector = Connector(identifier: "ynovB3", myPeerIDName: UIDevice.current.name)

class PeersTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.applyNavigationGradient(colors: [UIColor("#11998E"), UIColor("#38EF7D")])
        
        //Bind table refresh on service custom callback
        connector.service.foundedPeers = refreshTable
        connector.service.lostPeers = refreshTable
        connector.service.invitationReceived = invitationWasReceived
        connector.service.connectedWith = connectedWithPeer
        
        let settings = UIImage(named: "settings_25px_png24")!.withRenderingMode(.alwaysTemplate)
        let profileButton = UIBarButtonItem(image: settings, style: .plain, target: self, action: #selector(showProfileView))
        
        navigationItem.rightBarButtonItem = profileButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showProfileView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.navigationController?.pushViewController(storyboard.instantiateViewController(withIdentifier: "profileView"), animated: true)
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

//Applie gradients to navbar
extension UINavigationBar
{
    /// Applies a background gradient with the given colors
    func applyNavigationGradient( colors : [UIColor]) {
        var frameAndStatusBar: CGRect = self.bounds
        frameAndStatusBar.size.height += 20 // add 20 to account for the status bar
        
        setBackgroundImage(UINavigationBar.gradient(size: frameAndStatusBar.size, colors: colors), for: .default)
    }
    
    /// Creates a gradient image with the given settings
    static func gradient(size : CGSize, colors : [UIColor]) -> UIImage?
    {
        // Turn the colors into CGColors
        let cgcolors = colors.map { $0.cgColor }
        
        // Begin the graphics context
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        
        // If no context was retrieved, then it failed
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // From now on, the context gets ended if any return happens
        defer { UIGraphicsEndImageContext() }
        
        // Create the Coregraphics gradient
        var locations : [CGFloat] = [0.0, 1.0]
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgcolors as NSArray as CFArray, locations: &locations) else { return nil }
        
        // Draw the gradient
        context.drawLinearGradient(gradient, start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: size.width, y: 0.0), options: [])
        
        // Generate the image (the defer takes care of closing the context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

