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
    var alertCargando = UIAlertController(title: "", message: "Cargando...", preferredStyle: .alert)
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var tamañoLista = 0
    var desLoguear = false
    var mostrarAlert = true
    var isSubBrand = false
    let segueShowMessageUserChat = "showMessageUserChat"
    var indexSeleccionado:IndexPath?
    var numeroUsuarioConectados = 0
    var numeroUsuariosAPP = 0
    var myTimer = Timer.init()
    
    //MARK: - Outlets
    @IBOutlet weak var miTablaPersonalizada: UITableView!
    @IBOutlet weak var miSearchBar: UISearchBar!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.recuperarUserServidorTimer), userInfo: nil, repeats: true)
        self.editButtonItem().title = "Editar"
        if vieneDeListadoMensajes{
            self.tabBarController?.selectedIndex = 2
            vieneDeListadoMensajes = false
            
        }//else{
            listadoUsersConectados = User.devolverUsuariosConectados()
            listadoUsersAPP = User.devolverUsuariosAPP()
            numeroUsuarioConectados = User.devolverNumeroUsuariosConectados()
            numeroUsuariosAPP = User.devolverNumeroUsuariosAPP()
            if !listadoUsersConectados.isEmpty || !listadoUsersAPP.isEmpty{
                datosRecibidosServidor = true
            }
            //recuperarUserServidor()
            
            modificarUI()
            //Tenemos que forzar la recarga para que cuando cambiemos con el tabBar se recargue correctamente
            miTablaPersonalizada.reloadData()
        //}
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        miSearchBar.showsCancelButton = false
        resetContexto()
        miTablaPersonalizada.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        myTimer.invalidate()
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
        miTablaPersonalizada.tableFooterView = UIView()
        miTablaPersonalizada.backgroundColor = UIColor.clear()
    }
    
    func mostrarAlerta(){
        self.view.endEditing(true)
        let alert = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausur
        if desLoguear{
            desLoguear = false
            myTimerLeftMenu.invalidate()
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { (action) -> Void in
                LogOut.desLoguearBorrarDatos()
                //self.navigationController?.popToRootViewControllerAnimated(false)
                self.presentingViewController!.dismiss(animated: true, completion: nil)
            }))
        }else{
            //Añadimos un bonton al alert y lo que queramos que haga en la clausur
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler:nil))
        }
        //mostramos el alert
        self.navigationController?.present(alert, animated: true) { () -> Void in
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
                                    self.datosRecibidosServidor = true
                                    //self.listadoUsers = User.devolverListaUsers()
                                    self.listadoUsersConectados = User.devolverUsuariosConectados()
                                    self.numeroUsuarioConectados = User.devolverNumeroUsuariosConectados()
                                    self.numeroUsuariosAPP = User.devolverNumeroUsuariosAPP()
                                    self.listadoUsersAPP = User.devolverUsuariosAPP()
                                    self.miTablaPersonalizada.reloadData()
                                })
                            }
                        }
                    }else{
                        let codigoError = json["error_code"] as? String ?? ""
                        self.datosRecibidosServidor = true
                        DispatchQueue.main.async(execute: { () -> Void in
                            if codigoError != "list_users_empty"{
                                self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                self.mostrarAlerta()
                            }else{
                                self.mostrarAlert = false
                            }
                        })
                    }
                }
            } catch{
                self.spinner.stopAnimating()
                /*self.alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })*/
                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                DispatchQueue.main.async(execute: { () -> Void in
                    self.mostrarAlerta()
                })
            }
        }
        recuperarUsersTask.resume()
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
        headerView.textLabel?.textColor = UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1)
        headerView.textLabel?.font = UIFont.systemFont(ofSize: 16)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! CeldaListadoFavoritos
        var user:UserModel
        if indexPath.section == 0{
            user = listadoUsersConectados[indexPath.row]
        }else{
            user = listadoUsersAPP[indexPath.row]
        }
        cell.imagenAvatar.image = user.avatar
        cell.name.text = user.userName
        cell.lastPage.text = user.lastPageTitle
        cell.hora.text = Fechas.devolverTiempo(user.horaConectado)
        let conectionStatus = user.connectionStatus
        if conectionStatus == "online"{
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Online")
        }else if conectionStatus == "offline"{
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Offline")
        }else if conectionStatus == "inactive"{
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Inactive")
        }else{
            cell.imagenConnectionStatus.image = UIImage(named: "ConnectionStatus_Mobile")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Limpiamos el texto que haya en el seachBar
        self.view.endEditing(true)
        miSearchBar.text = "";
        miSearchBar.showsCancelButton = false
        miSearchBar.resignFirstResponder()
        
        indexSeleccionado = indexPath
        
        performSegue(withIdentifier: segueShowMessageUserChat, sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Usamos este metodo para ver si el indexPath es igual a la ultima celda
        if indexPath == tableView.indexPathsForVisibleRows?.last && datosRecibidosServidor{
            datosRecibidosServidor = false
            spinner.stopAnimating()
            /*alertCargando.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })*/
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueShowMessageUserChat{
            let indice = indexSeleccionado?.row
            var user:UserModel
            if indexSeleccionado!.section == 0{
                user = listadoUsersConectados[indice!]
            }else{
                user = listadoUsersAPP[indice!]
            }
            let (userHasConversation, conversationKey) = Conversation.existeConversacionDeUsuario(user.userKey)
             let messagesVC = segue.destinationViewController as! AddConversacionController
            if userHasConversation{
                messagesVC.conversacionNueva = false
                messagesVC.conversationKey = conversationKey

            }else{
                messagesVC.conversacionNueva = true
            }
            messagesVC.userKey = user.userKey
            messagesVC.userName = user.userName
        }
    }
    
    //MARK: - recuperarUserServidorTimer
    func recuperarUserServidorTimer(){
        recuperarUserServidor()
    }
}

//Extension para la gestion del SearcBar
extension UsersChatControllerViewController: UISearchBarDelegate{
    //Funcion que se ejecuta cada vez que se cambia el texto de busqueda
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var textoBuscado = searchBar.text!
        if !Utils.quitarEspacios(textoBuscado).isEmpty{
            //listadoUsersConectados.removeAll(keepCapacity: false)
            //listadoUsersAPP.removeAll(keepCapacity: false)
            //Eliminamos los espacios al final del texto
            textoBuscado = textoBuscado.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    //Funcion que se ejecuta cuando pulsamos en cancelar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        self.view.endEditing(true)
        if !searchBar.text!.isEmpty{
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

