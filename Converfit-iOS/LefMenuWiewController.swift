//
//  LefMenuWiewController.swift
//  Converfit-iOS
//
//  Created by Manuel Citious on 16/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit
var userKeyMenuSeleccionado = ""
var myTimerLeftMenu = Timer.init()

class LefMenuWiewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var miTablaPersonalizada: UITableView!
    @IBOutlet weak var lblEstadoChat: UILabel!
    
    //MARK: - Actions
    @IBAction func tapQuickOptions(_ sender: AnyObject) {
        let status = Utils.getStatusLeftMenu()
        if status == "0"{
            showAlertSheet("Activar chat")
        }else{
            showAlertSheet("Desactivar chat")
        }
    }
    
    //MARK: - Variables
    let cellId = "CeldaMenuLeft"
    var listadoUsersConectados = [UserModel]()
    var listadoUsersAPP = [UserModel]()
    var numeroUsuarioConectados = 0
    var numeroUsuariosAPP = 0
    
    //MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        modificarUI()
        checkStatusleftMenu()
        listadoUsersConectados = User.devolverUsuariosConectados()
        listadoUsersAPP = User.devolverUsuariosAPP()
        numeroUsuarioConectados = User.devolverNumeroUsuariosConectados()
        numeroUsuariosAPP = User.devolverNumeroUsuariosAPP()
        miTablaPersonalizada.reloadData()
        recuperarUserServidor()
        NotificationCenter.default().addObserver(self, selector: #selector(self.openMenu), name:notificationsOpenDrawerMenu , object: nil)
        myTimerLeftMenu = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.recuperarUserServidorTimer), userInfo: nil, repeats: true)
    }
    
    //MARK: - Utils
    func modificarUI(){
        miTablaPersonalizada.tableFooterView = UIView()
        miTablaPersonalizada.backgroundColor = UIColor.clear()
    }
    
    //MARK: - Check status left menu
    func checkStatusleftMenu(){
        let status = Utils.getStatusLeftMenu()
        if status == "0"{
            lblEstadoChat.text = "CHAT DESACTIVADO"
        }else{
            lblEstadoChat.text = "CHAT ACTIVADO"
        }
    }
    
    //MARK: - OpenMenu
    func openMenu(){
        miTablaPersonalizada.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        listadoUsersConectados = User.devolverUsuariosConectados()
        listadoUsersAPP = User.devolverUsuariosAPP()
        numeroUsuarioConectados = User.devolverNumeroUsuariosConectados()
        numeroUsuariosAPP = User.devolverNumeroUsuariosAPP()
        miTablaPersonalizada.reloadData()
    }
    
    //MARK:- recuperarUserServidorTimer
    func recuperarUserServidorTimer(){
        recuperarUserServidor()
    }
    
    
    //MARK: - Show alertSheet
    func showAlertSheet(_ titleAction:String){
        let alertSheetMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertSheetMenu.addAction(UIAlertAction(title: titleAction, style: .default, handler: { (action) -> Void in
            if titleAction == "Activar chat"{
                self.enableOrDisableChat("1")
            }else{
                self.enableOrDisableChat("0")
            }
        }))
        
        alertSheetMenu.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action) -> Void in
            
        }))
        self.present(alertSheetMenu, animated: true, completion: nil)
    }
    
    //MARK: - Enable or disable Chat
    func enableOrDisableChat(_ enableString:String){
        let sessionKey = Utils.getSessionKey()
        let params = "action=update_brand_webchat_status&session_key=\(sessionKey)&webchat_status=\(enableString)"
        let urlServidor = Utils.returnUrlWS("webchat")
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let enableTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        DispatchQueue.main.async(execute: { () -> Void in
                            dbErrorContador = 0
                            Utils.saveStatusLeftMenu(enableString)
                            self.checkStatusleftMenu()
                        })
                    }else{
                        //No hacemos nada
                    }
                }
            } catch{
                
            }
        }
        enableTask.resume()
    }
    
    //MARK: - Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "CONECTADOS"
        }else{
            return "CITIOUS APP"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = Colors.returnColorTextHeaderLeftMEnu()
        headerView.contentView.backgroundColor = Colors.returnColorHeaderLeftMEnu()
        headerView.textLabel?.font = UIFont.systemFont(ofSize: 12)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if numeroUsuarioConectados == 0 && section == 0{
            return 0.0
        }else if numeroUsuariosAPP == 0 && section == 1{
            return 0.0
        }else{
            return 30.0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return numeroUsuarioConectados
        }else{
            return numeroUsuariosAPP
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! CeldaLeftMenu
        var user:UserModel
        if indexPath.section == 0{
            user = listadoUsersConectados[indexPath.row]
        }else{
            user = listadoUsersAPP[indexPath.row]
        }
        cell.imagenAvatar.image = user.avatar
        cell.name.text = user.userName
        cell.hora.text = Fechas.devolverTiempo(user.horaConectado)
        let conectionStatus = user.connectionStatus
        if conectionStatus == "online"{
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Online")
        }else if conectionStatus == "offline"{
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Offline")
        }else if conectionStatus == "inactive"{
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Inactive")
        }else{
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Mobile_Quick")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            userKeyMenuSeleccionado = listadoUsersConectados[indexPath.row].userKey
        }else{
            userKeyMenuSeleccionado = listadoUsersAPP[indexPath.row].userKey
        }
        NotificationCenter.default().post(name: Notification.Name(rawValue: notificationToggleMenu), object: nil)
        NotificationCenter.default().post(name: Notification.Name(rawValue: notificationItemMenuSelected), object: nil)
    }
    
    func recuperarUserServidor(){
        let sessionKey = Utils.getSessionKey()
        let usersLastUpdate = Utils.getLastUpdateFollower()
        let params = "action=list_users&session_key=\(sessionKey)&users_last_update=\(usersLastUpdate)&offset=\(0)&limit=\(1000)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("brands")
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let recuperarUsersTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                            let lastUpdate = dataResultado["users_last_update"] as? String ?? ""
                            Utils.saveLastUpdateFollower(lastUpdate)
                            let needUpdate = dataResultado["need_to_update"] as? Bool ?? true
                            if needUpdate{
                                DispatchQueue.main.async(execute: { () -> Void in
                                    if let listaUsuarios = dataResultado["users"] as? [Dictionary<String, AnyObject>]{
                                        _=User.borrarAllUsers()
                                        //Llamamos por cada elemento del array de empresas al constructor
                                        for dict in listaUsuarios{
                                            _=User(aDict: dict)
                                        }
                                    }
                                    self.listadoUsersConectados = User.devolverUsuariosConectados()
                                    self.numeroUsuarioConectados = User.devolverNumeroUsuariosConectados()
                                    self.numeroUsuariosAPP = User.devolverNumeroUsuariosAPP()
                                    self.listadoUsersAPP = User.devolverUsuariosAPP()
                                    self.miTablaPersonalizada.reloadData()
                                })
                            }
                        }
                    }else{
                        //let codigoError = json["error_code"] as?  String ?? ""
                    }
                }
            } catch{
            }
        }
        recuperarUsersTask.resume()
    }
}
