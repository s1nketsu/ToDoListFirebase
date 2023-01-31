//
//  User.swift
//  ToDoListFirebase
//
//  Created by Полищук Александр on 30.01.2023.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let email: String
    
    init(user: Firebase.User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
