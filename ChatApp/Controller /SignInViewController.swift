//
//  ViewController.swift
//  ChatApp
//
//  Created by XECE on 27.01.2025.
//

import UIKit
import FirebaseAuth


class SignInViewController: UIViewController {
    
    
    @IBOutlet weak var mailText: UITextField!
    
    
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signIn(_ sender: Any) {
        guard let email = mailText.text, !email.isEmpty,
              let password = passwordText.text, !password.isEmpty else {
            Helper.dialogMessage(message: "Fields can't be empty", vc: self)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                Helper.dialogMessage(message: error.localizedDescription, vc: self)
                return
            }
            
            guard let _ = authResult?.user else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let homeVC = storyboard.instantiateViewController(withIdentifier: "homeViewController") as? HomeViewController {
                homeVC.modalPresentationStyle = .fullScreen
                self.present(homeVC, animated: true, completion: nil)
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
            }
            
        }
        
    }
    
}





