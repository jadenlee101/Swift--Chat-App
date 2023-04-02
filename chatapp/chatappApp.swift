//
//  chatappApp.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-03-23.
//

import SwiftUI
import Firebase

@main
struct chatappApp: App {
    
    init(){
        FirebaseApp.configure()
        print("fire base is con figured")
    }
    var body: some Scene {
        WindowGroup {
            LoginView()
            
        }
    }
}
