//
//  InboxViewController.swift
//  ChatApp
//
//  Created by XECE on 8.03.2025.
//
import UIKit
import FirebaseAuth
import FirebaseDatabase

class InboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    var list = [ChatMessage]()
       var databaseRef: DatabaseReference!
       var auth: Auth!
       
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
         super.viewDidLoad()
         tableView.delegate = self
         tableView.dataSource = self

         databaseRef = Database.database().reference()
         auth = Auth.auth()

         fetchInboxData()
     }

    private func fetchInboxData() {
        guard let currentUserID = auth.currentUser?.uid else {
            print("❌ Kullanıcı giriş yapmamış!")
            return
        }

        databaseRef.child("chat_inbox").child(currentUserID).observe(.value) { snapshot in
            self.list.removeAll()
            var uniqueUsers: [String: ChatMessage] = [:]

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   var dict = snap.value as? [String: Any] {

                    let senderUid = dict["senderUid"] as? String ?? ""
                    let recipientUid = dict["recipientUid"] as? String ?? ""

                    // 🔥 **Şimdilik hiçbir filtre koymadan listeleyelim**
                    let otherUserID = (senderUid == currentUserID) ? recipientUid : senderUid

                    if uniqueUsers[otherUserID] != nil { continue }

                    self.databaseRef.child("Users").child(otherUserID).observeSingleEvent(of: .value) { userSnapshot in
                        if let userData = userSnapshot.value as? [String: Any] {
                            dict["senderName"] = userData["name"] as? String ?? "Bilinmeyen"
                            dict["senderPhotoUrl"] = userData["photoUrl"] as? String ?? ""
                        }
                        let chatInboxItem = ChatMessage(dictionary: dict)
                        uniqueUsers[otherUserID] = chatInboxItem
                        self.list = Array(uniqueUsers.values)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return list.count
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell", for: indexPath) as? InboxTableViewCell else {
             return UITableViewCell()
         }

         let inboxItem = list[indexPath.row]
         cell.configureCell(name: inboxItem.senderName, message: inboxItem.lastMessage, imageUrl: inboxItem.senderPhotoUrl)

         return cell
     }

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)

         let selectedUser = list[indexPath.row]

         let chatVC = storyboard?.instantiateViewController(withIdentifier: "chatViewController") as! ChatViewController
         chatVC.recipientName = selectedUser.senderName
         chatVC.recipientUid = selectedUser.senderUid
         navigationController?.pushViewController(chatVC, animated: true)
     }
 }
