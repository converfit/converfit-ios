//
//  visorPdfController.swift
//  Citious-IOs
//
//  Created by Manuel Citious on 8/6/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class visorPdfController: UIViewController,UIWebViewDelegate, UIDocumentInteractionControllerDelegate {

    @IBOutlet weak var web: UIWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var pdfData:NSData?
    var urlString = ""
    var titulo = ""
    var docContr:UIDocumentInteractionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titulo
        web.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dispatch_async(dispatch_get_global_queue(
            Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.pdfData = NSData(contentsOfURL: NSURL(string: self.urlString)!)
                    self.web.loadData(self.pdfData!, MIMEType: "application/pdf", textEncodingName: "utf-8", baseURL: NSURL())
                    self.automaticallyAdjustsScrollViewInsets = false
                })
        }

        let rightButton = UIBarButtonItem()
        rightButton.title = "Guardar"
        rightButton.style = .Plain
        rightButton.target = self
        rightButton.action = "saveIbooks"
        
        navigationItem.rightBarButtonItem = rightButton
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Utils
    func applicationDocumentsDirectory() -> NSString {//En esta funcion obtenemos la ruta temporal donde guardar nuestro archivo
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    }
    
    func saveIbooks(){
        let urlPDF = NSURL(string: urlString)
        //let filePath = applicationDocumentsDirectory().stringByAppendingPathComponent(urlString.lastPathComponent)
        let filePath = applicationDocumentsDirectory().stringByAppendingPathComponent((urlPDF?.lastPathComponent)!)
        pdfData?.writeToFile(filePath, atomically: true)
        
        docContr = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: filePath))
        docContr?.delegate = self
        docContr?.presentOpenInMenuFromRect(self.view.bounds, inView: self.view, animated: true)
    }
    
    //MARK:- WebViewDelegate
    func webViewDidFinishLoad(webView: UIWebView) {
        indicator.stopAnimating()
    }
    
}
