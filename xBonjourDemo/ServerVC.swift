//
//  ViewController.swift
//
//  Created by James Zaghini on 6/05/2015.
//  Copyright (c) 2015 James Zaghini. All rights reserved.
//

import UIKit

class ServerVC: UIViewController, BonjourServerDelegate {
    
    var bonjourServer: BonjourServer!
    
    @IBOutlet var toSendTextField: UITextField!
    
    @IBOutlet var sendButton: UIButton!
    
    @IBOutlet var receivedTextField: UITextField!
    
    @IBOutlet var connectedToLabel: UILabel!
    
    @IBAction func sendText() {
        bonjourServer.send(self.toSendTextField.text!)
    }
    
    override func viewDidLoad() {
        print("serverVC")
        super.viewDidLoad()
        connectedToLabel.text = "0 Users"
        self.bonjourServer = BonjourServer()
        self.bonjourServer.delegate = self
    }
    
    // MARK: Bonjour server delegates
    
    func handleBody(body: NSString?) {
        print("Received message: \(body)")
        self.receivedTextField.text = body! as String
    }
    
    func connectedTo(socket: GCDAsyncSocket!) {
        print("Connected to " + socket.connectedHost)
        print("Connected to " + socket.description)
        print( "Connected users: \( bonjourServer.connectedSockets.count  )")
    }
    
    func disconnected(socket: GCDAsyncSocket!) {
        print("User disconnected: " + socket.description)
        print( "Connected users: \( bonjourServer.connectedSockets.count  )")
    }

    
    
}


