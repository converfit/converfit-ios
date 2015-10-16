//
//  LoginController.swift
//  Converfit-iOS
//
//  Created by Manuel Martinez Gomez on 8/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    //MARK: - Variables
    var alertTitle = ""
    var alertMessage = ""
    var showAppleStore = false
    
    //MARK: - Outlets
    @IBOutlet weak var viewEmailPassword: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var lostPasswordLabel: UILabel!
    @IBOutlet weak var singUpLabel: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var versionLabelLogin: UILabel!
    @IBOutlet weak var logoConverfitLogin: UIImageView!
    
    //MARK: - Actions
    @IBAction func viewContainerTap(sender: AnyObject) {
        dissmisKeyBoard()
    }
    
    @IBAction func tryLogin(sender: AnyObject) {
        dissmisKeyBoard()
        if(checkFormats()){//formats ok... call the WS
            login()
        }else{
            showAlert()
        }
    }

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        roundViews()
        addTapActions()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ocultar(ocultarLogIn)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: - KeyBoard
    func dissmisKeyBoard(){
        self.view.endEditing(true)
    }
    
    //MARK: - Round views
    func roundViews(){
        viewEmailPassword.layer.cornerRadius = 5
        loginButton.layer.cornerRadius = 5
    }
    
    //MARK: - Add Tap Actions
    func addTapActions(){
        let tapSingUpLabel =  UITapGestureRecognizer()
        tapSingUpLabel.addTarget(self, action: "tappedSignUp")
        singUpLabel.addGestureRecognizer(tapSingUpLabel)
        
        let tapLostPasswordLabel = UITapGestureRecognizer()
        tapLostPasswordLabel.addTarget(self, action: "tappedLostPassword")
        lostPasswordLabel.addGestureRecognizer(tapLostPasswordLabel)
    }
    
    func tappedSignUp(){//Show singUp converfit web
        if let requestUrl = NSURL(string: "http://www.converfit.com/app/es/signup/index.html") {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    func tappedLostPassword(){//Show recover_password converfit web
        if let requestUrl = NSURL(string: "http://www.converfit.com/app/es/recover_password/index.html") {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    //MARK: - Check Formats
    func checkFormats() -> Bool{//Check if the email and password are in correct format
        var formatCorrect = true
        if(emailTxt.text!.isEmpty || passwordTxt.text!.isEmpty){
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
    
    //MARK: - Show Alert
    func showAlert(){
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
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler:nil))
        }
        self.presentViewController(alert, animated: true) { () -> Void in
            self.alertTitle = ""
            self.alertMessage = ""
        }
    }
    
    //MARK: - Login into server
    func login(){
        let deviceKey = Utils.getDeviceKey()
        let params = "action=login&email=\(emailTxt.text!)&password=\(passwordTxt.text!)&device_key=\(deviceKey)&system=\(sistema)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("access")
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        
        let loginTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            if let dataJSON = json.objectForKey("data") as? NSDictionary{
                                if let sessionKey = dataJSON.objectForKey("session_key") as? String{
                                    Utils.saveSessionKey(sessionKey)
                                }
                                if let lastUpdate = dataJSON.objectForKey("last_update") as? String{
                                    Utils.saveLastUpdate(lastUpdate)
                                }
                                //Obtenemos los datos del admin para el lname y fname
                                if let admin = dataJSON.objectForKey("admin") as? NSDictionary{
                                    //Obtenemos el id del admin logado
                                    if let id = admin.objectForKey("id_admin") as? String{
                                        Utils.guardarIdLogin(id)
                                    }
                                    
                                    //Obtenemos el fname
                                    if let fname = admin.objectForKey("fname") as? String{
                                        Utils.guardarFname(fname)
                                    }
                                    //Obtenemos el lame
                                    if let lname = admin.objectForKey("lname") as? String{
                                        Utils.guardarLname(lname)
                                    }
                                }

                    
                                //Show the tabBar
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    //Borramos los datos que tuvieramos introducimos
                                    self.emailTxt.text = ""
                                    self.passwordTxt.text = ""
                                    self.performSegueWithIdentifier("loginSegue", sender: self)
                                    PostServidor.getStatusChat()
                                })
                            }
                        }else{
                            if let errorCode = json.objectForKey("error_code") as? String{
                                (self.alertTitle, self.alertMessage) = Utils.returnTitleAndMessageAlert(errorCode)
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.showAlert()
                                })
                            }
                        }
                    }
                } else {
                    (self.alertTitle, self.alertMessage) = Utils.returnTitleAndMessageAlert("default")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.showAlert()
                    })
                }
            } catch{
                (self.alertTitle, self.alertMessage) = Utils.returnTitleAndMessageAlert("default")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.showAlert()
                })
            }
        }
        loginTask.resume()
    }
    
    //MARK: - PrepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*if(segue.identifier == "loginSegue"){
            let tabBar = segue.destinationViewController as? UITabBarController
            tabBar?.selectedIndex = 2
        }*/
    }
    
    //MARK: - Ocultar login
    func ocultar(ocultar:Bool){
        dispatch_async(dispatch_get_main_queue()) {
            self.viewEmailPassword.hidden = ocultar
            self.emailTxt.hidden = ocultar
            self.passwordTxt.hidden = ocultar
            self.loginButton.hidden = ocultar
            self.lostPasswordLabel.hidden = ocultar
            self.singUpLabel.hidden = ocultar
            self.versionLabelLogin.hidden = ocultar
            self.logoConverfitLogin.hidden = ocultar
            if(ocultar){
                self.performSegueWithIdentifier("loginSegue", sender: self)
            }
        }
    }

}

