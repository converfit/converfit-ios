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
    
    
    //MARK: - Outlets
    @IBOutlet weak var viewEmailPassword: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var lostPasswordLabel: UILabel!
    @IBOutlet weak var singUpLabel: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    //MARK: - Actions
    @IBAction func viewContainerTap(sender: AnyObject) {
        dissmisKeyBoard()
    }

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        roundViews()
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
}
