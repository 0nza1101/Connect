//
//  MPCService.swift
//  Connect
//
//  Created by Jordan on 24/12/2017.
//  Copyright © 2017 Jordan. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum ServiceError: Error {
    case noConnectedPeers
}

internal class MPCService: NSObject {
    
    typealias PeersChangedCallback = (_ peers: [MCPeerID]) -> Void
    typealias DataReceivedCallback = (_ data: Data, _ peer: MCPeerID) -> Void
    typealias InvitationReceivedCallback = (_ from: String) -> Void
    typealias ConnectedWithCallback = (_ peer: MCPeerID) -> Void
    typealias FoundedPeersCallback = () -> Void
    typealias LostPeersCallback = () -> Void
    
    // This callback will be called when the session receives data from one of the connected peers.
    var dataReceived: DataReceivedCallback?
    // This callback will be called when the list of connected peers changes.
    var peersChanged: PeersChangedCallback?
    // This callback will be called when the user receive invitation from a peer.
    var invitationReceived: InvitationReceivedCallback?
    // This callback will be called when the user is connected with a peer.
    var connectedWith: ConnectedWithCallback?
    // This callback will be called when we found some peers.
    var foundedPeers: FoundedPeersCallback?
    // This callback will be called when we lost some peers.
    var lostPeers: LostPeersCallback?
    
    /// Initializes the service manager with a given service type and peerID.
    ///
    /// - Parameters:
    ///   - type: A MultiPeer service type. Service type must be a unique
    ///     string, at most 15 characters long and can contain only ASCII lowercase
    ///     letters, numbers and hyphens.
    ///   - peerID: The user's own peer id to be shown to others.
    init(with type: String, as peerID: MCPeerID) {
        self.type = type
        self.ownPeer = peerID
        super.init()
    }
    
    // The type that is used for advertising and browsing the service.
    let type: String
    
    // The peer id of the local user.
    let ownPeer: MCPeerID
    
    //Peer that we found around
    var foundPeers = [MCPeerID]()
    
    // The list of currently connected peers (peers in state MCSessionState.connected).
    var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }
    
     var invitationHandler: ((Bool, MCSession?)->Void)!
    
    /// lazy to make sure we utilize only the memory when we need it.
    // Session used for communicating with peers.
    lazy var session: MCSession = {
        let session = MCSession(peer: self.ownPeer, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    // Advertises our peer to others.
    lazy var serviceAdvertiser: MCNearbyServiceAdvertiser = {
        let advertiser = MCNearbyServiceAdvertiser(peer: self.ownPeer, discoveryInfo: nil, serviceType: self.type)
        advertiser.delegate = self
        return advertiser
    }()
    
    // Browses for other peers.
    lazy var serviceBrowser: MCNearbyServiceBrowser = {
        let browser = MCNearbyServiceBrowser(peer: self.ownPeer, serviceType: self.type)
        browser.delegate = self
        return browser
    }()
    
    // Starts advertising & browsing
    func startSvc() {
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }
    
    // Stops advertising & browsing
    func stopSvc() {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    // Tries to send given data to all connected peers.
    // - Parameter data: data to be sent to peers.
    func send(data: Data) throws {
        guard session.connectedPeers.count > 0 else {
            throw ServiceError.noConnectedPeers
        }
        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
    
    deinit {
        // Stop MultiPeer Stuff
        stopSvc()
    }
    
}

/** Delegate **/

private extension MPCService {
    func notifyReceive(data: Data, from peer: MCPeerID) {
        dataReceived?(data, peer)
    }
    
    func notifyPeersChanged(peers: [MCPeerID]) {
        peersChanged?(peers)
    }
    
    func notifyInvitationReceived(name: String) {
        invitationReceived?(name)
    }

    func notifyConnectedWith(peer: MCPeerID) {
        connectedWith?(peer)
    }
    
    func notifyFoundedPeers() {
        foundedPeers?()
    }
    
    func notifyLostPeers() {
        lostPeers?()
    }
}

// MCNearbyServiceAdvertiserDelegate
extension MPCService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        // Automatically accept all invitations that we get
        //invitationHandler(true, session)
        self.invitationHandler = invitationHandler
        notifyInvitationReceived(name: peerID.displayName)
        print("Received invitation from " + peerID.displayName)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
}

// MCNearbyServiceBrowserDelegate
extension MPCService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Automatically invite all peers we find
        //browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        foundPeers.append(peerID)
        notifyFoundedPeers()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, peer) in foundPeers.enumerated(){
            if peer == peerID {
                foundPeers.remove(at: index)
                break
            }
        }
        notifyLostPeers()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
}

// MCSessionDelegate
extension MPCService: MCSessionDelegate {
    // Called when a connected peer changes state (for example, goes offline)
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case MCSessionState.connected:
            print("Connected to session: \(session)")
            notifyConnectedWith(peer: peerID)
        case MCSessionState.connecting:
            print("Connecting to session: \(session)")
        default:
            print("Did not connect to session: \(session)")
        }
        notifyPeersChanged(peers: connectedPeers)
    }
    // Called when a peer sends an NSData to us
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.notifyReceive(data: data, from: peerID)
        }
    }
    // Called when a peer establishes a stream with us
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    // Called when a peer starts sending a file to us
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    // Called when a file has finished transferring from another peer
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    // Called when a certificate has been received
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
