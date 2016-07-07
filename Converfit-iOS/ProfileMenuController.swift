//
//  ProfileMenuController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 7/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class ProfileMenuController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Variables
    let cellId = "CeldaUserSettings"

    //MARK: - Outlets
    @IBOutlet weak var miTablaPersonalizada: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        modificarUI()
        //Nos damos de alta para responder a la notificacion enviada por push
        NotificationCenter.default.addObserver(self, selector: #selector(self.cambiarBadge), name:NSNotification.Name(rawValue: notificationChat), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        //Nos damos de baja de la notificacion
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notificationChat), object: nil)
    }
    
    //MARK: - Utils
    //Funcion para cambiar el badge cuando nos llega una notificacion
    func cambiarBadge(){
        let tabArray =  self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabArray?.object(at: 2) as! UITabBarItem
        let numeroMensajesSinLeer = Conversation.numeroMensajesSinLeer()
        DispatchQueue.main.async(execute: { () -> Void in
            if numeroMensajesSinLeer > 0{
                tabItem.badgeValue = "\(numeroMensajesSinLeer)"
                UIApplication.shared().applicationIconBadgeNumber = numeroMensajesSinLeer
            }else{
                tabItem.badgeValue = nil
                UIApplication.shared().applicationIconBadgeNumber = 0
            }
        })
    }
    
    func modificarUI(){
        self.tabBarController?.tabBar.isHidden = true
        miTablaPersonalizada.backgroundColor = UIColor.clear()
        //Creamos un footer con un UIView para eliminar los separator extras
        miTablaPersonalizada.tableFooterView = UIView()
    }
    
    //UITableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var textoCelda = ""
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if cell == nil{
            //No teniamos ninguna celda y tenemos que crearla
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellId)
        }
        //Como solo tendremos dos filas ponemos a cada uno el titulo que le corresponda
        if indexPath.row == 0{
            textoCelda = "Datos personales"
        }else{
            textoCelda = "Contraseña"
        }
        cell?.textLabel?.text = textoCelda
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            performSegue(withIdentifier: "personalDataSegue", sender: self)
        }else{
            performSegue(withIdentifier: "passwordMenuSegue", sender: self)
        }
    }
}
