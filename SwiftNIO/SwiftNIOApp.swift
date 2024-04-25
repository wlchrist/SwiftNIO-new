//
//  SwiftNIOApp.swift
//  SwiftNIO
//
//  Created by Warren Christian on 3/25/24.
//

import SwiftUI
import NIO

// GOAL: Create a TCP client, which is able to connect to an FTP server, send commands and receive inbound data to be displayed to the user. 	

// SwiftNIO is an event-driven network framework, designed to absract much of the network socket paradigm away.
// 1. Event loops are "listeners" which trigger an action when parameters are met
// 2. Channels encapsulate a network socket, each channel usually runs along a figurative "channel pipeline"
// 3. Each pipeline has a set of specified inbound or outbound handlers



class networkLogic: ObservableObject {
    let group: EventLoopGroup // Event loop groups, are a truncation of multiple event workers which wait for network operations.
    @Published var statusMessage: String = ""
    @Published var serverResponse: String = ""
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
    // TODO: Add a response handler mechanism to receive updates from server
    func setupConnection() {
        let bootstrap = ClientBootstrap(group: self.group)
        
        // Add handlers here
            .channelInitializer { channel in
                channel.pipeline.addHandlers([
                   myInboundHandler()
                    
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

// Logic for decoding frames being received along pipeline, made with the help from SwiftNIOExtras
// https://github.com/apple/swift-nio-extras/blob/main/Sources/NIOExtras/LineBasedFrameDecoder.swift

public final class LineBasedFrameDecoder: ByteToMessageDecoder {
    public typealias InboundOut = String //converting data from server to a readable string
    
    
    // takes in a buffer (the data itself), returns the decoded information
    public func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        
        // 1. Query for newline char, read data on lines where a newline char exists
        // 2. Skip newline char upon reading
        if let newlineIndex = buffer.readableBytesView.firstIndex(of: UInt8(ascii:"\n")) {
            
            if let line = buffer.readString(length: newlineIndex) {
                buffer.moveReaderIndex(forwardBy: 1)
                context.fireChannelRead(self.wrapInboundOut(line))
                
                return .continue
            }
        }
        
        return .needMoreData
    }
    
}

final class ResponseHandler: ChannelInboundHandler {
    
    typealias InboundIn = String
    var responseHandler: ((String) -> Void)?
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let response = self.unwrapInboundIn(data)
        responseHandler?(response)
        print("Inbound Response: \(response)")
    }
}

class myInboundHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var byteBuffer = self.unwrapInboundIn(data)

        if let receivedString = byteBuffer.readString(length: byteBuffer.readableBytes) {
            print("Received: \(receivedString)")
        }
    }

    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
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
