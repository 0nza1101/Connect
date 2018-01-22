//
//  ChatRoomViewController.swift
//  Connect
//
//  Created by Jordan on 28/12/2017.
//  Copyright © 2017 Jordan. All rights reserved.
//

import UIKit
import MessageKit
import CoreLocation
import MultipeerConnectivity


class ChatRoomViewController: MessagesViewController {
    
    var recipientUserName: String = ""
    var locationManager: CLLocationManager = CLLocationManager()
    var locationMsgUid: String = ""
    var imageMessageId: String = ""
    var messagesArray: [MessageType] = []
    var recipientAvatar: UIImage = #imageLiteral(resourceName: "default_profile_pic")

    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        locationManager.delegate = self
        
        setupMessageBarUI()
        
        scrollsToBottomOnKeybordBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + "profile_picture.jpg"
        if let image = UIImage(contentsOfFile: path) {
            connector.send(avatar: image)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = recipientUserName
        
        connector.service.dataReceived = dataReceived
        
        print("DATARECEIVED BIND")
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            connector.send(disconnect: "disconnect")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
        if self.isMovingFromParentViewController {
            connector.service.session.disconnect()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupMessageBarUI(){
        defaultStyle()
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.isTranslucent = false
        messageInputBar.inputTextView.backgroundColor = .clear
        messageInputBar.inputTextView.layer.borderWidth = 0
        let items =
            [makeButton(named: "ic_camera").onTouchUpInside { _ in
                self.openCameraAction()
            },
            makeButton(named: "ic_library").onTouchUpInside { _ in
                self.openGalleryAction()
            },
            makeButton(named: "pin").onTouchUpInside { _ in
                self.determineMyCurrentLocation()
            },
            makeButton(named: "ic_videocall").onTouchUpInside { _ in
                connector.send(videoCall: "invitation")
            },
            .flexibleSpace,
            messageInputBar.sendButton
                .configure {
                    $0.layer.cornerRadius = 8
                    $0.layer.borderWidth = 1.5
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.setTitleColor(.white, for: .normal)
                    $0.setTitleColor(.white, for: .highlighted)
                    $0.setSize(CGSize(width: 52, height: 30), animated: true)
                }.onDisabled {
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.backgroundColor = .white
                }.onEnabled {
                    $0.backgroundColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
                    $0.layer.borderColor = UIColor.clear.cgColor
                }.onSelected {
                    // We use a transform becuase changing the size would cause the other views to relayout
                    $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }.onDeselected {
                    $0.transform = CGAffineTransform.identity
            }]
        
        // We can change the container insets if we want
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        // Since we moved the send button to the bottom stack lets set the right stack width to 0
        messageInputBar.setRightStackViewWidthConstant(to: 0, animated: true)
        
        // Finally set the items
        messageInputBar.setStackViewItems(items, forStack: .bottom, animated: true)
    }
    
    //MARK: HELPERS
    func defaultStyle() {
        let newMessageInputBar = MessageInputBar()
        newMessageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        newMessageInputBar.delegate = self
        messageInputBar = newMessageInputBar
        reloadInputViews()
    }
    
    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
            }.onSelected {
                $0.tintColor = .lightGray
            }.onDeselected {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
            }
    }
    
    func videoCallAlert(from: String){
        let alertController = UIAlertController(title: "📹", message: "\(from) wants to start a video call with you.", preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "📞 Accept", style: .default) { (action:UIAlertAction) in
            connector.send(videoCall: "accepted")
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromTop
            self.navigationController?.view.layer.add(transition, forKey: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.navigationController?.pushViewController(storyboard.instantiateViewController(withIdentifier: "liveVideo"), animated: false)
        }
        
        let declineAction = UIAlertAction(title: "🚫 Decline", style: .default) { (action:UIAlertAction) in
            //connector.send(videoCall: "declined")
        }
        
        alertController.addAction(acceptAction)
        alertController.addAction(declineAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func dataReceived(data: Data, peer: MCPeerID) {
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]
        
        if let avatar = dataDictionary["avatar"] {
            recipientAvatar = avatar as! UIImage
        }
        
        if let text = dataDictionary["text"] {
            let sender = Sender(id: peer.displayName, displayName: peer.displayName)
            let message = MockMessage(text: text as! String, sender: sender, messageId: UUID().uuidString, date: Date())
            messagesArray.append(message)
            messagesCollectionView.insertSections([messagesArray.count - 1])
            messagesCollectionView.scrollToBottom()
        }
        
        if let location = dataDictionary["location"] {
            let sender = Sender(id: peer.displayName, displayName: peer.displayName)
            let message = MockMessage(location: location as! CLLocation, sender: sender, messageId: UUID().uuidString, date: Date())
            messagesArray.append(message)
            messagesCollectionView.insertSections([messagesArray.count - 1])
            messagesCollectionView.scrollToBottom()
        }
        
        if let image = dataDictionary["image"] {
            let sender = Sender(id: peer.displayName, displayName: peer.displayName)
            let message = MockMessage(image: image as! UIImage, sender: sender, messageId: UUID().uuidString, date: Date())
            messagesArray.append(message)
            messagesCollectionView.insertSections([messagesArray.count - 1])
            messagesCollectionView.scrollToBottom()
        }
    
        if let videoCall = dataDictionary["videoCall"] {
            if(videoCall as! String == "invitation"){
               videoCallAlert(from: peer.displayName)
            }
            else{
               let transition = CATransition()
               transition.duration = 0.5
               transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
               transition.type = kCATransitionMoveIn
               transition.subtype = kCATransitionFromTop
               self.navigationController?.view.layer.add(transition, forKey: nil)
               let storyboard = UIStoryboard(name: "Main", bundle: nil)
               self.navigationController?.pushViewController(storyboard.instantiateViewController(withIdentifier: "liveVideo"), animated: false)
            }
        }

        if (dataDictionary["disconnect"] != nil) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK : MESSAGE KIT SETUP/DELEGATE 💬
extension ChatRoomViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return Sender(id: connector.ownPeerID.displayName, displayName: connector.ownPeerID.displayName)
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return  messagesArray.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messagesArray[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        struct ConversationDateFormatter {
            static let formatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter
            }()
        }
        let formatter = ConversationDateFormatter.formatter
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func avatar(for message: MessageType, at  indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Avatar {
        // Show the profile picture of the sender in his avatar view || DOES NOT WORK!
        let fileName = "profile_picture.jpg"
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + fileName
        if message.sender.displayName == currentSender().displayName {
            if let image = UIImage(contentsOfFile: path) {
                return Avatar(image: image, initials: "?")
            }
        } else {
            return Avatar(image: recipientAvatar, initials: "?")
        }
        return Avatar(image: #imageLiteral(resourceName: "default_profile_pic"), initials: "?")
    }
    
}

extension ChatRoomViewController: MessageInputBarDelegate {
    
    //MARK : SEND MESSAGE WHEN SEND BUTTON PRESSED 🚀
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String){
        connector.send(text: text)//Send the message to the other peer
        
        let message = MockMessage(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date())
        messagesArray.append(message)
        inputBar.inputTextView.text = String()
        messagesCollectionView.insertSections([messagesArray.count - 1])
        messagesCollectionView.scrollToBottom()
    }
}

extension ChatRoomViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey : Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date]
    }
    
    // MARK: - All Messages
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    /*func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
    }*/
}

extension ChatRoomViewController: MessagesLayoutDelegate {
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 200
    }
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        if isFromCurrentSender(message: message) {
            return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)
        } else {
            return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
        }
    }
    
    func cellTopLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        } else {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        }
    }
    
    func cellBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        } else {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        }
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: messagesCollectionView.bounds.width, height: 10)
    }
    
    func avatarPosition(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> AvatarPosition {
        return AvatarPosition(horizontal: .natural, vertical: .messageBottom)
    }
}

extension ChatRoomViewController: MessageCellDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
}

//MARK : LOCATION SETUP/DELEGATE 📍
extension ChatRoomViewController: CLLocationManagerDelegate {
    
    func determineMyCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
            
            let message = MockMessage(text: "🕙📍", sender: self.currentSender(), messageId: UUID().uuidString, date: Date())
            locationMsgUid = message.messageId
            messagesArray.append(message)
            messagesCollectionView.insertSections([messagesArray.count - 1])
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.first {
            print(userLocation.coordinate)
            
            connector.send(location: userLocation)
            
            let message = MockMessage(location: userLocation, sender: self.currentSender(), messageId: UUID().uuidString, date: Date())
            for i in 0..<messagesArray.count {
                if (messagesArray[i].messageId ==  locationMsgUid) {
                    messagesArray[i] = message
                    locationMsgUid = ""
                }
            }
            messagesCollectionView.reloadSections([messagesArray.count - 1])
            messagesCollectionView.scrollToBottom()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

extension ChatRoomViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCameraAction() {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.cameraFlashMode = .off
            imagePicker.cameraCaptureMode = .photo
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func openGalleryAction() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        connector.send(image: newImage)
        
        let message = MockMessage(image: newImage, sender: currentSender(), messageId: UUID().uuidString, date: Date())
        messagesArray.append(message)
        messagesCollectionView.insertSections([messagesArray.count - 1])
        messagesCollectionView.scrollToBottom()
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
