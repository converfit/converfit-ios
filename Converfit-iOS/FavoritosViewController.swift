//
//  FavoritosViewController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 1/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class FavoritosViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Variables 
    let cellId = "CeldaListadoFavoritos"
    var sessionKey = ""
    var mensajeAlert = ""
    var tituloAlert = ""
    var listadoUsers = [UserModel]()
    var datosRecibidosServidor = false
    var alertCargando = UIAlertController(title: "", message: "Cargando...", preferredStyle: .Alert)
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var tamañoLista = 0
    var desLoguear = false
    var mostrarAlert = true
    var isSubBrand = false
    let segueShowConversationUser = "showConversationUser"
    var indexSeleccionado:NSIndexPath?
    
    //MARK: - Outlets
    @IBOutlet weak var miTablaPersonalizada: UITableView!
    @IBOutlet weak var miSearchBar: UISearchBar!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.editButtonItem().title = "Editar"
        if(vieneDeListadoMensajes){
            self.tabBarController?.selectedIndex = 2
            vieneDeListadoMensajes = false
        }else{
            listadoUsers = User.devolverListaUsers()
            if(!listadoUsers.isEmpty){
                datosRecibidosServidor = true
            }
            recuperarUserServidor()
            
            modificarUI()
            //Tenemos que forzar la recarga para que cuando cambiemos con el tabBar se recargue correctamente
            miTablaPersonalizada.reloadData()
        }
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
        listadoUsers.removeAll(keepCapacity: false)
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
        self.tabBarController?.tabBar.hidden = false
        miTablaPersonalizada.tableFooterView = UIView()
        miTablaPersonalizada.backgroundColor = UIColor.clearColor()
    }
    
    func mostrarAlerta(){
        self.view.endEditing(true)
        let alert = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.Alert)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausur
        alert.addAction(UIAlertAction(title: "Aceptar", style: .Default, handler:nil))
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
                                        if let listaUsuarios = dataResultado.objectForKey("users") as? NSArray{
                                            User.borrarAllUsers()
                                            //Llamamos por cada elemento del array de empresas al constructor
                                            for dict in listaUsuarios{
                                                _=User(aDict: dict as! NSDictionary)
                                            }
                                        }
                                        self.datosRecibidosServidor = true
                                        self.listadoUsers = User.devolverListaUsers()
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            self.miTablaPersonalizada.reloadData()
                                        })
                                    }
                                }
                            }
                        }
                        else{
                            if let codigoError = json.objectForKey("error_code") as? String{
                                self.datosRecibidosServidor = true
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
                                        if(codigoError != "list_users_empty"){
                                            (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                            self.mostrarAlerta()
                                        }else{
                                            self.mostrarAlert = false
                                        }
                                    })
                                })
                                
                            }
                        }
                    }
                }
            } catch{
                self.spinner.stopAnimating()
                self.alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
                    (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                    self.mostrarAlerta()
                })
            }
        }
        recuperarUsersTask.resume()
    }
        
    //MARK: - Table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listadoUsers.count// Create 1 row as an example
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! CeldaListadoFavoritos
        cell.imagenAvatar.image = listadoUsers[indexPath.row].avatar
        cell.name.text = listadoUsers[indexPath.row].userName
        cell.lastPage.text = listadoUsers[indexPath.row].lastPageTitle
        cell.hora.text = Fechas.devolverTiempo(listadoUsers[indexPath.row].horaConectado)
        let conectionStatus = listadoUsers[indexPath.row].connectionStatus
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
        
        performSegueWithIdentifier(segueShowConversationUser, sender: self)
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //Usamos este metodo para ver si el indexPath es igual a la ultima celda
        if(indexPath.isEqual(tableView.indexPathsForVisibleRows?.last) && datosRecibidosServidor){
            datosRecibidosServidor = false
            spinner.stopAnimating()
            alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == segueShowConversationUser){
            let indice = indexSeleccionado?.row
            let (userHasConversation, conversationKey) = Conversation.existeConversacionDeUsuario(listadoUsers[indice!].userKey)
             let messagesVC = segue.destinationViewController as! AddConversacionController
            if(userHasConversation){
                messagesVC.conversacionNueva = false
                messagesVC.conversationKey = conversationKey

            }else{
                messagesVC.conversacionNueva = true
            }
            messagesVC.userKey = listadoUsers[indice!].userKey
            messagesVC.userName = listadoUsers[indice!].userName
        }
    }
}

//Extension para la gestion del SearcBar
extension FavoritosViewController: UISearchBarDelegate{
    //Funcion que se ejecuta cada vez que se cambia el texto de busqueda
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        var textoBuscado = searchBar.text!
        if(!Utils.quitarEspacios(textoBuscado).isEmpty){
            listadoUsers.removeAll(keepCapacity: false)
            //Eliminamos los espacios al final del texto
            textoBuscado = textoBuscado.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            listadoUsers = User.buscarUser(textoBuscado)
            miTablaPersonalizada.reloadData()
        }else{//Si esta vacio lo vaciamos por si era un espacio el introducido
            searchBar.text = ""
            searchBar.showsCancelButton = false
            searchBar.resignFirstResponder()
            listadoUsers.removeAll(keepCapacity: false)
            listadoUsers = User.devolverListaUsers()
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
            listadoUsers.removeAll(keepCapacity: false)
            listadoUsers = User.devolverListaUsers()
            miTablaPersonalizada.reloadData()
        }
    }
}

