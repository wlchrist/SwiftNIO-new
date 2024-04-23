//
//  ContentView.swift
//  SwiftNIO
//
//  Created by Warren Christian on 3/25/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var netLogicSession = networkLogic()
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var loginStatus: String = ""
    
    var body: some View {
        
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Login/Connect") {
                self.netLogicSession.setupConnection()
                netLogicSession.sendLogin(username: username, password: password)
                
                
            }
            
            Text(netLogicSession.statusMessage)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
