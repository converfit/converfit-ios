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
            //recuperarUserServidor()
            
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
    /*
    func recuperarUserServidor(){
        var downloadQueue:NSOperationQueue = {
            var queue = NSOperationQueue()
            queue.name = "Download queue"
            queue.maxConcurrentOperationCount = 1
            return queue
            }()
        let favoritosLastUpdate = Utils.getLastUpdateFollower()
        
        let urlServidor = Utils.devolverURLservidor("brands")
        let params = "action=list_brand_users&session_key=\(sessionKey)&users_last_update=\(favoritosLastUpdate)&offset=\(0)&limit=\(1000)&app_version=\(appVersion)&app=\(app)"
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        request.HTTPMethod = "POST"
        
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(request, queue: downloadQueue) { (response, data, error) -> Void in
            if(data.length > 0){
                var JSONObjetcs:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                if let codigoResultado = JSONObjetcs.objectForKey("result") as? Int{
                    if(codigoResultado == 1){
                        dbErrorContador = 0
                        if let dataResultado = JSONObjetcs.objectForKey("data") as? NSDictionary{
                            //Guardamos el last update de favoritos
                            if let lastUpdate = dataResultado.objectForKey("brand_users_last_update") as? String{
                                Utils.guardarLastUpdateFavorito(lastUpdate)
                            }
                            //Obtenemos el need_to_update para ver si hay que actualizar la lista o no
                            if let needUpdate = dataResultado.objectForKey("need_to_update") as? Bool{
                                if(needUpdate){
                                    if let listaUsuarios = dataResultado.objectForKey("users") as? NSArray{
                                       User.borrarAllUsers()
                                        //Llamamos por cada elemento del array de empresas al constructor
                                        for dict in listaUsuarios{
                                            User(aDict: dict as! NSDictionary)
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
                        if let codigoError = JSONObjetcs.objectForKey("error_code") as? String{
                            self.datosRecibidosServidor = true
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
                                    if(codigoError != "list_users_empty"){
                                        self.desLoguear = Utils.comprobarDesloguear(codigoError)
                                        (self.tituloAlert,self.mensajeAlert) = Utils().establecerTituloMensajeAlert(codigoError)
                                        self.mostrarAlerta()
                                    }else{
                                        self.mostrarAlert = false
                                    }
                                })
                            })
                            
                        }
                    }
                }
            }else{
                self.spinner.stopAnimating()
                self.alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
                    (self.tituloAlert,self.mensajeAlert) = Utils().establecerTituloMensajeAlert("error")
                    self.mostrarAlerta()
                })
            }
        }
    }
    */
        
    //MARK: - Table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listadoUsers.count// Create 1 row as an example
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! CeldaListadoFavoritos
        /*
        cell.imagenAvatar.image = listadoUsers[indexPath.row].avatar
        cell.name.text = listadoUsers[indexPath.row].fname + " " + listadoUsers[indexPath.row].lname
        if(listadoUsers[indexPath.row].user_blocked){
            //cell.userInteractionEnabled = false            
            cell.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
        }else{
            //cell.userInteractionEnabled = true
            cell.backgroundColor = UIColor.whiteColor()
        }
*/
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*
        if(!isSubBrand){
            
            //Limpiamos el texto que haya en el seachBar
            self.view.endEditing(true)
            miSearchBar.text = "";
            miSearchBar.showsCancelButton = false
            miSearchBar.resignFirstResponder()
            
            var mensajeUserBloqued = ""
            var titleUserBloqued = ""
            var bloquearDesbloquear:UIAlertAction
            if(listadoUsers[indexPath.row].user_blocked){
                titleUserBloqued = "Usuario bloqueado"
                mensajeUserBloqued = "El usuario al que intenta acceder se encuentra bloqueado. No podrá contestar sus mensajes a menos que lo desbloquee."
                
                //Boton para desbloquear un usuario
                bloquearDesbloquear =  UIAlertAction(title: "Desbloquear usuario", style: .Default, handler: { (action) -> Void in
                    self.blockUser(self.listadoUsers[indexPath.row].userKey, bloqueado: false)
                    User.updateUserBlocked(self.listadoUsers[indexPath.row].userKey, blocked: false)
                    self.listadoUsers = User.devolverListaUsers()
                    self.miTablaPersonalizada.reloadData()
                })
            }else{
                titleUserBloqued = "Elija una opción"
                
                //Boton para bloquear un usuario
                bloquearDesbloquear =  UIAlertAction(title: "Bloquear usuario", style: .Default, handler: { (action) -> Void in
                    self.blockUser(self.listadoUsers[indexPath.row].userKey, bloqueado: true)
                    User.updateUserBlocked(self.listadoUsers[indexPath.row].userKey, blocked: true)
                    self.listadoUsers = User.devolverListaUsers()
                    self.miTablaPersonalizada.reloadData()
                })
            }
            
            //Boton para iniciar una nueva conversacion
            let iniciarConversacionUsuario = UIAlertAction(title: "Iniciar conversación", style: .Default, handler: { (action) -> Void in
                self.iniciarConversacion(indexPath.row)
            })
            
            //Boton para cancelar
            let cancel = UIAlertAction(title: "Cancelar", style: .Cancel, handler: { (action) -> Void in
                self.listadoUsers = User.devolverListaUsers()
                self.miTablaPersonalizada.reloadData()
            })

            
            //Creamos el alertSheet
            let alertUserBlocked = UIAlertController(title: titleUserBloqued, message: mensajeUserBloqued, preferredStyle: .ActionSheet)
            //Añadimos las acciones
            alertUserBlocked.addAction(iniciarConversacionUsuario)
            alertUserBlocked.addAction(bloquearDesbloquear)
            alertUserBlocked.addAction(cancel)
            
            self.presentViewController(alertUserBlocked, animated: true, completion: { () -> Void in
                
            })
        }
*/
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
    
    //Funcion para iniciar una conversación nueva
    func iniciarConversacion(indice:Int){
        /*let addConversacionVC = self.storyboard?.instantiateViewControllerWithIdentifier("AddConversation") as! AddConversacionController
        //Rellenamos los valores que queramos pasar al otro VC
        addConversacionVC.sessionKey = sessionKey
        addConversacionVC.userKey = listadoUsers[indice].userKey
        addConversacionVC.conversacionNueva = true
        addConversacionVC.userName = listadoUsers[indice].fname + " " + listadoUsers[indice].lname
        resetContexto()
        self.navigationController?.pushViewController(addConversacionVC, animated: true)
        */
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

