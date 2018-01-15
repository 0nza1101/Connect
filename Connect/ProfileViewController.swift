//
//  ProfileViewController.swift
//  Connect
//
//  Created by Can Serkan on 09/01/2018.
//  Copyright © 2018 Jordan. All rights reserved.
//

import UIKit
import Foundation

class ProfileViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 3
        profilePicture.layer.borderColor = UIColor.white.cgColor
        let fileName = "profile_picture.jpg"
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + fileName
        if let image = UIImage(contentsOfFile: path) {
            profilePicture.image = image
        } else {
            profilePicture.image = #imageLiteral(resourceName: "default_profile_pic")
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.showActionSheet))
        profilePicture.addGestureRecognizer(tap)
        profilePicture.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func showActionSheet() {
        let actionSheetController: UIAlertController = UIAlertController(title: "Please select", message: "Option to select", preferredStyle: .actionSheet)
        
        let openGalleryButtonAction = UIAlertAction(title: "Open Gallery", style: .default) { _ in
            self.openGalleryAction()
        }
        actionSheetController.addAction(openGalleryButtonAction)
        
        let openCameraButtonAction = UIAlertAction(title: "Open Camera", style: .default) { _ in
            self.openCameraAction()
        }
        actionSheetController.addAction(openCameraButtonAction)
        
        let deleteProfilePictureButtonAction = UIAlertAction(title: "Delete Profile Picture", style: .default)
        { _ in
            self.deleteProfilePicture()
        }
        actionSheetController.addAction(deleteProfilePictureButtonAction)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Canceled")
        }
        actionSheetController.addAction(cancelActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    fileprivate func deleteProfilePicture() {
        let filename = "profile_picture.jpg"
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + filename
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
            profilePicture.image = #imageLiteral(resourceName: "default_profile_pic")
        } catch _ as NSError{
            let alert = UIAlertController(title: "Cannot delete image", message: "An error has occurred. Cannot delete the profile picture", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func openCameraAction() {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.cameraCaptureMode = .photo
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func openGalleryAction() {
        imagePicker.allowsEditing = false
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
        
        profilePicture.image = newImage
        if profilePicture.image != nil {
            if let data = UIImageJPEGRepresentation(profilePicture.image!, 1.0) {
                let filename = getDocumentsDirectory().appendingPathComponent("profile_picture.jpg")
                try? data.write(to: filename)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

