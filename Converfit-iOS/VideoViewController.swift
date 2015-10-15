//
//  VideoViewController.swift
//  CitiousManager-IOs
//
//  Created by Manuel Citious on 27/8/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController, UIWebViewDelegate {
    
    var dataVideo: NSData?
    var messageKey = ""
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        webView.delegate = self
        mostrarVideo()
        self.tabBarController?.tabBar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func applicationDocumentsDirectory() -> NSString {//En esta funcion obtenemos la ruta temporal donde guardar nuestro archivo
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    }
    
    func mostrarVideo(){
        let filePath = applicationDocumentsDirectory().stringByAppendingPathComponent("\(messageKey).mp4")
        dataVideo?.writeToFile(filePath, atomically: true)
        
        let url = NSURL(fileURLWithPath: filePath)
        let request = NSMutableURLRequest(URL: url)
        self.webView.loadRequest(request)
    }
    
}
