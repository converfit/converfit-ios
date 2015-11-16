//
//  SignUpViewController.swift
//  Converfit-iOS
//
//  Created by Manuel Citious on 16/11/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    //MARK:- Variables
    var modelIphoneName = ""
    var alertTitle = ""
    var alertMessage = ""
    var showAppleStore = false
    var desLoguear = false
    var userCreatedOk = false

    //MARK: - Outlets
    @IBOutlet weak var centerYconstraint: NSLayoutConstraint!
    @IBOutlet weak var createUserButton: UIButton!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var converfitIcon: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    //MARK: - Actions
    @IBAction func superControlTap(sender: AnyObject) {
        dismissKeyBoard()
    }
   
    @IBAction func singUpPress(sender: AnyObject) {
        dismissKeyBoard()
        if(checkFormats()){//formats ok... call the WS
            createUser(nameTxt.text!, email: emailTxt.text!, password: passwordTxt.text!)
        }else{
            showAlert()
        }
    }
    
    
    //MARK: - LifeCycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
        containerView.layer.cornerRadius = 5
        createUserButton.layer.cornerRadius = 5
        customizeNavigationBar()
        startObservingKeyBoard()
        modelIphoneName = UIDevice.currentDevice().modelName
        addImageTap()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingKeyBoard()
    }
    
    //MARK: - Ocultar teclado
    func dismissKeyBoard(){
        self.view.endEditing(true)
    }
    
    func startObservingKeyBoard(){
        //Funcion para darnos de alta como observador en las notificaciones de teclado
        let nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "notifyThatKeyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: "notifyThatKeyboardWillDisappear:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Funcion para darnos de alta como observador en las notificaciones de teclado
    func stopObservingKeyBoard(){
        let nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
    }
    
    //Funcion que se ejecuta cuando aparece el teclado
    func notifyThatKeyboardWillAppear(notification:NSNotification){
        var constraintConstant:CGFloat
        centerYconstraint.constant = 0
        switch modelIphoneName{//-150 iphone 4
            case "iPhone5,1", "iPhone5,2", "iPhone5,3", "iPhone5,4", "iPhone6,1", "iPhone6,2": //Iphone 5 y 5C
                constraintConstant = -110
                break
            case "iPhone 6":
                constraintConstant = -70
                break
            case "iPhone 6s":
                constraintConstant = -70
                break
            case "iPhone 6s Plus":
                constraintConstant = 0
                break
            case "iPhone 6 Plus":
                constraintConstant = 0
                break
            default: //Valor por defecto para los iPhone 4
                constraintConstant = -150
                break
        }
        centerYconstraint.constant = constraintConstant

        UIView.animateWithDuration(0.25, animations:  {
            self.view.layoutIfNeeded()
        })
    }
    
    //Funcion que se ejecuta cuando desaparece el teclado
    func notifyThatKeyboardWillDisappear(notification:NSNotification){
        centerYconstraint.constant = 0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: - addTaps
    func addImageTap(){
        let tapSingUpLabel =  UITapGestureRecognizer()
        tapSingUpLabel.addTarget(self, action: "tappedImage")
        converfitIcon.addGestureRecognizer(tapSingUpLabel)
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
    
    //MARK: - Create User Server
    func createUser(brandName:String, email: String, password:String){
        let params = "action=signup&brand_name=\(brandName)&email=\(email)&password=\(password)&app=\(app)"
        let urlServidor = "http://www.converfit.com/server/app/1.0.0/models/access/model.php"
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let createUserTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            self.userCreatedOk = true
                            self.alertMessage = "Gracias por registrarte. Puedes verificar tu correo electrónico en el email que te hemos enviado. Puede que el correo llegue a su cuenta de Spam."
                        }else{
                            if let codigoError = json.objectForKey("error_code") as? String{
                                self.desLoguear = LogOut.comprobarDesloguear(codigoError)
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
        createUserTask.resume()
    }

    //MARK: - Show Alert
    func showAlert(){
        if(userCreatedOk){
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
            if(userCreatedOk){
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
        if(emailTxt.text!.isEmpty || passwordTxt.text!.isEmpty || nameTxt.text!.isEmpty){
            (alertTitle, alertMessage) = Utils.returnTitleAndMessageAlert("campos_vacios")
            formatCorrect = false
        }else if(!Utils.emailIsValid(emailTxt.text!) || emailTxt.text!.characters.count > 155){
            (alertTitle, alertMessage) = Utils.returnTitleAndMessageAlert("formato_email")
            formatCorrect = false
        }else if(passwordTxt.text!.characters.count < 4 || passwordTxt.text!.characters.count > 25){
            (alertTitle, alertMessage) = Utils.returnTitleAndMessageAlert("formato_contraseña")
            formatCorrect = false
        }
        return formatCorrect
    }
}
