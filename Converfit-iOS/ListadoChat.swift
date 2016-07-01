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
    var mensajeAlert = ""
    var tituloAlert = ""
    var listadoConversaciones = [ConversationsModel]()
    var mostrarError = false
    var datosRecibidosServidor = false
    var obtenerTodosMensajes = false
    var alertCargando = UIAlertController(title: "", message: "Cargando...", preferredStyle: .alert)
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var numeroMensajesSinLeer = 0
    var isPush = false
    var listadoVacio = false
    var desLoguear = false
    var mostrarAlert = true
    var isSubBrand = false
    var tapPosicionConversacion = 0
    let showUsersChatSegue = "showUsersChat"
    var myTimer = Timer.init()
    
    //MARK: - Outlets
    @IBOutlet weak var miTabla: UITableView!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        desactivarBotonEdit()//Deshabilitamos los botones por defecto por si no se produce la carga
        crearBotonesCabecera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.recuperarConversacionesTimer), userInfo: nil, repeats: true)
        Utils.customAppear(self)
        vieneDeListadoMensajes = false
        if irPantallaLogin{
            irPantallaLogin = false
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
       }else{
            self.editButtonItem().title = "Editar"
            listadoConversaciones = Conversation.devolverListConversations()
            if listadoConversaciones.isEmpty{
                listadoVacio = true
            }else{
                datosRecibidosServidor = true
                miTabla.reloadData()
            }
            recuperarConversaciones()
       
            //Creamos un footer con un UIView para eliminar los separator extras
            miTabla.tableFooterView = UIView()
            self.tabBarController?.tabBar.isHidden = false
        
            //Establecemos el titulo de la pestaña origin y el  indicador a true para indicar que vamos desde una de las pantallas iniciales del tabBar
        
            self.setEditing(false, animated: true)
            addBadgeCount()
            //Nos damos de alta para responder a la notificacion enviada por push
            NotificationCenter.default().addObserver(self, selector: #selector(self.recargarPantalla), name:notificationChat, object: nil)
            miTabla.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetContexto()
        miTabla.reloadData()
        //Nos damos de baja de la notificacion
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name(rawValue: notificationChat), object: nil)
        myTimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Recargar Pantalla cuando llega una Push
    func recargarPantalla(){//Funcion a la que llamamos cuando se recibe una notificacion para recargar la pantalla
        isPush = true
        //Reseteamos los valores a los originales
        listadoConversaciones.removeAll(keepingCapacity: false)
        //Obtenemos los datos
        listadoConversaciones = Conversation.devolverListConversations()
        DispatchQueue.main.async(execute: { () -> Void in
            self.miTabla.reloadData()
            self.addBadgeCount()
            self.desactivarBotonEdit()
        })
    }
    
    //MARK: - ComunicacionServidor
    func recuperarConversaciones(){
        let sessionKey = Utils.getSessionKey()
        let conversationLasUp = Utils.getConversationsLastUpdate()
        let params = "action=list_conversations&session_key=\(sessionKey)&conversations_last_update=\(conversationLasUp)&offset=\(0)&limit=\(1000)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("conversations")
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let recuperarConversacionesTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                            let lastUpdate = dataResultado["conversations_last_update"] as? String ?? ""
                            Utils.saveConversationsLastUpdate(lastUpdate)
                            let needToUpdate = dataResultado["need_to_update"] as? Bool ?? true
                            if needToUpdate{
                                if let conversations = dataResultado["conversations"] as? [Dictionary<String, AnyObject>]{
                                    //Borramos las conversaciones que tengamos guardadas y no esten en el array devuelvo por el WS
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        self.borrarConversacionesSobrantes(conversations)
                                        //Llamamos por cada elemento del array de empresas al constructor
                                        for dict in conversations{
                                            let conversationKey = self.obtenerConversationKey(dict)
                                            let lastUpdateConversacion = Conversation.obtenerLastUpdate(conversationKey)
                                            let existe = Conversation.existeConversacion(conversationKey)
                                            Conversation.borrarConversationConSessionKey(conversationKey, update: true)
                                            _ = Conversation(aDict: dict , aLastUpdate: lastUpdateConversacion, existe: existe)
                                        }
                                        self.listadoConversaciones = Conversation.devolverListConversations()
                                        self.datosRecibidosServidor = true
                                        self.miTabla.reloadData()
                                    })
                                }
                            }else{
                                self.mostrarAlert = false
                                DispatchQueue.main.async(execute: { () -> Void in
                                    self.spinner.stopAnimating()
                                    self.alertCargando.dismiss(animated: true, completion: { () -> Void in
                                        
                                    })
                                    self.desactivarBotonEdit()
                                })
                            }
                        }
                    }else{
                        let codigoError = json["error_code"] as? String ?? ""
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.alertCargando.dismiss(animated: true, completion: { () -> Void in
                                
                            })
                            if codigoError != "list_conversations_empty"{
                                self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                self.mostrarAlerta()
                            }else{
                                self.mostrarAlert = false
                                self.listadoConversaciones.removeAll(keepingCapacity: false)
                                _=Conversation.borrarAllConversations()
                                self.miTabla.reloadData()
                            }
                            self.desactivarBotonEdit()
                        })
                    }
                }
            } catch{
                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                DispatchQueue.main.async(execute: { () -> Void in
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.mostrarAlerta()
                    })
                })
            }
        }
        recuperarConversacionesTask.resume()
    }

    func borrarConversacion(_ conversationKey:String){
        let sessionKey = Utils.getSessionKey()
        let params = "action=delete_conversation&session_key=\(sessionKey)&conversation_key=\(conversationKey)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("conversations")
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let borrarConversacionTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if error != nil{
                    if error!.code == -1005{
                        self.borrarConversacion(conversationKey)
                    }else{
                        (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                        self.mostrarAlerta()
                    }
                }else{
                    if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                        let resultCode = json["reuslt"] as? Int ?? 0
                        if resultCode == 1{
                            if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                                let lastUpdate = dataResultado["conversations_last_update"] as? String ?? ""
                                Utils.saveConversationsLastUpdate(lastUpdate)
                            }
                        }else{
                            let codigoError = json["error_code"] as? String ?? ""
                            if codigoError != "list_conversations_empty"{
                                self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                DispatchQueue.main.async(execute: { () -> Void in
                                    self.mostrarAlerta()
                                })
                            }
                        }
                    }
                }
            }catch{
                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                DispatchQueue.main.async(execute: { () -> Void in
                    self.mostrarAlerta()
                })
            }
        }
        borrarConversacionTask.resume()
    }
    
    //MARK: - Utils
    func  borrarConversacionesSobrantes(_ conversations: [Dictionary<String, AnyObject>]){
        var listCkeys = [String]()
        //Creamos un array con todas las conversationsKey que nos devuelve el WS
        for conversacion in conversations{
            let ckey = obtenerConversationKey(conversacion)
            listCkeys.append(ckey)
        }
        
        for miConversacion in listadoConversaciones{
            if let _ = listCkeys.index(of: miConversacion.conversationKey) {
                //Como no da error significa que existe y por lo tanto no hacemos nada
            }else{
                //Como no existe el conversationKey en la lista que devuelve el servidor lo borramos de nuestro CoreData
                Conversation.borrarConversationConSessionKey(miConversacion.conversationKey, update: true)
            }
        }
    }
    func obtenerConversationKey(_ aDict: Dictionary<String, AnyObject>) -> String{
        return aDict["conversation_key"] as? String ?? "0"
    }
    
    func resetContexto(){//Reseteamos el valor de las variables a por defecto
        mensajeAlert = ""
        tituloAlert = ""
        //Vaciamos el Array de conversaciones para que cuando añadamos una nueva al volver no se dupliquen
        listadoConversaciones.removeAll(keepingCapacity: false)
        mostrarError = false
        datosRecibidosServidor = false
        obtenerTodosMensajes = false
        numeroMensajesSinLeer = 0
        isPush = false
        listadoVacio = false
        mostrarAlert = true
    }
        
    func desactivarBotonEdit(){
        if listadoConversaciones.count == 0{
            self.editButtonItem().isEnabled = false
            self.editButtonItem().title = ""
            self.setEditing(false, animated: true)
        }else{
            self.editButtonItem().isEnabled = true
            self.editButtonItem().title = "Editar"
        }
    }
    
    func crearBotonesCabecera(){
        //Añadimos un boton para ver las empresas
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action:#selector(self.getListBrands))
        navigationItem.rightBarButtonItem = rightButton
        // Ponemos el boton de editar para borrar la tabla
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    func getListBrands(){
        performSegue(withIdentifier: showUsersChatSegue, sender: self)
    }
    
    func mostrarAlerta(){
        self.view.endEditing(true)
        let alert = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausur
        if desLoguear{
            desLoguear = false
            myTimerLeftMenu.invalidate()
            myTimer.invalidate()
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { (action) -> Void in
                LogOut.desLoguearBorrarDatos()
                self.dismiss(animated: true, completion: { () -> Void in
                })
            }))
        }else{
            //Añadimos un bonton al alert y lo que queramos que haga en la clausura
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { action in
            
            }))
        }
        //mostramos el alert
        self.present(alert, animated: true) { () -> Void in
            self.tituloAlert = ""
            self.mensajeAlert = ""
        }
    }

    //Funcion para añadir el numero de mensajes que quedan sin leer
    func addBadgeCount(){
        let tabArray =  self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabArray?.object(at: 2) as! UITabBarItem
        numeroMensajesSinLeer = Conversation.numeroMensajesSinLeer()
        if numeroMensajesSinLeer > 0{
            tabItem.badgeValue = "\(numeroMensajesSinLeer)"
            UIApplication.shared().applicationIconBadgeNumber = numeroMensajesSinLeer
        }else{
            tabItem.badgeValue = nil
            UIApplication.shared().applicationIconBadgeNumber = 0
        }
    }

    //MARK: - Table
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listadoConversaciones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListadoConversaciones") as! CeldaListaConversacion
        
        cell.brandName.text = listadoConversaciones[indexPath.row].fname + " " + listadoConversaciones[indexPath.row].lname
        cell.lastMessage.text = listadoConversaciones[indexPath.row].lastMessage
        cell.avatarImagen?.image = listadoConversaciones[indexPath.row].avatar
        let fechaLastMessage = listadoConversaciones[indexPath.row].lastMessageCreation
        cell.lastMessageCreation.text = Fechas.devolverTiempo(fechaLastMessage)
        //comprobamos el Flag para cambiar el color del texto
        if listadoConversaciones[indexPath.row].flagNewMessageUser{
            cell.lastMessageCreation.textColor = Colors.returnColorBlackNewMessage()
            cell.brandName.textColor = Colors.returnColorBlackNewMessage()
            cell.brandName.font = UIFont.boldSystemFont(ofSize: 18)
            cell.lastMessage.textColor = Colors.returnColorBlackNewMessage()
            cell.lastMessage.font = UIFont.boldSystemFont(ofSize: 12)
        }else{
            cell.lastMessageCreation.textColor = Colors.returnColor909090()
            cell.brandName.font = UIFont.systemFont(ofSize: 18)
            cell.brandName.textColor = UIColor.black()
            cell.lastMessage.textColor = Colors.returnColor909090()
            cell.lastMessage.font = UIFont.systemFont(ofSize: 12)
        }
        let conectionStatus = listadoConversaciones[indexPath.row].connectionStatus
        if conectionStatus == "online"{
            cell.imageConnectionStatus.image = UIImage(named: "ConnectionStatus_Online")
        }else if conectionStatus == "offline"{
            cell.imageConnectionStatus.image = UIImage(named: "ConnectionStatus_Offline")
        }else if conectionStatus == "inactive"{
            cell.imageConnectionStatus.image = UIImage(named: "ConnectionStatus_Inactive")
        }else{
            cell.imageConnectionStatus.image = UIImage(named: "ConnectionStatus_Mobile")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tapPosicionConversacion = indexPath.row
        performSegue(withIdentifier: "showConversation", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            borrarConversacion(listadoConversaciones[indexPath.row].conversationKey)
            Conversation.borrarConversationConSessionKey(listadoConversaciones[indexPath.row].conversationKey, update: false)
            listadoConversaciones.removeAll(keepingCapacity: false)
            listadoConversaciones = Conversation.devolverListConversations()
            addBadgeCount()
            miTabla.reloadData()
            if listadoConversaciones.count == 0{
                desactivarBotonEdit()
            }
        }
    }
    
    //Debemos hacer un override para que funcione el boton editar
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing{
            // Execute tasks for editing status
            miTabla.setEditing(editing, animated: true)
            self.navigationItem.leftBarButtonItem?.title = "OK"
        } else {
            miTabla.setEditing(editing, animated: true)
            self.navigationItem.leftBarButtonItem?.title = "Editar"
        }
    }

    //Funcion para comprobar que al acabar de cargar la tabla muestra el badge del tabBar
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Usamos este metodo para ver si el indexPath es igual a la ultima celda
        if indexPath == tableView.indexPathsForVisibleRows?.last && datosRecibidosServidor{
            if listadoVacio{
                DispatchQueue.main.async(execute: { () -> Void in
                   // PostServidor.guardatAllMessages(self.sessionKey, listaConversaciones: self.listadoConversaciones)
                    self.listadoVacio = false
                })
            }
            datosRecibidosServidor = false
            if !isPush{
                DispatchQueue.main.async(execute: { () -> Void in
                    self.spinner.stopAnimating()
                    self.alertCargando.dismiss(animated: true, completion: { () -> Void in
            
                    })
                    self.desactivarBotonEdit()
                })
            }else{
                isPush = false
            }
            addBadgeCount()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Borrar"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showConversation"{
            let messagesVC = segue.destinationViewController as! AddConversacionController
            messagesVC.conversacionNueva = false
            messagesVC.conversationKey = listadoConversaciones[tapPosicionConversacion].conversationKey
            messagesVC.userKey = listadoConversaciones[tapPosicionConversacion].userkey
            messagesVC.userName = listadoConversaciones[tapPosicionConversacion].fname +
                " " + listadoConversaciones[tapPosicionConversacion].lname
        }
    }
    
    //MARK: - recuperarConversacionesTimer
    func recuperarConversacionesTimer(){
        recuperarConversaciones()
    }
}
