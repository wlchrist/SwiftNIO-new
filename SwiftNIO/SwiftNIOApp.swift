//
//  SwiftNIOApp.swift
//  SwiftNIO
//
//  Created by Warren Christian on 3/25/24.
//

import SwiftUI
import NIO

// GOAL: Create a TCP socket connection to localhost ftp server. List each step required for a successful SwiftNIO connection.

class networkLogic {
    let group: EventLoopGroup // Event loop groups, are a truncation of multiple event workers which wait for network operations.
    init() {
        // personal note: init can (in some cases) negate the need to declare and optional explicitly
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    }
    
    func setupConnection() {
        let bootstrap = ClientBootstrap(group: self.group)
        print("1. bootstrap created")
        
        let connectionAttempt = bootstrap.connect(host: "localhost", port: 21)
        
        connectionAttempt.whenSuccess { channel in
            print("2. successful connection")
        }
        
        connectionAttempt.whenFailure { channel in
            print("2. failed connection \(channel)")
        }
    }
    
    func sendLogin() {
        
    }
}

@main
struct SwiftNIOApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
