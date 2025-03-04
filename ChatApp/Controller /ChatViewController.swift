//
//  ChatViewController.swift
//  ChatApp
//
//  Created by XECE on 18.02.2025.
//

import UIKit
import Firebase
import FirebaseAuth
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var textMessage: UITextField!
    @IBOutlet weak var viewSendBottomConst: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    private var messages = [Message]()
    private let databaseRef = Database.database().reference()
    private let auth = Auth.auth()
    var recipientName = ""
    var recipientUid = ""
    private var inboxKey = ""
    private var lastMessageKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchChatData()
    }
    
    private func setupUI() {
        navBar.topItem?.title = recipientName
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "chatTableViewCell")
        tableView.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func fetchChatData() {
        guard let currentUserUid = auth.currentUser?.uid else { return }
        
        databaseRef.child("chat_inbox").queryOrdered(byChild: "senderUid").queryEqual(toValue: currentUserUid).observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                if let snap = child as? DataSnapshot, let data = snap.value as? [String: Any],
                   let recipientUid = data["recipientUid"] as? String, recipientUid == self.recipientUid {
                    self.inboxKey = data["inboxKey"] as? String ?? ""
                    self.fetchMessages()
                    return
                }
            }
            self.createChatInbox()
        }
    }
    
    private func createChatInbox() {
        guard let currentUserUid = auth.currentUser?.uid else { return }
        inboxKey = databaseRef.childByAutoId().key ?? ""
        
        let chatInboxData = ["inboxKey": inboxKey, "senderUid": currentUserUid, "recipientUid": recipientUid, "isRead": "0"]
        databaseRef.child("chat_inbox").childByAutoId().setValue(chatInboxData)
        databaseRef.child("chat_inbox").childByAutoId().setValue(["inboxKey": inboxKey, "senderUid": recipientUid, "recipientUid": currentUserUid, "isRead": "0"])
        
        databaseRef.child("chat_last").childByAutoId().setValue(["inboxKey": inboxKey, "messageKey": ""]) { error, snapshot in
            self.lastMessageKey = snapshot.key ?? ""
        }
    }
    
    private func fetchMessages() {
        databaseRef.child("chats").queryOrdered(byChild: "inboxKey").queryEqual(toValue: inboxKey).observe(.childAdded) { snapshot in
            if let data = snapshot.value as? [String: Any], let senderUid = data["senderUid"] as? String, let message = data["message"] as? String {
                self.messages.append(Message(senderUid: senderUid, message: message))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            }
        }
    }
    
    private func scrollToBottom() {
        if messages.isEmpty { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        guard let messageText = textMessage.text, !messageText.isEmpty, let senderUid = auth.currentUser?.uid else { return }
        
        let messageData = ["inboxKey": inboxKey, "senderUid": senderUid, "message": messageText]
        let messageRef = databaseRef.child("chats").childByAutoId()
        messageRef.setValue(messageData) { _, snapshot in
            self.textMessage.text = ""
            self.databaseRef.child("chat_last").child(self.lastMessageKey).child("messageKey").setValue(snapshot.key ?? "")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatTableViewCell", for: indexPath) as! ChatTableViewCell
        let message = messages[indexPath.row]
        cell.configure(with: message, isIncoming: message.senderUid != auth.currentUser?.uid)
        return cell
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            viewSendBottomConst.constant = -keyboardSize.height + view.safeAreaInsets.bottom
            scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        viewSendBottomConst.constant = 0
    }
}

struct Message {
    let senderUid: String
    let message: String
}


