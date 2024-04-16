//
//  SwiftNIOApp.swift
//  SwiftNIO
//
//  Created by Warren Christian on 3/25/24.
//

import SwiftUI
import NIO

// GOAL: Create a TCP socket connection to localhost ftp server. List each step required for a successful SwiftNIO connection.

class networkLogic: ObservableObject {
    let group: EventLoopGroup // Event loop groups, are a truncation of multiple event workers which wait for network operations.
    @Published var statusMessage: String = ""
    var channel: Channel?
    
    
    init() {
        // personal note: init can (in some cases) negate the need to declare and optional explicitly
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    }
    
    func sendString(_ command: String, channel: Channel) -> EventLoopFuture<Void> {
        let cleanString = command + "\r\n" // NOTE: string sent over socket isn't "clean"/formatted correctly. denoting a new line and return, ensures the command is complete by the time you enter a new string to be send to the FTP server
        
        let buffer = channel.allocator.buffer(string: cleanString)
        
        return channel.writeAndFlush(buffer)
        
        
    }
    
    func setupConnection() {
        let bootstrap = ClientBootstrap(group: self.group)
            .channelInitializer { channel in
                channel.pipeline.addHandlers([
                   // responseDecoder(),
                   // responseHandler(),
                   // commandEncoder(),
                   // commandSender()
                    
                ])
            }

        let connectionAttempt = bootstrap.connect(host: "localhost", port: 21)
        
        connectionAttempt.whenSuccess { channel in
            DispatchQueue.main.async {
                self.statusMessage = "Connected Successfully"
                self.channel = channel
            }
        }
        
        connectionAttempt.whenFailure { error in
            DispatchQueue.main.async {
                self.statusMessage = "Failed Connection \(error.localizedDescription)"
            }
        }
    }
    
    func sendLogin(username: String, password: String) {
        guard let channel = self.channel else {
            DispatchQueue.main.async {
                self.statusMessage = "No active pipeline to send commands through"
            }
            return
        }
        
        sendString("USER \(username)", channel: channel)
            .flatMap {
                self.sendString("PASS \(password)", channel: channel)
            }
            .whenComplete { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.statusMessage = "Login Successful"
                    case .failure:
                        self.statusMessage = "Login Failed: \(result)"
                        
                    }
                }
            }
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
