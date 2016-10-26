//
//  ViewController.swift
//  RouterMonitor
//
//  Created by Julian Lima on 20/8/16.
//  Copyright © 2016 Julian Lima. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

      @IBOutlet weak var label: NSTextField!
    
    @IBOutlet weak var startCheck: NSButton!
    
        dynamic var isRunning = false
        var outputPipe:NSPipe!
        var buildTask:NSTask!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        label.editable = false
        label.stringValue = ""
        
      
        
        // Do any additional setup after loading the view.
    }

    @IBAction func startCheckOnClick(sender: NSButton) {
        runScript([""])
        sender.enabled = false
    }
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func runScript(arguments:[String]) {
        
        //1.
        isRunning = true
        
        let taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        
        //2.
        dispatch_async(taskQueue) {
            
            //TESTING CODE
            
            //3.
            NSThread.sleepForTimeInterval(2.0)
            
          
            
            //1.
            guard let path = NSBundle.mainBundle().pathForResource("monitor",ofType:"command") else {
                print("Unable to locate monitor.command")
                return
            }
            
            //2.
            self.buildTask = NSTask()
            self.captureStandardOutputAndRouteToTextView(self.buildTask)
            self.buildTask.launchPath = path
            self.buildTask.arguments = arguments
            
            
            //TODO Output Handling
            
            //4.
            self.buildTask.launch()
            
            print(self.buildTask.description)
           
            //5.
            self.buildTask.waitUntilExit()
            self.startCheck.enabled = true
            print("termino")
        }
        
    }
    
    func captureStandardOutputAndRouteToTextView(task:NSTask) {
        
        //1.
        outputPipe = NSPipe()
        task.standardOutput = outputPipe
        //2.
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        //3.
        NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: outputPipe.fileHandleForReading , queue: nil) {
            
            notification in
            
            //4.
            let output = self.outputPipe.fileHandleForReading.availableData
            //print(String(data: output, encoding: NSUTF8StringEncoding))
            let outputString = String(data: output, encoding: NSUTF8StringEncoding) ?? ""
            
            
            //PING 192.168.0.1 (192.168.0.1): 56 data bytes
            
            //--- 192.168.0.1 ping statistics ---
            //1 packets transmitted, 1 packets received, 0.0% packet loss, 1 packets out of wait time
            //round-trip min/avg/max/stddev = 1.043/1.043/1.043/0.000 ms
            
            let range1 = outputString.rangeOfString("---",
                                                    options: NSStringCompareOptions.LiteralSearch,
                                                    range: outputString.startIndex..<outputString.endIndex,
                                                    locale: nil)

            if let result1 = range1{
            var range :Range<String.Index> = result1
                range.endIndex = (outputString.endIndex)
                
            var IP  = outputString.substringWithRange(range)
            range = IP.rangeOfString("192.168.0.")!
            range.endIndex = range.endIndex.advancedBy(2)
            
            IP = IP.substringWithRange(range)
            //print("IP "+IP+"\n")
            
            
            let result = outputString.rangeOfString("1 packets received",
                                                options: NSStringCompareOptions.LiteralSearch,
                                                range: outputString.startIndex..<outputString.endIndex,
                                                locale: nil)
                if let range = result {
                    
                    
                    IP = IP+" : conectado"
     
            //5.
            dispatch_async(dispatch_get_main_queue(), {
               // let previousOutput =
                let nextOutput = self.label.stringValue + "\n" + IP
                self.label.stringValue  = nextOutput
                //print(nextOutput)
                
            })
                    }
            //6.
                self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            }
                
            
        }
    }
}

