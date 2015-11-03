//
//  ViewController.swift
//  xBonjourDemo
//
//  Created by Johnson, Christopher P on 10/20/15.
//  Copyright © 2015 Johnson, Christopher P. All rights reserved.
//

import UIKit
import AVFoundation


class ClientVC: UIViewController, BonjourClientDelegate {
    
    var bonjourClient: BonjourClient!
    
    @IBOutlet var toSendTextField: UITextField!
    
    @IBOutlet var sendButton: UIButton!
    
    @IBOutlet var receivedTextField: UITextField!
    
    @IBOutlet var connectedToLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bonjourClient = BonjourClient()
        self.bonjourClient.delegate = self
        onSayMeSomething("Hello Chris. How are you today?")
    }
    
    @IBAction func sendText() {
        self.bonjourClient.send(self.toSendTextField.text!)
    }
    
    func onSayMeSomething( xString : String ) {
        let utterance = AVSpeechUtterance(string: xString)
        //utterance.pitchMultiplier = 1.3
        //utterance.rate = AVSpeechUtteranceMinimumSpeechRate * 2.0
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        //utterance.postUtteranceDelay = 0.005  //take a breath between paragraphs (sentences?)
        let synth = AVSpeechSynthesizer()
        synth.speakUtterance(utterance)
    }
    
    

    
    //---------user dot
    var userDots: Array<Dot> = []
    @IBOutlet weak var myDot: Dot!
    
    func createUserDot() {
        let testFrame : CGRect = CGRectMake(100,100,50,50)
        let testView : Dot = Dot(frame: testFrame)
        testView.backgroundColor = UIColor.clearColor()
        testView.xNum = 4
        testView.isPlayer = false
        //testView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        testView.alpha=0.5
        self.view.addSubview(testView)
        self.view.sendSubviewToBack(testView)
    }
    
    // MARK: Bonjour client delegates
    func handleBody(body: NSString?) {
        receivedTextField.text = body! as String
    }
    
    func didChangeServices() {
        //print("didChangeServices")
        if self.bonjourClient.devices.count > 0 {
            let device = self.bonjourClient.devices[0]
            //let result = device.name
            //print(result)
            //let service = self.bonjourServer.devices[self.tableView.selectedRow]
            self.bonjourClient.connectTo(device)
            connectedToLabel.text = "\(self.bonjourClient.devices.count) Users"
        } else {
            print("No users it says!")
        }
    }
    
    func connected() {
        print("connected")
    }
    
    func disconnected() {
        print("disconnected")
        
        //---UIAlertController to tell user that they have lost connection
        let alertController = UIAlertController(title: "Disconnected!", message: "By the Server.", preferredStyle: .Alert)
        let doItAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(doItAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}


