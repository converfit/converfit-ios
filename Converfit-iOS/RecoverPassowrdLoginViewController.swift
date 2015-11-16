//
//  RecoverPassowrdLoginViewController.swift
//  Converfit-iOS
//
//  Created by Manuel Citious on 16/11/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class RecoverPassowrdLoginViewController: UIViewController, UITextFieldDelegate {

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
}
