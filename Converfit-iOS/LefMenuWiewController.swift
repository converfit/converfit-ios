//
//  LefMenuWiewController.swift
//  Converfit-iOS
//
//  Created by Manuel Citious on 16/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

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
    var indexSeleccionado:NSIndexPath?
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
    
    /*
    func mostrarAlerta(){
        self.view.endEditing(true)
        let alert = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.Alert)
        alert.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausur
        if(desLoguear){
            desLoguear = false
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler: { (action) -> Void in
                LogOut.desLoguearBorrarDatos()
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                })
            }))
        }else{
            //Añadimos un bonton al alert y lo que queramos que haga en la clausur
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler:nil))
        }
        //mostramos el alert
        self.navigationController?.presentViewController(alert, animated: true) { () -> Void in
            self.tituloAlert = ""
            self.mensajeAlert = ""
        }
    }*/
    
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
        headerView.textLabel?.textColor = Utils.returnColorTextHeaderLeftMEnu()
        headerView.contentView.backgroundColor = Utils.returnColorHeaderLeftMEnu()
        headerView.textLabel?.font = UIFont.systemFontOfSize(14)
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
        //Limpiamos el texto que haya en el seachBar
        self.view.endEditing(true)
        //miSearchBar.text = "";
        //miSearchBar.showsCancelButton = false
       // miSearchBar.resignFirstResponder()
        
        indexSeleccionado = indexPath
        
        //performSegueWithIdentifier(segueShowConversationUser, sender: self)
    }
}
