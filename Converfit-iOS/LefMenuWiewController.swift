//
//  LefMenuWiewController.swift
//  Converfit-iOS
//
//  Created by Manuel Citious on 16/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class LefMenuWiewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var miTablaPersonalizada: UITableView!
    @IBOutlet weak var lblEstadoChat: UILabel!
    
    //MARK: - Actions
    @IBAction func tapQuickOptions(sender: AnyObject) {
        
    }
    
    //MARK: - LifeCycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        modificarUI()
        checkStatusleftMenu()
    }
    
    //MARK: - Utils
    func modificarUI(){
        miTablaPersonalizada.tableFooterView = UIView()
        miTablaPersonalizada.backgroundColor = UIColor.clearColor()
    }
    
    //MARK: - Check status left menu
    func checkStatusleftMenu(){
        let status = Utils.getStatusLeftMenu()
        if(status == "0"){
            lblEstadoChat.text = "CHAT DESACTIVADO"
        }else{
            lblEstadoChat.text = "CHAT ACTIVADO"
        }
    }
}
