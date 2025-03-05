//
//  HomeViewController.swift
//  ChatApp
//
//  Created by XECE on 18.02.2025.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase




class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var users = [User]()
       
       private var currentUserID: String? {
           return Auth.auth().currentUser?.uid
       }
       
       override func viewDidLoad() {
           super.viewDidLoad()
           setupTableView()
           setupLogoutButton()
           fetchUsers()
       }
       
       private func setupTableView() {
           tableView.delegate = self
           tableView.dataSource = self
           tableView.rowHeight = 94
           
           
           tableView.estimatedRowHeight = UITableView.automaticDimension
           tableView.separatorStyle = .singleLine
       }
       
       private func setupLogoutButton() {
           let logoutButton = UIButton(type: .system)
           logoutButton.setTitle("Logout", for: .normal)
           logoutButton.setTitleColor(UIColor.red, for: .normal)
           logoutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
           logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
           
           let barButtonItem = UIBarButtonItem(customView: logoutButton)
           self.navigationItem.rightBarButtonItem = barButtonItem
       }
       
       func fetchUsers() {
           let ref = Database.database().reference().child("Users")
           
           ref.observeSingleEvent(of: .value) { [weak self] (snapshot) in
               guard let self = self else { return }
               if !snapshot.exists() {
                   print("Kullanıcı verisi bulunamadı!")
                   return
               }

               var fetchedUsers: [User] = []
               
               for child in snapshot.children {
                   if let childSnapshot = child as? DataSnapshot,
                      let data = childSnapshot.value as? [String: Any] {
                       let user = User(dictionary: data)
                       
                       if user.uid == self.currentUserID {
                           continue  // Kendi hesabını listeleme
                       }
                       
                       fetchedUsers.append(user)
                   }
               }
               
               self.users = fetchedUsers
               DispatchQueue.main.async {
                   self.tableView.reloadData()
               }
           }
       }
       
       @objc func logoutTapped() {
           do {
               try Auth.auth().signOut()
               if let signInVC = storyboard?.instantiateViewController(withIdentifier: "signInViewController") {
                   guard let window = UIApplication.shared.windows.first else { return }
                   window.rootViewController = signInVC
                   window.makeKeyAndVisible()
               }
           } catch {
               print("Logout Error: \(error.localizedDescription)")
           }
       }
   }

   
   extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return users.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as? HomeTableViewCell else {
               return UITableViewCell()
           }

           let user = users[indexPath.row]
           cell.configureCell(name: user.name, imageUrl: user.photoUrl)

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

   
   extension HomeViewController: UITabBarDelegate {
       func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
           switch item.tag {
           case 0:
               let chatVC = storyboard?.instantiateViewController(withIdentifier: "chatViewController") as! ChatViewController
               navigationController?.pushViewController(chatVC, animated: true)
           case 1:
               let profileVC = storyboard?.instantiateViewController(withIdentifier: "profileViewController") as! ProfileViewController
               navigationController?.pushViewController(profileVC, animated: true)
           case 2:
               let inboxVC = storyboard?.instantiateViewController(withIdentifier: "InboxViewController") as! InboxViewController
               navigationController?.pushViewController(inboxVC, animated: true)
           default:
               break
           }
       }
   }
