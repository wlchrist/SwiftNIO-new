//
//  ContentView.swift
//  SwiftNIO
//
//  Created by Warren Christian on 3/25/24.
//

import SwiftUI

struct ContentView: View {
    
    var netLogicSession = networkLogic()
    var body: some View {
        VStack {
            Button("Connect to server") {
                self.netLogicSession.setupConnection()
                
            }
                
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
