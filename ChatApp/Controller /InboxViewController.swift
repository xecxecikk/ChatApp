//
//  InboxViewController.swift
//  ChatApp
//
//  Created by XECE on 18.02.2025.
//

import UIKit
import Firebase
import FirebaseAuth

class InboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var list = [ListItem]()
    private var databaseRef = Database.database().reference()
    private var auth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInbox()
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func loadInbox() {
        guard let currentUserID = auth.currentUser?.uid else { return }
        
        databaseRef.child(Child.CHAT_INBOX)
            .queryOrdered(byChild: "senderUid")
            .queryEqual(toValue: currentUserID)
            .observe(.value) { [weak self] snapshot in
                guard let self = self else { return }
                self.list.removeAll()
                
                let group = DispatchGroup()
                
                for child in snapshot.children.compactMap({ $0 as? DataSnapshot }) {
                    let dict = child.value as? [String: Any] ?? [:]
                    
                    guard let recipientUid = dict["recipientUid"] as? String,
                          let isRead = dict["isRead"] as? String else { continue }
                    
                    group.enter()
                    self.fetchUserInfo(uid: recipientUid) { name, photoUrl in
                        self.list.append(ListItem(rowKey: child.key, uid: recipientUid, name: name, photoUrl: photoUrl, isRead: isRead))
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.tableView.reloadData()
                }
            }
    }
    
    private func fetchUserInfo(uid: String, completion: @escaping (String, String) -> Void) {
        databaseRef.child(Child.USERS)
            .queryOrdered(byChild: "uid")
            .queryEqual(toValue: uid)
            .observeSingleEvent(of: .value) { snapshot in
                if let userSnap = snapshot.children.compactMap({ $0 as? DataSnapshot }).first,
                   let dict = userSnap.value as? [String: Any],
                   let name = dict["name"] as? String,
                   let photoUrl = dict["photoUrl"] as? String {
                    completion(name, photoUrl)
                }
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
        let info = list[indexPath.row]
        
        cell.labelName.text = info.name
        Helper.imageLoad(imageView: cell.imagePhoto, url: info.photoUrl)
        cell.imagePhoto.layer.cornerRadius = cell.imagePhoto.frame.width / 2
        cell.imagePhoto.layer.borderWidth = 2.0
        cell.imagePhoto.layer.borderColor = (info.isRead == "1") ? UIColor.red.cgColor : UIColor.white.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = list[indexPath.row]
        
        databaseRef.child(Child.CHAT_INBOX).child(selectedItem.rowKey).child("isRead").setValue("0")
        
        let chatVC = storyboard?.instantiateViewController(withIdentifier: "chatViewController") as! ChatViewController
        chatVC.recipientUid = selectedItem.uid
        chatVC.recipientName = selectedItem.name
        present(chatVC, animated: true)
    }
    
    struct ListItem {
        let rowKey: String
        let uid: String
        let name: String
        let photoUrl: String
        let isRead: String
    }
}
