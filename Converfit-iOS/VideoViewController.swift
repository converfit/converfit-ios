//
//  VideoViewController.swift
//  CitiousManager-IOs
//
//  Created by Manuel Citious on 27/8/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController, UIWebViewDelegate {
    
    var dataVideo: Data?
    var messageKey = ""
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        webView.delegate = self
        mostrarVideo()
        self.tabBarController?.tabBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func applicationDocumentsDirectory() -> NSString {//En esta funcion obtenemos la ruta temporal donde guardar nuestro archivo
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    }
    
    func mostrarVideo(){
        let filePath = applicationDocumentsDirectory().appendingPathComponent("\(messageKey).mp4")
        if let pathURL = URL(string: filePath){
            try! dataVideo?.write(to: pathURL)
        }
        
        let url = URL(fileURLWithPath: filePath)
        let request = NSMutableURLRequest(url: url)
        self.webView.loadRequest(request as URLRequest)
    }
    
}
