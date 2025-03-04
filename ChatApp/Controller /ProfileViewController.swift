//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by XECE on 18.02.2025.
//

import UIKit
import Firebase
import FirebaseAuth
class ProfileViewController: UIViewController {

    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var imagePhoto: UIImageView!
    
    private let databaseRef = Database.database().reference()
    private let auth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserProfile()
    }
    
    private func loadUserProfile() {
        guard let userId = auth.currentUser?.uid else { return }
        
        databaseRef.child(Child.USERS)
            .queryOrdered(byChild: "uid")
            .queryEqual(toValue: userId)
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else { return }
                
                if let userSnap = snapshot.children.allObjects.first as? DataSnapshot,
                   let dict = userSnap.value as? [String: Any],
                   let name = dict["name"] as? String,
                   let photoUrl = dict["photoUrl"] as? String {
                    
                    DispatchQueue.main.async {
                        self.labelInfo.text = name
                        Helper.imageLoad(imageView: self.imagePhoto, url: photoUrl)
                    }
                }
            }
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
