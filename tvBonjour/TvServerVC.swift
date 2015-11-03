//
//  ViewController.swift
//  tvBonjour
//
//  Created by Johnson, Christopher P on 10/20/15.
//  Copyright © 2015 Johnson, Christopher P. All rights reserved.
//

import UIKit

class TvServerVC: UIViewController, BonjourServerDelegate {
    
    var bonjourServer: BonjourServer!
    
    @IBAction func colorAction(sender: UIButton) {
        print(sender.titleLabel!.text)
    }
    
    @IBOutlet var toSendTextField: UITextField!
    
    @IBOutlet var sendButton: UIButton!
    
    @IBOutlet var receivedTextField: UITextField!
    
    @IBOutlet var connectedToLabel: UILabel!
    
    override func viewDidLoad() {
        print("serverVC")
        super.viewDidLoad()
        connectedToLabel.text = "0 Users"
        self.bonjourServer = BonjourServer()
        self.bonjourServer.delegate = self
    }
    
    @IBAction func sendText() {
        bonjourServer.send(self.toSendTextField.text!)
    }
    
    // MARK: Bonjour server delegates
    
    func handleBody(body: NSString?) {
        print("Received message: \(body)")
        self.receivedTextField.text = body! as String
    }
    
    func connectedTo(socket: GCDAsyncSocket!) {
        //print("Connected to " + socket.connectedHost)
        //print("Connected to " + socket.description)
        print( "Connected users: \( bonjourServer.connectedSockets.count  )")
    }
    
    func disconnected(socket: GCDAsyncSocket!) {
        //self.xStatusText.stringValue = "Disconnected"
        //print("User disconnected: " + socket.description)
        print( "Connected users: \( bonjourServer.connectedSockets.count  )")
    }
    
}




