//
//  RecoverPassowrdLoginViewController.swift
//  Converfit-iOS
//
//  Created by Manuel Citious on 16/11/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class RecoverPassowrdLoginViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Variables
    var recoverPassOk = false
    var alertTitle = ""
    var alertMessage = ""
    var showAppleStore = false

    //MARK: - Outlets
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var recoverPassButton: UIButton!
    @IBOutlet weak var iconImage: UIImageView!
   
    //MARK: - Actions
    @IBAction func superControlTap(sender: AnyObject) {
        dismissKeyBoard()
    }
    @IBAction func recoverPassTap(sender: AnyObject) {
        dismissKeyBoard()
        if(checkFormats()){//formats ok... call the WS
            recoverPassword(emailTxt.text!)
        }else{
            showAlert()
        }
    }
    
    //MARK: - LifeCycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        customizeNavigationBar()
        recoverPassButton.layer.cornerRadius = 5
        emailTxt.layer.cornerRadius = 5
        emailTxt.layer.borderColor = Colors.returnColorBorderButtons().CGColor
        emailTxt.layer.borderWidth = 0.5
        addImageTap()
    }
    
    //MARK: - addTaps
    func addImageTap(){
        let tapSingUpLabel =  UITapGestureRecognizer()
        tapSingUpLabel.addTarget(self, action: "tappedImage")
        iconImage.addGestureRecognizer(tapSingUpLabel)
    }
    
    func tappedImage(){
        dismissKeyBoard()
    }
    
    //MARK: - Customize NavigationBar
    func customizeNavigationBar(){
        self.navigationController?.navigationBar.barTintColor = Colors.returnRedConverfit()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyBoard()
        return true
    }
    
    //MARK: - Ocultar teclado
    func dismissKeyBoard(){
        self.view.endEditing(true)
    }
    
    //MARK: - Show Alert
    func showAlert(){
        if(recoverPassOk){
            alertTitle = "Revise su correco electrónico"
        }
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        if(showAppleStore){
            alert.addAction(UIAlertAction(title: "IR A APP STORE", style: .Default, handler: { (action) -> Void in
                //Falta implementar el boto para mostrar pero de momento no tenemos id
                print("IR A APP STORE")/*
                let url  = NSURL(string: "itms-apps://itunes.apple.com/app/id1024941703")
                if UIApplication.sharedApplication().canOpenURL(url!) == true  {
                UIApplication.sharedApplication().openURL(url!)
                }*/
            }))
        }else{
            if(recoverPassOk){
                alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler: { (action) -> Void in
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }))
            }else{
                alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler:nil))
            }
        }
        self.presentViewController(alert, animated: true) { () -> Void in
            self.alertTitle = ""
            self.alertMessage = ""
        }
    }
    
    //MARK: - Check Formats
    func checkFormats() -> Bool{//Check if the email and password are in correct format
        var formatCorrect = true
        if(emailTxt.text!.isEmpty ){
            (alertTitle, alertMessage) = Utils.returnTitleAndMessageAlert("campos_vacios")
            formatCorrect = false
        }else if(!Utils.emailIsValid(emailTxt.text!) || emailTxt.text!.characters.count > 155){
            (alertTitle, alertMessage) = Utils.returnTitleAndMessageAlert("formato_email")
            formatCorrect = false
        }
        return formatCorrect
    }

    //MARK: - RecoverPassword Server
    func recoverPassword(email: String){
        let params = "action=create_lost_password_code&email=\(email)&lang=es&app=\(app)"
        let urlServidor = "http://www.converfit.com/server/app/1.0.0/models/access/model.php"
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let recoverPasswordTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            self.recoverPassOk = true
                            self.alertMessage = "Siga las instrucciones que se indican en el correo para recuperar su contraseña. Puede que el correo llegue a su cuenta de Spam."
                        }else{
                            if let codigoError = json.objectForKey("error_code") as? String{
                                (self.alertTitle,self.alertMessage) = Utils.returnTitleAndMessageAlert(codigoError)
                            }
                        }
                    }
                }
            } catch{
                (self.alertTitle,self.alertMessage) = Utils.returnTitleAndMessageAlert("error")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.showAlert()
                })
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.showAlert()
            })
        }
        recoverPasswordTask.resume()
    }
}
