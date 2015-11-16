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

    //MARK: - Outlets
    @IBOutlet weak var centerYconstraint: NSLayoutConstraint!
    @IBOutlet weak var createUserButton: UIButton!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var converfitIcon: UIImageView!
    
    //MARK: - Actions
    @IBAction func superControlTap(sender: AnyObject) {
        dismissKeyBoard()
    }
    @IBAction func childControlTap(sender: AnyObject) {
        dismissKeyBoard()
    }
    @IBAction func singUpPress(sender: AnyObject) {
        dismissKeyBoard()
    }
    
    
    //MARK: - LifeCycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        customizeSingUpButton()
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
    
    //MARK: - Customize SingUpButton
    func customizeSingUpButton(){
        createUserButton.layer.cornerRadius = 5
        createUserButton.layer.borderWidth = 0.5
        createUserButton.layer.borderColor = Colors.returnColorBorderButtons().CGColor
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyBoard()
        return true
    }
}
