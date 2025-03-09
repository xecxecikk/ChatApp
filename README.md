# 📱 ChatApp

ChatApp is a real-time messaging application built with Swift and powered by Firebase Firestore. The app enables users to sign up, log in, and exchange messages dynamically.

## ✨ Features

### 🔐 Authentication
Users can sign up and log in using Firebase Authentication.
Users can log out securely.

### 💬 Real-Time Chat
Send and receive messages instantly using Firestore.
Messages are displayed dynamically in a table view.

### 📤 Message Storage
Messages are stored in Firebase Firestore in real-time.
Each message contains:
Sender's email
Message content

### Timestamp
🛠 Firebase Firestore Integration
Firestore is used to store and retrieve chat messages.
Data updates instantly when a new message is sent.
🛠️ Tools & Technologies Used

## Technology	Purpose
##### Swift
Programming language for the app
##### UIKit
UI framework for designing the interface
FirebaseAuth
#####
User authentication (sign-in, sign-up, logout)
 ##### FirebaseFirestore
 Real-time database for chat messages
##### Swift Package Manager (SPM)	
Dependency management
Foundation	Core functionalities like date and string handling

### 📂 Code Overview
##### SignInViewController.swift
Handles user authentication.

🔹 Key Functions:
signInClicked – Logs in an existing user.
signUpClicked – Registers a new user.

##### ChatViewController.swift
Manages real-time chat messages.

🔹 Key Functions:
sendMessage – Saves the message in Firestore.
getMessagesFromFirestore – Fetches chat messages and updates the UI dynamically.
tableView(_:cellForRowAt:) – Configures message cells.
MessageTableViewCell.swift
Custom table view cell for displaying messages.

##### SettingsViewController.swift
Handles user logout.

🔹 Key Function:
logOutClicked – Logs out the user and redirects to the login screen.



### 🚀 Setup Instructions

Prerequisites:
Install Xcode (version 14.0 or later recommended).
Create a Firebase project and configure it for iOS.
Enable Firebase Authentication (Email/Password).
Enable Firebase Firestore as the database.
Download GoogleService-Info.plist from the Firebase Console and add it to your project.
Installation:
Clone the repository:
git clone https://github.com/xecxecikk/ChatApp.git
cd ChatApp
Open the project in Xcode.
Install dependencies via Swift Package Manager (SPM).
Run the project on a simulator or physical device.

### 🎯 Future Improvements

Push notifications for new messages.
Read receipts for delivered and seen messages.
User profile customization (profile pictures, status updates).


### 📞 Contact

For any issues or suggestions, feel free to open an issue on GitHub.

![Ekran Resmi 2025-03-09 15 22 55](https://github.com/user-attachments/assets/cb5e2b07-4517-4a99-8176-6bdd5e3158b3)


https://github.com/user-attachments/assets/502670c1-01ce-4c93-9dc8-55e1b1c5ad8a



https://github.com/user-attachments/assets/bb9b3d56-9d4f-4272-b82b-4a4891d721c5

