//
//  BonjourController.swift
//  bonjour-demo-ios
//  https://github.com/jameszaghini/bonjour-demo-osx-to-ios
//  Created by James Zaghini on 12/05/2015.
//  Copyright (c) 2015 James Zaghini. All rights reserved.
//



enum PacketTag: Int {
    case Header = 1
    case Body = 2
}

protocol BonjourServerDelegate {
    func connectedTo(socket: GCDAsyncSocket!)
    func disconnected(socket: GCDAsyncSocket!)
    func handleBody(body: NSString?)
}

class BonjourServer: NSObject, NSNetServiceDelegate, NSNetServiceBrowserDelegate, GCDAsyncSocketDelegate {
    
    var delegate: BonjourServerDelegate!
    
    var service: NSNetService!
    
    var socket: GCDAsyncSocket!
    
    var connectedSockets : NSMutableArray!
    
    override init() {
        super.init()
        self.startBroadCasting()
    }
    
    func startBroadCasting() {
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        connectedSockets = []
        
        var error: NSError?
        //UIDevice.currentDevice().name
        do {
            try self.socket.acceptOnPort(0)
            self.service = NSNetService(domain: "local.", type: "_probonjoreCJ._tcp.", name: "xHostWithMostist", port: Int32(self.socket.localPort) )
            //self.service.includesPeerToPeer = true
            self.service.delegate = self
            self.service.publish()
            
            
        } catch let error1 as NSError {
            error = error1
            print("Unable to create socket. Error \(error)")
        }
    }
    
    func parseHeader(data: NSData) -> UInt {
        var out: UInt = 0
        data.getBytes(&out, length: sizeof(UInt))
        return out
    }
    
    func handleResponseBody(data: NSData) -> NSString? {
        if let message = NSString(data: data, encoding: NSUTF8StringEncoding) {
            return message
        }
        return nil
    }
    
    func send( var xString: String) {
        //print("send data")
        if xString.characters.count == 8 {
            xString = "\(xString) "
        }
        let data : NSData = xString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var header = data.length
        let headerData = NSData(bytes: &header, length: sizeof(UInt))

        for (var i = 0; i < connectedSockets.count; i++) {
            let thisSocket : GCDAsyncSocket = self.connectedSockets[i] as! GCDAsyncSocket
            
            thisSocket.writeData(headerData, withTimeout: -1.0, tag: PacketTag.Header.rawValue)
            thisSocket.writeData(data, withTimeout: -1.0, tag: PacketTag.Body.rawValue)
        }
    }
    
    /// MARK: NSNetService Delegates
    
    func netServiceDidPublish(sender: NSNetService) {
        //print("Bonjour service published. domain: \(sender.domain), type: \(sender.type), name: \(sender.name), port: \(sender.port)")
    }
    
    func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        //print("Unable to create socket. domain: \(sender.domain), type: \(sender.type), name: \(sender.name), port: \(sender.port), Error \(errorDict)")
        //print( errorDict["NSNetServicesErrorCode"] )
        let xErrorCode : Int = errorDict["NSNetServicesErrorCode"] as! Int
        
        if xErrorCode == -72001 {
            print("Service named \(sender.name) is already in use on this network!")
        }
    }
    
    /// MARK: GCDAsyncSocket Delegates
    
    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        //print("Did accept new socket from: \(newSocket.connectedHost) - \(newSocket.connectedPort)")
        
        
        
        newSocket.readDataWithTimeout(-1, tag: 0)
        //newSocket.readDataToLength(UInt(sizeof(UInt64)), withTimeout: -1.0, tag: 0)
        
        
        //self.socket = newSocket
        //self.socket.readDataToLength(UInt(sizeof(UInt64)), withTimeout: -1.0, tag: 0)
        self.delegate.connectedTo(newSocket)
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        //print("socket did disconnect: error \(err)")
        //print(sock )
        
        connectedSockets.removeObject(sock)
        
        /*
        for (var i = 0; i < connectedSockets.count; i++) {
        let thisSocket : GCDAsyncSocket = self.connectedSockets[i] as! GCDAsyncSocket
        if thisSocket == sock {
        //self.delegate.disconnected()
        print("socket found that left us! as pos: \(i)")
        connectedSockets.removeObjectAtIndex(i)
        break
        }
        }
        */
        
        
        
        
        //if self.socket == socket {
        self.delegate.disconnected(sock)
        //}
        
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        //print("didReadData")
        
        if data.length == sizeof(UInt) {
            let bodyLength: UInt = self.parseHeader(data)
            sock.readDataToLength(bodyLength, withTimeout: -1, tag: PacketTag.Body.rawValue)
        } else {
            let body = self.handleResponseBody(data)
            self.delegate.handleBody(body)
            sock.readDataToLength(UInt(sizeof(UInt)), withTimeout: -1, tag: PacketTag.Header.rawValue)
        }
    }
    
    //func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
    //---DO NOT DELETE. THIS IS USED
    //print("did write data with tag: \(tag)")
    //}
}