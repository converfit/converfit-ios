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
    
    var pdfData:Data?
    var urlString = ""
    var titulo = ""
    var docContr:UIDocumentInteractionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titulo
        web.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(
            attributes: DispatchQueue.GlobalAttributes(rawValue: UInt64(Int(DispatchQueueAttributes.qosUserInteractive.rawValue)))).async {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.pdfData = try? Data(contentsOf: URL(string: self.urlString)!)
                    //self.web.load(self.pdfData!, mimeType: "application/pdf", textEncodingName: "utf-8", baseURL: URL())
                    self.web.load(self.pdfData!, mimeType: "application/pdf", textEncodingName: "utf-8", baseURL: URL(string: "")!)
                    self.automaticallyAdjustsScrollViewInsets = false
                })
        }

        let rightButton = UIBarButtonItem()
        rightButton.title = "Guardar"
        rightButton.style = .plain
        rightButton.target = self
        rightButton.action = #selector(self.saveIbooks)
        
        navigationItem.rightBarButtonItem = rightButton
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Utils
    func applicationDocumentsDirectory() -> NSString {//En esta funcion obtenemos la ruta temporal donde guardar nuestro archivo
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    }
    
    func saveIbooks(){
        let urlPDF = URL(string: urlString)
        let filePath = applicationDocumentsDirectory().appendingPathComponent((urlPDF?.lastPathComponent)!)
        do{
            try pdfData?.write(to: URL(fileURLWithPath: filePath), options: .atomicWrite)
            docContr = UIDocumentInteractionController(url: URL(fileURLWithPath: filePath))
            docContr?.delegate = self
            docContr?.presentOpenInMenu(from: self.view.bounds, in: self.view, animated: true)
        }catch let error as NSError{
            mostrarAlerta(mensajeAlert: error.localizedDescription)
        }
    }
    
    //MARK: - Show alert
    func mostrarAlerta(mensajeAlert: String){
        self.view.endEditing(true)
        let alert = UIAlertController(title: "No se ha podido guardar en iBooks", message: mensajeAlert, preferredStyle: UIAlertControllerStyle.alert)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausura
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { action in
        }))
        //mostramos el alert
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- WebViewDelegate
    func webViewDidFinishLoad(_ webView: UIWebView) {
        indicator.stopAnimating()
    }
    
}
