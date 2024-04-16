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
            TextField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Connect to server") {
                self.netLogicSession.setupConnection()
                
            }
            Button("Login") {
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
