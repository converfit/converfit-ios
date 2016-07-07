//
//  AjustesViewController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 1/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class AjustesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Variables
    let cellId = "CeldaUserSettings"

    //MARK: - Outlets
    @IBOutlet weak var miTablaPersonalizada: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modificarUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        vieneDeListadoMensajes = false
        if irPantallaLogin{
            irPantallaLogin = false
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
        }else{
            Utils.customAppear(self)
            //Nos damos de alta para responder a la notificacion enviada por push
            NotificationCenter.default.addObserver(self, selector: #selector(self.cambiarBadge), name:NSNotification.Name(rawValue: notificationChat), object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func modificarUI(){
        miTablaPersonalizada.backgroundColor = UIColor.clear()
        //Creamos un footer con un UIView para eliminar los separator extras
        miTablaPersonalizada.tableFooterView = UIView()
    }
    
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
    
    //UITableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var textoCelda = ""
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        //Como solo tendremos dos filas ponemos a cada uno el titulo que le corresponda
        if indexPath.row == 0{
            textoCelda = "Perfil"
        }else{
            textoCelda = "Cerrar sesión"
        }
        cell.textLabel?.text = textoCelda
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            self.performSegue(withIdentifier: "showPerfil", sender: self)
        }else{
            DispatchQueue.main.async(execute: { () -> Void in
                LogOut.desLoguearBorrarDatos()
                ocultarLogIn = false
                self.dismiss(animated: true, completion: nil)
            })
            LogOut.desLoguear()
        }
    }
}
