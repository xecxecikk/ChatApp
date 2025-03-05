//
//  ChatViewController.swift
//  ChatApp
//
//  Created by XECE on 18.02.2025.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
   
    
    
    @IBOutlet weak var textMessage: UITextField!
    @IBOutlet weak var viewSendBottomConst: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
   
        
        private var messages = [ChatMessage]()
        private let databaseRef = Database.database().reference()
        private let auth = Auth.auth()
        
        var recipientName = ""
        var recipientUid = ""
        private var inboxKey = ""

        override func viewDidLoad() {
            super.viewDidLoad()
            
            
     

                tableView.backgroundColor = UIColor.systemGray6 // 📌 Tablo arka planını gri yap
                view.backgroundColor = UIColor.systemGray6 // 📌 Ekranın tamamını gri yap

                tableView.contentInset = UIEdgeInsets.zero // 📌 Fazladan boşluğu kaldır
                tableView.scrollIndicatorInsets = UIEdgeInsets.zero

                if #available(iOS 11.0, *) {
                    tableView.insetsContentViewsToSafeArea = false // 📌 Safe Area boşluğu olmasın
          

            setupUI()
        fetchChatData()
      
                }
            }
        private func setupUI() {
            navBar.topItem?.title = recipientName
            tableView.delegate = self
            tableView.dataSource = self
            textMessage.delegate = self
            tableView.separatorStyle = .none
            
            tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "chatTableViewCell")
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }

        private func fetchChatData() {
            guard let currentUserUid = auth.currentUser?.uid else { return }

            databaseRef.child("chat_inbox")
                .child(currentUserUid)
                .child(recipientUid)
                .observeSingleEvent(of: .value) { snapshot in
                    if let data = snapshot.value as? [String: Any], let storedInboxKey = data["inboxKey"] as? String {
                        self.inboxKey = storedInboxKey
                        self.fetchMessages()
                    } else {
                        self.createChatInbox()
                    }
                }
        }

        private func createChatInbox() {
            guard let currentUserUid = auth.currentUser?.uid, !recipientUid.isEmpty else { return }
            inboxKey = databaseRef.child("chats").childByAutoId().key ?? ""

            let chatInboxDataSender: [String: Any] = [
                "inboxKey": inboxKey,
                "senderUid": currentUserUid,
                "recipientUid": recipientUid,
                "isRead": "0",
                "lastMessage": ""
            ]

            let chatInboxDataReceiver: [String: Any] = [
                "inboxKey": inboxKey,
                "senderUid": recipientUid,
                "recipientUid": currentUserUid,
                "isRead": "0",
                "lastMessage": ""
            ]

            databaseRef.child("chat_inbox").child(currentUserUid).child(recipientUid).setValue(chatInboxDataSender)
            databaseRef.child("chat_inbox").child(recipientUid).child(currentUserUid).setValue(chatInboxDataReceiver)
        }

    private func fetchMessages() {
        databaseRef.child("chats")
            .queryOrdered(byChild: "inboxKey")
            .queryEqual(toValue: inboxKey)
            .observe(.childAdded, with: { snapshot in
                if let data = snapshot.value as? [String: Any] {
                    let message = ChatMessage(dictionary: data)
                    self.messages.append(message)

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    }
                }
            })
    }


        private func scrollToBottom() {
            if !messages.isEmpty {
                let indexPath = IndexPath(row: messages.count - 1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }


        @IBAction func sendMessage(_ sender: Any) {
            guard let messageText = textMessage.text, !messageText.isEmpty,
                          let senderUid = auth.currentUser?.uid else {
                        return
                    }
                    
                    databaseRef.child("Users").child(senderUid).observeSingleEvent(of: .value) { snapshot in
                        guard let userData = snapshot.value as? [String: Any] else { return }
                        
                        let senderName = userData["name"] as? String ?? "Unknown"
                        let senderPhotoUrl = userData["photoUrl"] as? String ?? ""
                        
                        let messageData: [String: Any] = [
                            "inboxKey": self.inboxKey,
                            "senderUid": senderUid,
                            "senderName": senderName,
                            "senderPhotoUrl": senderPhotoUrl,
                            "recipientUid": self.recipientUid,
                            "message": messageText,
                            "timestamp": ServerValue.timestamp()
                        ]
                        
                        let messageRef = self.databaseRef.child("chats").childByAutoId()
                        messageRef.setValue(messageData)
                        
                        self.textMessage.text = ""
                        
                        let lastMessageUpdate: [String: Any] = [
                            "lastMessage": messageText,
                            "timestamp": ServerValue.timestamp()
                        ]
                        
                        self.databaseRef.child("chat_inbox").child(senderUid).child(self.recipientUid).updateChildValues(lastMessageUpdate)
                        self.databaseRef.child("chat_inbox").child(self.recipientUid).child(senderUid).updateChildValues(lastMessageUpdate)
                    }
                }

                @objc private func keyboardWillShow(notification: Notification) {
                    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                        viewSendBottomConst.constant = -keyboardSize.height + view.safeAreaInsets.bottom
                        view.layoutIfNeeded()
                        scrollToBottom()
                    }
                }

                @objc private func keyboardWillHide(notification: Notification) {
                    viewSendBottomConst.constant = 0
                    view.layoutIfNeeded()
                }

                func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                    return messages.count
                }

                func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatTableViewCell", for: indexPath) as? ChatTableViewCell else {
                        fatalError("ChatTableViewCell bulunamadı!")
                    }
                    let message = messages[indexPath.row]
                    cell.configure(with: message, isIncoming: message.senderUid != auth.currentUser?.uid)
                    return cell
                }

                func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                    textField.resignFirstResponder()
                    return true
                }
            }
    
