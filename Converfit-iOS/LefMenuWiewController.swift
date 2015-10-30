//
//  LefMenuWiewController.swift
//  Converfit-iOS
//
//  Created by Manuel Citious on 16/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit
var userKeyMenuSeleccionado = ""

class LefMenuWiewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var miTablaPersonalizada: UITableView!
    @IBOutlet weak var lblEstadoChat: UILabel!
    
    //MARK: - Actions
    @IBAction func tapQuickOptions(sender: AnyObject) {
        let status = Utils.getStatusLeftMenu()
        if(status == "0"){
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        modificarUI()
        checkStatusleftMenu()
        listadoUsersConectados = User.devolverUsuariosConectados()
        listadoUsersAPP = User.devolverUsuariosAPP()
        numeroUsuarioConectados = User.devolverNumeroUsuariosConectados()
        numeroUsuariosAPP = User.devolverNumeroUsuariosAPP()
        miTablaPersonalizada.reloadData()
        recuperarUserServidor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "openMenu", name:notificationsOpenDrawerMenu , object: nil)
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
    
    //MARK: - OpenMenu
    func openMenu(){
        miTablaPersonalizada.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        listadoUsersConectados = User.devolverUsuariosConectados()
        listadoUsersAPP = User.devolverUsuariosAPP()
        numeroUsuarioConectados = User.devolverNumeroUsuariosConectados()
        numeroUsuariosAPP = User.devolverNumeroUsuariosAPP()
        miTablaPersonalizada.reloadData()
        recuperarUserServidor()
    }
    
    
    //MARK: - Show alertSheet
    func showAlertSheet(titleAction:String){
        let alertSheetMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertSheetMenu.addAction(UIAlertAction(title: titleAction, style: .Default, handler: { (action) -> Void in
            if(titleAction == "Activar chat"){
                self.enableOrDisableChat("1")
            }else{
                self.enableOrDisableChat("0")
            }
        }))
        
        alertSheetMenu.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: { (action) -> Void in
            
        }))
        self.presentViewController(alertSheetMenu, animated: true, completion: nil)
    }
    
    //MARK: - Enable or disable Chat
    func enableOrDisableChat(enableString:String){
        let sessionKey = Utils.getSessionKey()
        let params = "action=update_brand_webchat_status&session_key=\(sessionKey)&webchat_status=\(enableString)"
        let urlServidor = Utils.returnUrlWS("webchat")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let enableTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                dbErrorContador = 0
                                Utils.saveStatusLeftMenu(enableString)
                                self.checkStatusleftMenu()
                            })
                        }else{
                            //MostrarAlerta error
                        }
                    }
                }
            } catch{
                
            }
        }
        enableTask.resume()
    }
    
    //MARK: - Table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return "CONECTADOS"
        }else{
            return "CITIOUS APP"
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = Colors.returnColorTextHeaderLeftMEnu()
        headerView.contentView.backgroundColor = Colors.returnColorHeaderLeftMEnu()
        headerView.textLabel?.font = UIFont.systemFontOfSize(12)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(numeroUsuarioConectados == 0 && section == 0){
            return 0.0
        }else if(numeroUsuariosAPP == 0 && section == 1){
            return 0.0
        }else{
            return 30.0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return numeroUsuarioConectados
        }else{
            return numeroUsuariosAPP
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! CeldaLeftMenu
        var user:UserModel
        if(indexPath.section == 0){
            user = listadoUsersConectados[indexPath.row]
        }else{
            user = listadoUsersAPP[indexPath.row]
        }
        cell.imagenAvatar.image = user.avatar
        cell.name.text = user.userName
        cell.hora.text = Fechas.devolverTiempo(user.horaConectado)
        let conectionStatus = user.connectionStatus
        if(conectionStatus == "online"){
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Online")
        }else if(conectionStatus == "offline"){
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Offline")
        }else if(conectionStatus == "inactive"){
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Inactive")
        }else{
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Mobile_Quick")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0){
            userKeyMenuSeleccionado = listadoUsersConectados[indexPath.row].userKey
        }else{
            userKeyMenuSeleccionado = listadoUsersAPP[indexPath.row].userKey
        }
        NSNotificationCenter.defaultCenter().postNotificationName(notificationToggleMenu, object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(notificationItemMenuSelected, object: nil)
    }
    
    func recuperarUserServidor(){
        let sessionKey = Utils.getSessionKey()
        let usersLastUpdate = Utils.getLastUpdateFollower()
        let params = "action=list_users&session_key=\(sessionKey)&users_last_update=\(usersLastUpdate)&offset=\(0)&limit=\(1000)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("brands")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let recuperarUsersTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            if let dataResultado = json.objectForKey("data") as? NSDictionary{
                                //Guardamos el last update de favoritos
                                if let lastUpdate = dataResultado.objectForKey("users_last_update") as? String{
                                    Utils.saveLastUpdateFollower(lastUpdate)
                                }
                                //Obtenemos el need_to_update para ver si hay que actualizar la lista o no
                                if let needUpdate = dataResultado.objectForKey("need_to_update") as? Bool{
                                    if(needUpdate){
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            if let listaUsuarios = dataResultado.objectForKey("users") as? NSArray{
                                                User.borrarAllUsers()
                                                //Llamamos por cada elemento del array de empresas al constructor
                                                for dict in listaUsuarios{
                                                    _=User(aDict: dict as! NSDictionary)
                                                }
                                            }
                                            self.listadoUsersConectados = User.devolverUsuariosConectados()
                                            self.numeroUsuarioConectados = User.devolverNumeroUsuariosConectados()
                                            self.numeroUsuariosAPP = User.devolverNumeroUsuariosAPP()
                                            self.listadoUsersAPP = User.devolverUsuariosAPP()
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                self.miTablaPersonalizada.reloadData()
                                            })
                                        })
                                    }
                                }
                            }
                        }
                        else{
                            /*if let codigoError = json.objectForKey("error_code") as? String{
                                
                            }*/
                        }
                    }
                }
            } catch{
            }
        }
        recuperarUsersTask.resume()
    }
}
