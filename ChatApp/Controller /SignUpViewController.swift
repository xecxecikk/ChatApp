//
//  SignUpViewController.swift
//  ChatApp
//
//  Created by XECE on 27.01.2025.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import PhotosUI


class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    

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
                  showAlert(message: "Please fill in all fields.")
                  return
              }

              guard password == passwordRepetition else {
                  showAlert(message: "Passwords don't match.")
                  return
              }
              
              guard let selectedImage = imagePhoto.image else {
                  showAlert(message: "Please select a profile photo.")
                  return
              }

              

              uploadProfileImage(selectedImage) { [weak self] imageUrl in
                  guard let self = self else { return }
                  
                  self.registerUser(name: name, mail: mail, password: password, photoUrl: imageUrl)
              }
          }
          
    private func registerUser(name: String, mail: String, password: String, photoUrl: String?) {
        let auth = Auth.auth()
        let databaseRef = Database.database().reference()
        
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
            
            let userData: [String: Any] = [
                "name": name,
                "mail": mail,
                "uid": userId,
                "photoUrl": photoUrl ?? "" 
            ]
            
            
            
            databaseRef.child("Users").child(userId).setValue(userData) { error, _ in
                if let error = error {
                   
                    self.showAlert(message: error.localizedDescription)
                } else {
                  
                    self.showAlert(message: "Registration successful. Please proceed to the login page.") {
                        self.navigateToHome()
                    }
                }
            }
        }
    }

          
    private func uploadProfileImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
          
            completion(nil)
            return
        }
        
        let userId = Auth.auth().currentUser?.uid ?? UUID().uuidString
        let storageRef = Storage.storage().reference()
        let imageName = "\(userId).jpg"
        let imageRef = storageRef.child("profile_images").child(imageName)
        
       
        
        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
               
                completion(nil)
                return
            }
            
          
            
            imageRef.downloadURL { url, error in
                if let error = error {
                   
                    completion(nil)
                } else {
                    let photoUrl = url?.absoluteString
                  
                    completion(photoUrl)
                }
            }
        }
    }

          
          private func navigateToHome() {
              guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "signInViewController") as? SignInViewController else {
                  showAlert(message: "SignInViewController not found.")
                  return
              }
              present(loginVC, animated: true, completion: nil)
          }
          
          @objc private func openGallery() {
              var config = PHPickerConfiguration()
              config.selectionLimit = 1
              config.filter = .images
              
              let picker = PHPickerViewController(configuration: config)
              picker.delegate = self
              present(picker, animated: true, completion: nil)
          }
          
          func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
              picker.dismiss(animated: true, completion: nil)
              
              guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
              
              itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                  guard let self = self, let selectedImage = image as? UIImage else { return }
                  
                  DispatchQueue.main.async {
                      self.imagePhoto.image = selectedImage
                    
                  }
              }
          }
          
          private func showAlert(message: String, completion: (() -> Void)? = nil) {
              let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                  completion?()
              })
              present(alert, animated: true, completion: nil)
          }
      }
