//
//  FavoritosViewController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 1/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class UsersChatControllerViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Variables 
    let cellId = "CeldaListadoFavoritos"
    var sessionKey = ""
    var mensajeAlert = ""
    var tituloAlert = ""
    var listadoUsersConectados = [UserModel]()
    var listadoUsersAPP = [UserModel]()
    var datosRecibidosServidor = false
    var alertCargando = UIAlertController(title: "", message: "Cargando...", preferredStyle: .Alert)
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var tamañoLista = 0
    var desLoguear = false
    var mostrarAlert = true
    var isSubBrand = false
    let segueShowMessageUserChat = "showMessageUserChat"
    var indexSeleccionado:NSIndexPath?
    var numeroUsuarioConectados = 0
    var numeroUsuariosAPP = 0
    
    //MARK: - Outlets
    @IBOutlet weak var miTablaPersonalizada: UITableView!
    @IBOutlet weak var miSearchBar: UISearchBar!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.tabBarController?.tabBar.hidden = false
        self.editButtonItem().title = "Editar"
        if(vieneDeListadoMensajes){
            self.tabBarController?.selectedIndex = 2
            vieneDeListadoMensajes = false
            
        }//else{
            listadoUsersConectados = User.devolverUsuariosConectados()
            listadoUsersAPP = User.devolverUsuariosAPP()
            numeroUsuarioConectados = User.devolverNumeroUsuariosConectados()
            numeroUsuariosAPP = User.devolverNumeroUsuariosAPP()
            if(!listadoUsersConectados.isEmpty || !listadoUsersAPP.isEmpty){
                datosRecibidosServidor = true
            }
            recuperarUserServidor()
            
            modificarUI()
            //Tenemos que forzar la recarga para que cuando cambiemos con el tabBar se recargue correctamente
            miTablaPersonalizada.reloadData()
        //}
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /*if(listadoUsers.isEmpty && !datosRecibidosServidor && mostrarAlert){
            mostrarAlert = false
            spinner.color = UIColor.blackColor()
            spinner.frame = CGRectMake(0, 12, 100, 44)
            spinner.hidden = false
            spinner.startAnimating()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.alertCargando.view.addSubview(self.spinner)
                self.presentViewController(self.alertCargando, animated: true) { () -> Void in
                    
                }
            })
        }*/
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        miSearchBar.showsCancelButton = false
        resetContexto()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Utils
    func resetContexto(){
        //Funcion que utilizamos para poner los datos por defecto cuando desaparece la pantalla
        //listadoUsersConectados.removeAll(keepCapacity: false)
        //listadoUsersAPP.removeAll(keepCapacity: false)
        miTablaPersonalizada.reloadData()
        mensajeAlert = ""
        tituloAlert = ""
        miSearchBar.text = ""
        mostrarAlert = true
        self.view.endEditing(true)
    }
    
    //Funcion para cambiar el badge cuando nos llega una notificacion
    func cambiarBadge(){
        let tabArray =  self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabArray.objectAtIndex(2) as! UITabBarItem
        let numeroMensajesSinLeer = Conversation.numeroMensajesSinLeer()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if(numeroMensajesSinLeer > 0){
                tabItem.badgeValue = "\(numeroMensajesSinLeer)"
                UIApplication.sharedApplication().applicationIconBadgeNumber = numeroMensajesSinLeer
            }else{
                tabItem.badgeValue = nil
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
        })
    }
    
    func modificarUI(){
        miTablaPersonalizada.tableFooterView = UIView()
        miTablaPersonalizada.backgroundColor = UIColor.clearColor()
    }
    
    func mostrarAlerta(){
        self.view.endEditing(true)
        let alert = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.Alert)
        alert.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausur
        if(desLoguear){
            desLoguear = false
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler: { (action) -> Void in
                LogOut.desLoguearBorrarDatos()
                self.navigationController?.popToRootViewControllerAnimated(false)
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
    }
    
    //MARK: - ComunicacionServidor
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
                                            self.datosRecibidosServidor = true
                                            //self.listadoUsers = User.devolverListaUsers()
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
                            if let codigoError = json.objectForKey("error_code") as? String{
                                self.datosRecibidosServidor = true
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    /*self.alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
                                        
                                    })*/
                                    if(codigoError != "list_users_empty"){
                                        self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                                        (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            self.mostrarAlerta()
                                        })
                                    }else{
                                        self.mostrarAlert = false
                                    }
                                })
                                
                            }
                        }
                    }
                }
            } catch{
                self.spinner.stopAnimating()
                /*self.alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })*/
                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.mostrarAlerta()
                })
            }
        }
        recuperarUsersTask.resume()
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
        headerView.textLabel?.textColor = UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1)
        headerView.textLabel?.font = UIFont.systemFontOfSize(16)
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! CeldaListadoFavoritos
        var user:UserModel
        if(indexPath.section == 0){
            user = listadoUsersConectados[indexPath.row]
        }else{
            user = listadoUsersAPP[indexPath.row]
        }
        cell.imagenAvatar.image = user.avatar
        cell.name.text = user.userName
        cell.lastPage.text = user.lastPageTitle
        cell.hora.text = Fechas.devolverTiempo(user.horaConectado)
        let conectionStatus = user.connectionStatus
        if(conectionStatus == "online"){
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Online")
        }else if(conectionStatus == "offline"){
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Offline")
        }else if(conectionStatus == "inactive"){
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Inactive")
        }else{
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Mobile")
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Limpiamos el texto que haya en el seachBar
        self.view.endEditing(true)
        miSearchBar.text = "";
        miSearchBar.showsCancelButton = false
        miSearchBar.resignFirstResponder()
        
        indexSeleccionado = indexPath
        
        performSegueWithIdentifier(segueShowMessageUserChat, sender: self)
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //Usamos este metodo para ver si el indexPath es igual a la ultima celda
        if(indexPath.isEqual(tableView.indexPathsForVisibleRows?.last) && datosRecibidosServidor){
            datosRecibidosServidor = false
            spinner.stopAnimating()
            /*alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })*/
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == segueShowMessageUserChat){
            let indice = indexSeleccionado?.row
            var user:UserModel
            if(indexSeleccionado!.section == 0){
                user = listadoUsersConectados[indice!]
            }else{
                user = listadoUsersAPP[indice!]
            }
            let (userHasConversation, conversationKey) = Conversation.existeConversacionDeUsuario(user.userKey)
             let messagesVC = segue.destinationViewController as! AddConversacionController
            if(userHasConversation){
                messagesVC.conversacionNueva = false
                messagesVC.conversationKey = conversationKey

            }else{
                messagesVC.conversacionNueva = true
            }
            messagesVC.userKey = user.userKey
            messagesVC.userName = user.userName
        }
    }
}

//Extension para la gestion del SearcBar
extension UsersChatControllerViewController: UISearchBarDelegate{
    //Funcion que se ejecuta cada vez que se cambia el texto de busqueda
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        var textoBuscado = searchBar.text!
        if(!Utils.quitarEspacios(textoBuscado).isEmpty){
            //listadoUsersConectados.removeAll(keepCapacity: false)
            //listadoUsersAPP.removeAll(keepCapacity: false)
            //Eliminamos los espacios al final del texto
            textoBuscado = textoBuscado.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            listadoUsersConectados = User.buscarUserConectado(textoBuscado)
            listadoUsersAPP = User.buscarUserAPP(textoBuscado)
            numeroUsuarioConectados = listadoUsersConectados.count
            numeroUsuariosAPP = listadoUsersAPP.count
            miTablaPersonalizada.reloadData()
        }else{//Si esta vacio lo vaciamos por si era un espacio el introducido
            searchBar.text = ""
            searchBar.showsCancelButton = false
            searchBar.resignFirstResponder()
            //listadoUsersConectados.removeAll(keepCapacity: false)
            //listadoUsersAPP.removeAll(keepCapacity: false)
            listadoUsersConectados = User.devolverUsuariosConectados()
            listadoUsersAPP = User.devolverUsuariosAPP()
            numeroUsuarioConectados = listadoUsersConectados.count
            numeroUsuariosAPP = listadoUsersAPP.count
            miTablaPersonalizada.reloadData()
        }
    }
    
    //Funcion que se ejecuta cuando pulsamos en el boton Search
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    //Funcion que se ejecuta cuando pulsamos en cancelar
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        self.view.endEditing(true)
        if(!searchBar.text!.isEmpty){
            searchBar.text = ""
            //listadoUsersConectados.removeAll(keepCapacity: false)
            //listadoUsersAPP.removeAll(keepCapacity: false)
            listadoUsersConectados = User.devolverUsuariosConectados()
            listadoUsersAPP = User.devolverUsuariosAPP()
            numeroUsuarioConectados = listadoUsersConectados.count
            numeroUsuariosAPP = listadoUsersAPP.count
            miTablaPersonalizada.reloadData()
        }
    }
}

