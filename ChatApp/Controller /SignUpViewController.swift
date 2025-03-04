//
//  SignUpViewController.swift
//  ChatApp
//
//  Created by XECE on 27.01.2025.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore


class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    @IBOutlet weak var textPasswordRepetition: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textMail: UITextField!
    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var imagePhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()
    }
    
    private func setupImagePicker() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openGallery))
        imagePhoto.isUserInteractionEnabled = true
        imagePhoto.addGestureRecognizer(tapGesture)
    }
    

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func register(_ sender: Any) {
        guard let name = textName.text, !name.isEmpty,
              let mail = textMail.text, !mail.isEmpty,
              let password = textPassword.text, !password.isEmpty,
              let passwordRepetition = textPasswordRepetition.text, !passwordRepetition.isEmpty else {
            showAlert(message: "Fields can't be empty")
            return
        }
        
        guard password == passwordRepetition else {
            showAlert(message: "Passwords don't match")
            return
        }
        
        registerUser(name: name, mail: mail, password: password)
    }
    
    private func registerUser(name: String, mail: String, password: String) {
        let auth = Auth.auth()
        let databaseRef = Database.database().reference()
        let storageRef = Storage.storage().reference()
        
        auth.createUser(withEmail: mail, password: password) { [weak self] (authResult, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            
            guard let userId = auth.currentUser?.uid else {
                self.showAlert(message: "User ID not found.")
                return
            }
            
            self.uploadProfileImage(storageRef: storageRef, userId: userId) { imageUrl in
                let userData: [String: Any] = [
                    "name": name,
                    "mail": mail,
                    "uid": userId,
                    "photoUrl": imageUrl ?? ""
                ]
                
                databaseRef.child("Users").child(userId).setValue(userData) { error, _ in
                    if let error = error {
                        self.showAlert(message: error.localizedDescription)
                    } else {
                        self.navigateToHome()
                    }
                }
            }
        }
    }
    
   
    private func uploadProfileImage(storageRef: StorageReference, userId: String, completion: @escaping (String?) -> Void) {
        guard let imageData = imagePhoto.image?.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        let imageName = "\(userId).jpg"
        let imageRef = storageRef.child("profile_images").child(imageName)
        
        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                completion(nil)
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
   
    private func navigateToHome() {
        guard let homeVC = storyboard?.instantiateViewController(withIdentifier: "homeViewController") as? HomeViewController else {
            showAlert(message: "HomeViewController not found.")
            return
        }
        present(homeVC, animated: true, completion: nil)
    }
    
  
    @objc private func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imagePhoto.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
   
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
