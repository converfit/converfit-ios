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
    let createUserSegue = "createUserSegue"
    let recoverPasswordSegue = "recoverPasswordSegue"
    
    //MARK: - Outlets
    @IBOutlet weak var viewEmailPassword: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var lostPasswordLabel: UILabel!
    @IBOutlet weak var singUpLabel: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var versionLabelLogin: UILabel!
    @IBOutlet weak var logoConverfitLogin: UIImageView!
    @IBOutlet weak var verticalCenterYconstrait: NSLayoutConstraint!
    
    //MARK: - Actions
    @IBAction func viewContainerTap(_ sender: AnyObject) {
        dissmisKeyBoard()
    }
    
    @IBAction func tryLogin(_ sender: AnyObject) {
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        irPantallaLogin = false
        roundViews()
        addTapActions()
        startObservingKeyBoard()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingKeyBoard()
        verticalCenterYconstrait.constant = 0
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
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
        tapSingUpLabel.addTarget(self, action: #selector(self.tappedSignUp))
        singUpLabel.addGestureRecognizer(tapSingUpLabel)
        
        let tapLostPasswordLabel = UITapGestureRecognizer()
        tapLostPasswordLabel.addTarget(self, action: #selector(self.tappedLostPassword))
        lostPasswordLabel.addGestureRecognizer(tapLostPasswordLabel)
    }
    
    func tappedSignUp(){//Show singUp converfit web
        performSegue(withIdentifier: createUserSegue, sender: self)
    }
    
    func tappedLostPassword(){//Show recover_password converfit web
        performSegue(withIdentifier: recoverPasswordSegue, sender: self)
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
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        if(showAppleStore){
            alert.addAction(UIAlertAction(title: "IR A APP STORE", style: .default, handler: { (action) -> Void in
                //Falta implementar el boto para mostrar pero de momento no tenemos id
                print("IR A APP STORE")/*
                let url  = NSURL(string: "itms-apps://itunes.apple.com/app/id1024941703")
                if UIApplication.sharedApplication().canOpenURL(url!) == true  {
                    UIApplication.sharedApplication().openURL(url!)
                }*/
            }))
        }else{
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler:nil))
        }
        self.present(alert, animated: true) { () -> Void in
            self.alertTitle = ""
            self.alertMessage = ""
        }
    }
    
    //MARK: - Login into server
    func login(){
        let deviceKey = Utils.getDeviceKey()
        let params = "action=login&email=\(emailTxt.text!)&password=\(passwordTxt.text!)&device_key=\(deviceKey)&system=\(sistema)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("access")
        
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        
        let loginTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                            let sessionKey = dataResultado["session_key"] as? String ?? ""
                            Utils.saveSessionKey(sessionKey)
                            let lastUpdate = dataResultado["last_update"] as? String ?? ""
                            Utils.saveLastUpdate(lastUpdate)
                            if let admin = dataResultado["admin"] as? Dictionary<String, AnyObject>{
                                let id = admin["id_admin"] as? String ?? "0"
                                Utils.guardarIdLogin(id)
                                let fname = admin["fname"] as? String ?? ""
                                Utils.guardarFname(fname)
                                let lname = admin["lname"] as? String ?? ""
                                Utils.guardarLname(lname)
                                //Show the tabBar
                                DispatchQueue.main.async(execute: { () -> Void in
                                    //Borramos los datos que tuvieramos introducimos
                                    self.emailTxt.text = ""
                                    self.passwordTxt.text = ""
                                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                                    PostServidor.getStatusChat()
                                })
                            }
                        }
                    }else{
                        let errorCode = json["error_code"] as? String ?? ""
                        (self.alertTitle, self.alertMessage) = Utils.returnTitleAndMessageAlert(errorCode)
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.showAlert()
                        })
                    }
                } else {
                    (self.alertTitle, self.alertMessage) = Utils.returnTitleAndMessageAlert("default")
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.showAlert()
                    })
                }
            } catch{
                (self.alertTitle, self.alertMessage) = Utils.returnTitleAndMessageAlert("default")
                DispatchQueue.main.async(execute: { () -> Void in
                    self.showAlert()
                })
            }
        }
        loginTask.resume()
    }
    
    //MARK: - PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        /*if(segue.identifier == "loginSegue"){
            let tabBar = segue.destinationViewController as? UITabBarController
            tabBar?.selectedIndex = 2
        }*/
    }
    
    //MARK: - Ocultar teclado
    func startObservingKeyBoard(){
        //Funcion para darnos de alta como observador en las notificaciones de teclado
        let nc:NotificationCenter = NotificationCenter.default()
        nc.addObserver(self, selector: #selector(self.notifyThatKeyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        nc.addObserver(self, selector: #selector(self.notifyThatKeyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //Funcion para darnos de alta como observador en las notificaciones de teclado
    func stopObservingKeyBoard(){
        let nc:NotificationCenter = NotificationCenter.default()
        nc.removeObserver(self)
    }
    
    //Funcion que se ejecuta cuando aparece el teclado
    func notifyThatKeyboardWillAppear(_ notification:Notification){
        verticalCenterYconstrait.constant = -100
        UIView.animate(withDuration: 0.25, animations:  {
            self.view.layoutIfNeeded()
        })
    }
    
    //Funcion que se ejecuta cuando desaparece el teclado
    func notifyThatKeyboardWillDisappear(_ notification:Notification){
        verticalCenterYconstrait.constant = 0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

}

