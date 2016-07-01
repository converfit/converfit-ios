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
    @IBAction func superControlTap(_ sender: AnyObject) {
        dismissKeyBoard()
    }
    @IBAction func recoverPassTap(_ sender: AnyObject) {
        dismissKeyBoard()
        if checkFormats(){//formats ok... call the WS
            recoverPassword(emailTxt.text!)
        }else{
            showAlert()
        }
    }
    
    //MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        customizeNavigationBar()
        recoverPassButton.layer.cornerRadius = 5
        emailTxt.layer.cornerRadius = 5
        emailTxt.layer.borderColor = Colors.returnColorBorderButtons().cgColor
        emailTxt.layer.borderWidth = 0.5
        addImageTap()
    }
    
    //MARK: - addTaps
    func addImageTap(){
        let tapSingUpLabel =  UITapGestureRecognizer()
        tapSingUpLabel.addTarget(self, action: #selector(self.tappedImage))
        iconImage.addGestureRecognizer(tapSingUpLabel)
    }
    
    func tappedImage(){
        dismissKeyBoard()
    }
    
    //MARK: - Customize NavigationBar
    func customizeNavigationBar(){
        self.navigationController?.navigationBar.barTintColor = Colors.returnRedConverfit()
        self.navigationController?.navigationBar.tintColor = UIColor.white()
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyBoard()
        return true
    }
    
    //MARK: - Ocultar teclado
    func dismissKeyBoard(){
        self.view.endEditing(true)
    }
    
    //MARK: - Show Alert
    func showAlert(){
        if recoverPassOk{
            alertTitle = "Revise su correco electrónico"
        }
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        if showAppleStore{
            alert.addAction(UIAlertAction(title: "IR A APP STORE", style: .default, handler: { (action) -> Void in
                //Falta implementar el boto para mostrar pero de momento no tenemos id
                print("IR A APP STORE")/*
                let url  = NSURL(string: "itms-apps://itunes.apple.com/app/id1024941703")
                if UIApplication.sharedApplication().canOpenURL(url!) == true  {
                UIApplication.sharedApplication().openURL(url!)
                }*/
            }))
        }else{
            if recoverPassOk{
                alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { (action) -> Void in
                    _=self.navigationController?.popToRootViewController(animated: true)
                }))
            }else{
                alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler:nil))
            }
        }
        self.present(alert, animated: true) { () -> Void in
            self.alertTitle = ""
            self.alertMessage = ""
        }
    }
    
    //MARK: - Check Formats
    func checkFormats() -> Bool{//Check if the email and password are in correct format
        var formatCorrect = true
        if emailTxt.text!.isEmpty{
            (alertTitle, alertMessage) = Utils.returnTitleAndMessageAlert("campos_vacios")
            formatCorrect = false
        }else if !Utils.emailIsValid(emailTxt.text!) || emailTxt.text!.characters.count > 155{
            (alertTitle, alertMessage) = Utils.returnTitleAndMessageAlert("formato_email")
            formatCorrect = false
        }
        return formatCorrect
    }

    //MARK: - RecoverPassword Server
    func recoverPassword(_ email: String){
        let params = "action=create_lost_password_code&email=\(email)&lang=es&app=\(app)"
        let urlServidor = "http://www.converfit.com/server/app/1.0.0/models/access/model.php"
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let recoverPasswordTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        self.recoverPassOk = true
                        self.alertMessage = "Siga las instrucciones que se indican en el correo para recuperar su contraseña. Puede que el correo llegue a su cuenta de Spam."
                    }else{
                        let codigoError = json["error_code"] as? String ?? ""
                        (self.alertTitle,self.alertMessage) = Utils.returnTitleAndMessageAlert(codigoError)
                    }
                }
            } catch{
                (self.alertTitle,self.alertMessage) = Utils.returnTitleAndMessageAlert("error")
                DispatchQueue.main.async(execute: { () -> Void in
                    self.showAlert()
                })
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.showAlert()
            })
        }
        recoverPasswordTask.resume()
    }
}
