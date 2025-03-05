//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by XECE on 18.02.2025.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class ProfileViewController: UIViewController {

    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var imagePhoto: UIImageView!
    
 
    override func viewDidLoad() {
           super.viewDidLoad()
           fetchProfileData()
       }
       
    private func fetchProfileData() {
           guard let userId = Auth.auth().currentUser?.uid else {
               print("Hata: Kullanıcı giriş yapmamış!")
               return
           }
           
           let ref = Database.database().reference().child("Users").child(userId)
           ref.observeSingleEvent(of: .value) { snapshot in
               guard let data = snapshot.value as? [String: Any] else {
                   print("Hata: Kullanıcı verisi çekilemedi!")
                   return
               }
               
               let name = data["name"] as? String ?? "Bilinmeyen"
               let profileImageURL = data["photoUrl"] as? String ?? ""

               DispatchQueue.main.async {
                   self.labelInfo.text = name
               }

               if let url = URL(string: profileImageURL), !profileImageURL.isEmpty {
                   print("✅ Profil resmi URL: \(profileImageURL)")  // 📌 Debug için eklendi
                   
                   DispatchQueue.global().async {
                       if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                           DispatchQueue.main.async {
                               self.imagePhoto.image = image
                           }
                       } else {
                           print("❌ Hata: Profil resmi yüklenemedi!")  // 📌 Debug için eklendi
                       }
                   }
               } else {
                   print("⚠️ Uyarı: Kullanıcının profil fotoğrafı URL’si boş!")  // 📌 Debug için eklendi
               }
           }
       }

        
    @IBAction func deleteBttn(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: "Your account will be permanently deleted.", preferredStyle: .alert)
                     
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                    self.deleteAccount()
                }))
                     
                present(alert, animated: true)
            }

            private func deleteAccount() {
                guard let user = Auth.auth().currentUser else { return }
                let userId = user.uid
                let ref = Database.database().reference().child("Users").child(userId)

                ref.removeValue { error, _ in
                    if let error = error {
                        print("Hata: Kullanıcı verisi silinemedi - \(error.localizedDescription)")
                        return
                    }

                    user.delete { [weak self] error in
                        if let error = error {
                            print("Hata: Firebase Authentication hesabı silinemedi - \(error.localizedDescription)")
                            return
                        }

                        self?.navigateToSignUp()
                    }
                }
            }

            private func navigateToSignUp() {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let signUpVC = storyboard.instantiateViewController(withIdentifier: "signUpViewController") as? UIViewController else { return }
                
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = scene.windows.first else { return }
                
                window.rootViewController = signUpVC
                window.makeKeyAndVisible()
            }
        }
