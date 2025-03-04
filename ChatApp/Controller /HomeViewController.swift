//
//  HomeViewController.swift
//  ChatApp
//
//  Created by XECE on 18.02.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var users = [User]()
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchUsers()
    }
    
    private func fetchUsers() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").getDocuments { [weak self] snapshot, error in
            guard let self = self, error == nil, let documents = snapshot?.documents else { return }
            
            self.users = documents.compactMap { doc in
                let data = doc.data()
                guard let uid = data["uid"] as? String, let name = data["name"] as? String, let photoUrl = data["photoUrl"] as? String else { return nil }
                return uid != currentUserID ? User(uid: uid, name: name, photoUrl: photoUrl) : nil
            }
            
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        if let signInVC = storyboard?.instantiateViewController(withIdentifier: "signInViewController") {
            signInVC.modalPresentationStyle = .fullScreen
            present(signInVC, animated: true)
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath)
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        
        if let url = URL(string: user.photoUrl) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatVC = storyboard?.instantiateViewController(withIdentifier: "chatViewController") as! ChatViewController
        chatVC.recipientName = users[indexPath.row].name
        chatVC.recipientUid = users[indexPath.row].uid
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

struct User {
    let uid: String
    let name: String
    let photoUrl: String
}
