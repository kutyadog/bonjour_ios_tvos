//
//  BonjourController.swift
//  xBonjourDemo
//  Created by Johnson, Christopher P on 10/20/15.
//  Copyright © 2015 Johnson, Christopher P. All rights reserved.

import UIKit

enum PacketTagC: Int {
    case Header = 1
    case Body = 2
}

protocol BonjourClientDelegate {
    func connected()
    func disconnected()
    func handleBody(body: NSString?)
    func didChangeServices()
}

class BonjourClient: NSObject, NSNetServiceBrowserDelegate, NSNetServiceDelegate, GCDAsyncSocketDelegate {
    
    var delegate: BonjourClientDelegate!
    
    var coServiceBrowser: NSNetServiceBrowser!
    
    var devices: Array<NSNetService>!
    
    var connectedService: NSNetService!
    
    var sockets: [String : GCDAsyncSocket]!

    override init() {
        super.init()
        self.devices = []
        self.sockets = [:]
        self.startService()
    }
    
    func parseHeader(data: NSData) -> UInt {
        var out: UInt = 0
        data.getBytes(&out, length: sizeof(UInt))
        return out
    }
    
    func handleResponseBody(data: NSData) {
        if let message = NSString(data: data, encoding: NSUTF8StringEncoding) {
            self.delegate.handleBody(message)
        }
    }
    
    func connectTo(service: NSNetService) {
        service.delegate = self
        service.resolveWithTimeout(3)
    }
    
    // MARK: NSNetServiceBrowser helpers
    
    func stopBrowsing() {
        if self.coServiceBrowser != nil {
            self.coServiceBrowser.stop()
            self.coServiceBrowser.delegate = nil
            self.coServiceBrowser = nil
        }
    }
    
    func startService() {
        //print("startService")
        if self.devices != nil {
            self.devices.removeAll(keepCapacity: true)
        }
        
        self.coServiceBrowser = NSNetServiceBrowser()
        self.coServiceBrowser.delegate = self
        //self.coServiceBrowser.includesPeerToPeer = true
        self.coServiceBrowser.searchForServicesOfType("_probonjoreCJ._tcp.", inDomain: "local.")
    }
    
    //func send(data: NSData) {
    func send( var xString: String) {
        //print("send data")
        if xString.characters.count == 8 {
            xString = "\(xString) "
        }
        let data : NSData = xString.dataUsingEncoding(NSUTF8StringEncoding)!
        //.dataUsingEncoding(NSUTF8StringEncoding)
        if let socket = self.getSelectedSocket() {
            var header = data.length
            let headerData = NSData(bytes: &header, length: sizeof(UInt))
            socket.writeData(headerData, withTimeout: -1.0, tag: PacketTagC.Header.rawValue)
            //print ( String(data: headerData, encoding: NSUTF8StringEncoding)  )
            socket.writeData(data, withTimeout: -1.0, tag: PacketTagC.Body.rawValue)
        } else {
            //print("5")
        }
    }
    
    func connectToServer(service: NSNetService) -> Bool {
        var connected = false
        
        let addresses: Array = service.addresses!
        var socket = self.sockets[service.name]
        
        if !(socket?.isConnected != nil) {
            socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            while !connected && Bool(addresses.count) {
                let address: NSData = addresses[0]
                do {
                    if (try socket?.connectToAddress(address) != nil) {
                        print( "Connecting to : \( service.name )")
                        self.sockets.updateValue(socket!, forKey: service.name)
                        self.connectedService = service
                        connected = true
                        stopBrowsing()  //cj added
                    }
                } catch {
                    print(error);
                }
            }
        }
        
        return true
    }
    
    // MARK: NSNetService Delegates
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        //print("did resolve address \(sender.name)")
        if self.connectToServer(sender) {
            //print("connected to \(sender.name)")
            self.delegate.connected()
        }
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        print("net service did no resolve. errorDict: \(errorDict)")
    }
    
    // MARK: GCDAsyncSocket Delegates
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        //print("connected to host \(host), on port \(port)")
        sock.readDataToLength(UInt(sizeof(UInt64)), withTimeout: -1.0, tag: 0)
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        //print("socket did disconnect \(sock), error: \(err.userInfo)")
        self.delegate.disconnected()
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        //print("socket did read data. tag: \(tag)")
        
        if self.getSelectedSocket() == sock {
            if data.length == sizeof(UInt) {
                let bodyLength: UInt = self.parseHeader(data)
                //print("bodyLength: \(bodyLength)")
                //7668058320735204196
                //if bodyLength > 2342343223 {
                    //fdfgdsee
                    //sock.readDataWithTimeout(-1, tag: PacketTagC.Body.rawValue)
                //} else {
                sock.readDataToLength(bodyLength, withTimeout: -1, tag: PacketTagC.Body.rawValue)
                //}
                
            } else {
                self.handleResponseBody(data)
                sock.readDataToLength(UInt(sizeof(UInt)), withTimeout: -1, tag: PacketTagC.Header.rawValue)
            }
        }
    }
    
    func socketDidCloseReadStream(sock: GCDAsyncSocket!) {
        print("socket did close read stream")
    }
    
    // MARK: NSNetServiceBrowser Delegates
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        self.devices.append(aNetService)
        if !moreComing {
            self.delegate.didChangeServices()
        }
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        self.devices.removeObject(aNetService)
        if !moreComing {
            self.delegate.didChangeServices()
        }
    }
    
    func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        self.stopBrowsing()
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        self.stopBrowsing()
    }
    
    // MARK: helpers
    
    func getSelectedSocket() -> GCDAsyncSocket? {
        var sock: GCDAsyncSocket?
        if self.connectedService != nil {
            sock = self.sockets[self.connectedService.name]!
        }
        return sock
    }
    
}

extension Array {
    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int?
        for (idx, objectToCompare) in self.enumerate() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if(index != nil) {
            self.removeAtIndex(index!)
        }
    }
}