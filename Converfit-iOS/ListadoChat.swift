//
//  FullConversacionesController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 31/3/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class ListadoChat: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    //MARK: - Variables
    var sessionKey = ""
    var mensajeAlert = ""
    var tituloAlert = ""
    var listadoConversaciones = [ConversationsModel]()
    var mostrarError = false
    var datosRecibidosServidor = false
    var obtenerTodosMensajes = false
    var alertCargando = UIAlertController(title: "", message: "Cargando...", preferredStyle: .Alert)
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var numeroMensajesSinLeer = 0
    var isPush = false
    var listadoVacio = false
    var desLoguear = false
    var mostrarAlert = true
    var isSubBrand = false
    
    //MARK: - Outlets
    @IBOutlet weak var miTabla: UITableView!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        desactivarBotonEdit()//Deshabilitamos los botones por defecto por si no se produce la carga
        crearBotonesCabecera()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.editButtonItem().title = "Editar"
        let defaults = NSUserDefaults.standardUserDefaults()
        sessionKey = defaults.stringForKey("session_key")!
        listadoConversaciones = Conversation.devolverListConversations()
        if(listadoConversaciones.isEmpty){
            listadoVacio = true
        }else{
            datosRecibidosServidor = true
            miTabla.reloadData()
        }
        //recuperarConversationsServidor(sessionKey)
       
        //Creamos un footer con un UIView para eliminar los separator extras
        miTabla.tableFooterView = UIView()
        self.tabBarController?.tabBar.hidden = false
        
        //Establecemos el titulo de la pestaña origin y el  indicador a true para indicar que vamos desde una de las pantallas iniciales del tabBar
        
        self.setEditing(false, animated: true)
        addBadgeCount()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        resetContexto()
        miTabla.reloadData()
        //Nos damos de baja de la notificacion
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - ComunicacionServidor
    /*
    func recuperarConversationsServidor(sessionKey:String){
        var downloadQueue:NSOperationQueue = {
            var queue = NSOperationQueue()
            queue.name = "Download queue"
            queue.maxConcurrentOperationCount = 1
            return queue
            }()
        
        var conversationLasUp = Utils.obtenerConversationsLastUpdate()
        let urlServidor = Utils.devolverURLservidor("conversations")
        let params = "action=list_conversations&session_key=\(sessionKey)&conversations_last_update=\(conversationLasUp)&offset=\(0)&limit=\(1000)&app_version=\(appVersion)&app=\(app)"
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        request.HTTPMethod = "POST"
        
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: downloadQueue) { (response, data, error) -> Void in
            if(data!.length > 0){
                let JSONObjetcs:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                if let codigoResultado = JSONObjetcs.objectForKey("result") as? Int{
                    if(codigoResultado == 1){
                        dbErrorContador = 0
                        if let dataResultado = JSONObjetcs.objectForKey("data") as? NSDictionary{
                            if let lastUpdate = dataResultado.objectForKey("conversations_last_update") as? String{
                                Utils.guardarConversationsLastUpdate(lastUpdate)
                            }
                            if let needToUpdate = dataResultado.objectForKey("need_to_update") as? Bool{
                                if(needToUpdate){
                                    if let conversations = dataResultado.objectForKey("conversations") as? [NSDictionary]{
                                        //Borramos las conversaciones que tengamos guardadas y no esten en el array devuelvo por el WS
                                        self.borrarConversacionesSobrantes(conversations)
                                        //Llamamos por cada elemento del array de empresas al constructor
                                        for dict in conversations{
                                            var conversationKey = self.obtenerConversationKey(dict)
                                            var lastUpdateConversacion = Conversation.obtenerLastUpdate(conversationKey)
                                            var existe = Conversation.existeConversacion(conversationKey)
                                            Conversation.borrarConversationConSessionKey(conversationKey, update: true)
                                            Conversation(aDict: dict , aLastUpdate: lastUpdateConversacion, existe: existe)
                                        }
                                        self.listadoConversaciones = Conversation.devolverListConversations()
                                        self.datosRecibidosServidor = true
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            self.miTabla.reloadData()
                                        })
                                    }
                                }else{
                                    self.mostrarAlert = false
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.spinner.stopAnimating()
                                        self.alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
                                            
                                        })
                                        self.desactivarBotonEdit()
                                    })
                                }
                            }
                        }
                    }else{
                        if let codigoError = JSONObjetcs.objectForKey("error_code") as? String{
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                var cerradaAlert = false
                                self.alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
                                
                                })
                                if(codigoError != "list_conversations_empty"){
                                    self.desLoguear = Utils.comprobarDesloguear(codigoError)
                                    (self.tituloAlert,self.mensajeAlert) = Utils().establecerTituloMensajeAlert(codigoError)
                                    self.mostrarAlerta()
                                }else{
                                    self.mostrarAlert = false
                                    self.listadoConversaciones.removeAll(keepCapacity: false)
                                    Conversation.borrarAllConversations()
                                    self.miTabla.reloadData()
                                }
                                self.desactivarBotonEdit()
                            })
                        }
                    }
                }
            }else{
                (self.tituloAlert,self.mensajeAlert) = Utils().establecerTituloMensajeAlert("error")
                self.mostrarAlerta()
            }
        }
    }
   */
    /*
    func borrarConversacion(conversationKey:String){
        var downloadQueue:NSOperationQueue = {
            var queue = NSOperationQueue()
            queue.name = "Download queue"
            queue.maxConcurrentOperationCount = 60
            return queue
            }()
        
        let params = "action=delete_conversation&session_key=\(sessionKey)&conversation_key=\(conversationKey)&app_version=\(appVersion)&app=\(app)"
        
        let urlServidor = Utils.devolverURLservidor("conversations")
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        request.HTTPMethod = "POST"
        
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(request, queue: downloadQueue) { (response, data, error) -> Void in
            if(error != nil){
                if(error!.code == -1005){
                    self.borrarConversacion(conversationKey)
                }else{
                    (self.tituloAlert,self.mensajeAlert) = Utils().establecerTituloMensajeAlert("error")
                    self.mostrarAlerta()
                }
            }else{
                if(data!.length > 0){
                    var JSONObjetcs:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                    if let codigoResultado = JSONObjetcs.objectForKey("result") as? Int{
                        if(codigoResultado == 1){
                            dbErrorContador = 0
                            //Guardamos el last update del usuario
                            if let dataResultado = JSONObjetcs.objectForKey("data") as? NSDictionary{
                                if let lastUpdate = dataResultado.objectForKey("conversations_last_update") as? String{
                                    Utils.guardarConversationsLastUpdate(lastUpdate)
                                }
                            }
                        }
                        else{
                            if let codigoError = JSONObjetcs.objectForKey("error_code") as? String{
                                if(codigoError != "list_conversations_empty"){
                                    self.desLoguear = Utils.comprobarDesloguear(codigoError)
                                    (self.tituloAlert,self.mensajeAlert) = Utils().establecerTituloMensajeAlert(codigoError)
                                    self.mostrarAlerta()
                                }
                            }
                        }
                    }
                }else{
                    (self.tituloAlert,self.mensajeAlert) = Utils().establecerTituloMensajeAlert("error")
                    self.mostrarAlerta()
                }
            }
        }
    }
    */
    //MARK: - Utils
    func  borrarConversacionesSobrantes(conversations:NSArray){
        var listCkeys = [String]()
        //Creamos un array con todas las conversationsKey que nos devuelve el WS
        for conversacion in conversations{
            let ckey = obtenerConversationKey(conversacion as! NSDictionary)
            listCkeys.append(ckey)
        }
        
        for miConversacion in listadoConversaciones{
            if let _ = listCkeys.indexOf(miConversacion.conversationKey) {
                //Como no da error significa que existe y por lo tanto no hacemos nada
            }else{
                //Como no existe el conversationKey en la lista que devuelve el servidor lo borramos de nuestro CoreData
                Conversation.borrarConversationConSessionKey(miConversacion.conversationKey, update: true)
            }
        }
    }
    func obtenerConversationKey(aDict:NSDictionary) -> String{
        var conversationKey = "0"
        //Guardamos el conversationKey
        if let aConversationKey = aDict.objectForKey("conversation_key") as? String{
            conversationKey = aConversationKey
        }
        return conversationKey
    }
    
    func resetContexto(){//Reseteamos el valor de las variables a por defecto
        sessionKey = ""
        mensajeAlert = ""
        tituloAlert = ""
        //Vaciamos el Array de conversaciones para que cuando añadamos una nueva al volver no se dupliquen
        listadoConversaciones.removeAll(keepCapacity: false)
        mostrarError = false
        datosRecibidosServidor = false
        obtenerTodosMensajes = false
        numeroMensajesSinLeer = 0
        isPush = false
        listadoVacio = false
        mostrarAlert = true
    }
    
    func recargarPantalla(){//Funcion a la que llamamos cuando se recibe una notificacion para recargar la pantalla
        isPush = true
        //Reseteamos los valores a los originales
        listadoConversaciones.removeAll(keepCapacity: false)
        //Obtenemos los datos
        let defaults = NSUserDefaults.standardUserDefaults()
        if let session = defaults.stringForKey("session_key")
        {
            sessionKey = session
            listadoConversaciones = Conversation.devolverListConversations()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.miTabla.reloadData()
                self.addBadgeCount()
                self.desactivarBotonEdit()
            })
        }
    }
    
    func desactivarBotonEdit(){
        if(listadoConversaciones.count == 0){
            self.editButtonItem().enabled = false
            self.editButtonItem().title = ""
            self.setEditing(false, animated: true)
        }else{
            self.editButtonItem().enabled = true
            self.editButtonItem().title = "Editar"
        }
        /*
        if(User.devolverListaUsers().count == 0 || Utils.obtenerIsGroupSubBrand()){
            navigationItem.rightBarButtonItem?.enabled = false
        }else{
            navigationItem.rightBarButtonItem?.enabled = true
        }
        */
    }
    
    func crearBotonesCabecera(){
        //Añadimos un boton para ver las empresas
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action:"getListBrands")
       /* isSubBrand = Utils.obtenerIsGroupSubBrand()
        if(User.devolverListaUsers().count == 0 || isSubBrand){
            rightButton.enabled = false
        }else{
            rightButton.enabled = true
        }*/
        navigationItem.rightBarButtonItem = rightButton
        // Ponemos el boton de editar para borrar la tabla
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    func getListBrands(){
        //let listBrandVC = self.storyboard?.instantiateViewControllerWithIdentifier("ListBrand") as! ListBrandController
        //self.navigationController?.pushViewController(listBrandVC, animated: true)
    }
    
    func mostrarAlerta(){
        self.view.endEditing(true)
        let alert = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.Alert)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausura
        alert.addAction(UIAlertAction(title: "Aceptar", style: .Default, handler: { action in
            
        }))
        //mostramos el alert
        self.presentViewController(alert, animated: true) { () -> Void in
            self.tituloAlert = ""
            self.mensajeAlert = ""
        }
    }

    //Funcion para añadir el numero de mensajes que quedan sin leer
    func addBadgeCount(){
        let tabArray =  self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabArray.objectAtIndex(2) as! UITabBarItem
        numeroMensajesSinLeer = Conversation.numeroMensajesSinLeer()
        if(numeroMensajesSinLeer > 0){
            tabItem.badgeValue = "\(numeroMensajesSinLeer)"
            UIApplication.sharedApplication().applicationIconBadgeNumber = numeroMensajesSinLeer
        }else{
            tabItem.badgeValue = nil
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
    }

    //MARK: - Table
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listadoConversaciones.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ListadoConversaciones") as! CeldaListaConversacion
        
        cell.brandName.text = listadoConversaciones[indexPath.row].fname + " " + listadoConversaciones[indexPath.row].lname
        cell.lastMessage.text = listadoConversaciones[indexPath.row].lastMessage
        cell.avatarImagen?.image = listadoConversaciones[indexPath.row].avatar
        let fechaLastMessage = listadoConversaciones[indexPath.row].lastMessageCreation
        cell.lastMessageCreation.text = Fechas.convertirFechaUnixToString(fechaLastMessage)
        //comprobamos el Flag para cambiar el color del texto
        if(listadoConversaciones[indexPath.row].flagNewMessageUser){
            cell.lastMessageCreation.textColor = UIColor.blueColor()
            cell.imagenNuevoMensaje.image = UIImage(named: "NuevoMensaje")
        }else{
            cell.lastMessageCreation.textColor = UIColor.blackColor()
            cell.imagenNuevoMensaje.image = nil
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*
        let addConversacionVC = self.storyboard?.instantiateViewControllerWithIdentifier("AddConversation") as! AddConversacionController
        //Rellenamos los valores que queramos pasar al otro VC
        addConversacionVC.sessionKey = sessionKey
        addConversacionVC.userKey = listadoConversaciones[indexPath.row].userkey
        addConversacionVC.conversacionNueva = false
        addConversacionVC.userName = listadoConversaciones[indexPath.row].fname + " " + listadoConversaciones[indexPath.row].lname
        addConversacionVC.conversationKey = listadoConversaciones[indexPath.row].conversationKey
        self.navigationController?.pushViewController(addConversacionVC, animated: true)
        */
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            /*borrarConversacion(listadoConversaciones[indexPath.row].conversationKey)
            Conversation.borrarConversationConSessionKey(listadoConversaciones[indexPath.row].conversationKey, update: false)
            listadoConversaciones.removeAll(keepCapacity: false)
            listadoConversaciones = Conversation.devolverListConversations()
            addBadgeCount()
            miTabla.reloadData()
            if(listadoConversaciones.count == 0){
                desactivarBotonEdit()
            }*/
        }
    }
    
    //Debemos hacer un override para que funcione el boton editar
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if (editing) {
            // Execute tasks for editing status
            miTabla.setEditing(editing, animated: true)
            self.navigationItem.leftBarButtonItem?.title = "OK"
        } else {
            miTabla.setEditing(editing, animated: true)
            self.navigationItem.leftBarButtonItem?.title = "Editar"
        }
    }

    //Funcion para comprobar que al acabar de cargar la tabla muestra el badge del tabBar
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //Usamos este metodo para ver si el indexPath es igual a la ultima celda
        if(indexPath.isEqual(tableView.indexPathsForVisibleRows?.last) && datosRecibidosServidor){
            if(listadoVacio){
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                   // PostServidor.guardatAllMessages(self.sessionKey, listaConversaciones: self.listadoConversaciones)
                    self.listadoVacio = false
                })
            }
            datosRecibidosServidor = false
            if(!isPush){
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.spinner.stopAnimating()
                    self.alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
            
                    })
                    self.desactivarBotonEdit()
                })
            }else{
                isPush = false
            }
            addBadgeCount()
        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Borrar"
    }
    
    //MARK: - Rotar Dispositivo
    override func shouldAutorotate() -> Bool {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.PortraitUpsideDown ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.Unknown) {
                return true
        }
        else {
            return false
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}
