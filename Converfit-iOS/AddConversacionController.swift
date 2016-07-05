  //
//  AddConversacionController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 1/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

var vieneDeListadoMensajes = false
var hacerFoto = false

class AddConversacionController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //Variables
    var userKey:String!
    var userName:String!
    var conversacionNueva:Bool!
    var mensajeAlert = ""
    var tituloAlert = ""
    var conversationKey = ""
    var listaMensajes = [MessageModel]()
    var listaMensajesPaginada = [MessageModel]()
    var indicePaginado = 0
    var moverUltimaFila = true
    var keyboardFrame: CGRect = CGRect.null
    var keyboardIsShowing: Bool = false
    var mostrarMensajesAnteriores:Bool = false
    let llamarInfoCellId = "llamarInfoCell"
    let cargarMensajesAnterioresId = "CargarMensajesAnteriores"
    let pdfEncuenstaCellId = "pdfEncuesta"
    let mensajePdf = "Abrir Pdf"
    let mensajeEncuesta = "Realizar encuesta"
    let mensajeRealizdaEncuesta = "Encuesta realizada"
    var fechaCreacion = ""
    var desLoguear = false
    var listaMessagesKeyFallidos = [String]()
    let fname = Utils.obtenerFname()
    let lname = Utils.obtenerLname()
    let imagenDetailSegue = "imagenDetailSegue"
    let videoSegue = "videoSegue"
    let pdfSegue = "pdfSegue"
    let showUsersChat = "showUsersChat"
    var indiceSeleccionado = 0
    var codError = ""
    var myTimer = Timer.init()
    
    //MARK: - Outlets
    @IBOutlet weak var escribirMensajeOutlet: UITextField!
    @IBOutlet weak var miTabla: UITableView!
    @IBOutlet weak var vistaContenedoraTeclado: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var bottomConstratitVistaTeclado: NSLayoutConstraint!
    
    
    //MARK: - Actions
    @IBAction func takePhoto(_ sender: AnyObject) {
        self.view.endEditing(true)
        hacerFoto = true
        //Creamos el picker para la foto
        let photoPicker = UIImagePickerController()
        //Nos declaramos delegado
        photoPicker.delegate = self
        let alert = UIAlertController(title: "Elija una opción", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        //Añadimos un boton para sacar una foto con la camara
        alert.addAction(UIAlertAction(title: "Hacer foto", style: .default, handler: { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                photoPicker.sourceType = UIImagePickerControllerSourceType.camera
                //Lo mostramos
                DispatchQueue.main.async {
                    self.present(photoPicker, animated: true, completion: { () -> Void in
                        
                    })
                }
            }
        }))
        
        //Añdimos un boton para coger una foto de la galeria
        alert.addAction(UIAlertAction(title: "Album", style: .default, handler: { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
                photoPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                photoPicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.camera)!
                //Lo mostramos
                DispatchQueue.main.async {
                    self.present(photoPicker, animated: true, completion: { () -> Void in
                        
                    })
                }
            }
        }))
        
        ////Añdimos un boton para coger una foto de la galeria
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                photoPicker.sourceType = UIImagePickerControllerSourceType.camera
                photoPicker.mediaTypes = [kUTTypeMovie as String]
                photoPicker.allowsEditing = false
                //photoPicker.videoMaximumDuration = 10.0
                //Lo mostramos
                DispatchQueue.main.async {
                    self.present(photoPicker, animated: true, completion: { () -> Void in
                        
                    })
                }
            }
        }))

        
        //Añdimos un boton para cancelar las opciones
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action -> Void in
            
        }))

        //mostramos el alert
        DispatchQueue.main.async {
            self.present(alert, animated: true) { () -> Void in
                
            }
        }
    }
    
    //MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !conversacionNueva{
            myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.recuperarListadoMensajesTimer), userInfo: nil, repeats: true)
        }
        vistaContenedoraTeclado.layer.borderWidth = 0.5
        vistaContenedoraTeclado.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 0.3).cgColor
        //Nos damos de alta para responder a la notificacion enviada por push
        modificarUI()
        startObservingKeyBoard()
        
        //Nos aseguramos de activar el spinner por si volvemos de mas info
        spinner.isHidden = false
        spinner.startAnimating()
        rellenarListaMensajes()
        if !conversacionNueva && !hacerFoto{
            recuperarListadoMensajes()
        }else if hacerFoto{
            hacerFoto = false
        }
        addTap()
        NotificationCenter.default().addObserver(self, selector: #selector(self.recargarPantalla), name:notificationChat, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        listaMensajes.removeAll(keepingCapacity: false)
        listaMensajesPaginada.removeAll(keepingCapacity: false)
        mostrarMensajesAnteriores = false
        moverUltimaFila = true
        miTabla.reloadData()
        //Nos damos de baja de la notificacion
        indicePaginado = 0
        stopObservingKeyBoard()
        dissmisKeyboard()
        bottomConstratitVistaTeclado.constant = 0
        vieneDeListadoMensajes = true
        //Nos damos de baja de la notificacion
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name(rawValue: notificationChat), object: nil)
        myTimer.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if listaMensajes.isEmpty && !conversacionNueva{
            spinner.startAnimating()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Utils
    func resetearBadgeIconoApp(){
        let numeroMensajesSinLeer = Conversation.numeroMensajesSinLeer()
        if numeroMensajesSinLeer > 0{
            UIApplication.shared().applicationIconBadgeNumber = numeroMensajesSinLeer
        }else{
            UIApplication.shared().applicationIconBadgeNumber = 0
        }
    }
    
    func addTap(){
        let tapRec = UITapGestureRecognizer()
        tapRec.addTarget(self, action: #selector(self.tappedTabla))
        miTabla.addGestureRecognizer(tapRec)
    }
    
    func tappedTabla(){
        self.view.endEditing(true)
    }
    
    func rellenarListaMensajes(){
        //Recogemos los datos en segundo plano para no bloquear la interfaz
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
        DispatchQueue.main.async(execute: { () -> Void in
            self.listaMensajes = Messsage.devolverListMessages(self.conversationKey)
            
            if !self.listaMensajes.isEmpty{
                self.conversacionNueva = false
                Conversation.cambiarFlagNewMessageUserConversation(self.conversationKey,nuevo: false)
                self.resetearBadgeIconoApp()
                if self.listaMensajes.count > 20{
                    let botonMasMensajes = ["message_key": "a","converstation_key": "a", "sender": "a", "created": "a", "content": "a", "type": "botonMensajeAnterior", "enviado":"true", "fname": "a", "lname": "a"]
                    let fakeDictMasMensajeBoton = MessageModel(aDict: botonMasMensajes)
                    self.listaMensajesPaginada = Array(self.listaMensajes[(0)..<20])//Copiamos los 20 primeros elementos de la lista
                    self.listaMensajesPaginada.append(fakeDictMasMensajeBoton)
                }else{
                    self.listaMensajesPaginada = self.listaMensajes
                }
            }
            //Cuando acabamos todo lo demas volvemos al hilo principal para actualizar la UI
            DispatchQueue.main.async {
                self.miTabla.reloadData()
                self.spinner.stopAnimating()
            }
        //})
            })
    }
    
    func recargarPantalla(){//Recargamos la pantalla cuando nos llegue una notificacion
        listaMensajes.removeAll(keepingCapacity: false)
        listaMensajesPaginada.removeAll(keepingCapacity: false)
        mostrarMensajesAnteriores = false
        moverUltimaFila = true
        Conversation.cambiarFlagNewMessageUserConversation(conversationKey,nuevo: true)
        resetearBadgeIconoApp()
        DispatchQueue.main.async(execute: { () -> Void in
            self.rellenarListaMensajes()
        })
    }
    
    //Funcion que va aumentando la lista de mensajes de 20 en 20 siempre que sea posible
    func mostrarMasMensajes(){
        indicePaginado += 1
        if listaMensajes.count > (indicePaginado * 20){
            listaMensajesPaginada.removeAll(keepingCapacity: false)//Vaciamos la lista para añadir los elementos paginados
            let indiceFinal = (indicePaginado + 1) * 20
            if indiceFinal < listaMensajes.count{ //Comprobamos si se pueden mostrar los 20 siguientes mensajes enteros
                listaMensajesPaginada = Array(listaMensajes[0..<indiceFinal]) //Si el indice es menor que el tamaño entero se el ultimo elemento sera el de indiceFinal
                let botonMasMensajes = ["message_key": "a","converstation_key": "a", "sender": "a", "created": "a", "content": "a", "type": "botonMensajeAnterior" ,"enviado":"true", "fname": "a", "lname": "a"]
                let fakeDictMasMensajeBoton = MessageModel(aDict: botonMasMensajes)
                //Si el indice final es menor que el numero de elementos significa que hay mas mensajes por lo tanto mostramos el boton de mensajes Anteriores
                listaMensajesPaginada.append(fakeDictMasMensajeBoton)
            }else{
                listaMensajesPaginada = Array(listaMensajes[0..<listaMensajes.count])
            }
            miTabla.reloadData()
        }
    }
    
    //Funcion para redondear los botones y demas formatos de la UI
    func modificarUI(){
        self.title = userName
        //Ocultamos el tabBar
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //Funcion para visualizar la ultima fila de la tabla
    func establecerUltimaFilaTabla(){
        let lastSection = miTabla.numberOfSections - 1
        let lastRow = miTabla.numberOfRows(inSection: lastSection) - 1
        let ip = IndexPath(row: lastRow, section: lastSection)
        miTabla.scrollToRow(at: ip, at: UITableViewScrollPosition.bottom, animated: false)
    }
    
    func mostrarAlerta(){
        //Nos aseguramos que esta en el hilo principal o rompera
        DispatchQueue.main.async(execute: { () -> Void in
            self.view.endEditing(true)
            let alert = UIAlertController(title: self.tituloAlert, message: self.mensajeAlert, preferredStyle: UIAlertControllerStyle.alert)
            alert.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
            //Añadimos un bonton al alert y lo que queramos que haga en la clausur
            if self.desLoguear{
                self.desLoguear = false
                myTimerLeftMenu.invalidate()
                alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { (action) -> Void in
                    LogOut.desLoguearBorrarDatos()
                    self.presentingViewController!.dismiss(animated: true, completion: nil)
                }))
            }else{
                //Añadimos un bonton al alert y lo que queramos que haga en la clausur
                alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { (action) -> Void in
                    if self.codError == "list_messages_empty"{
                        _=self.navigationController?.popToRootViewController(animated: true)
                    }
                }))
            }
            //mostramos el alert
            self.present(alert, animated: true) { () -> Void in
                self.tituloAlert = ""
                self.mensajeAlert = ""
            }
        })
    }
    
    //Funcion para reenviar el mensaje cuando fallo y pulsamos el boton
    func reenviarMensaje(_ sender:UIButton){
        var upMessage = false
        var posicion = 0
        let alert = UIAlertController(title: "Elija una opción", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Reenviar mensajes fallidos", style: .default, handler: { action -> Void in
            let listaMensajesFallidos = Messsage.devolverMensajesFallidos(self.conversationKey)
            for mensajeFallido in listaMensajesFallidos{
                Messsage.cambiarEstadoEnviadoMensaje(mensajeFallido.conversationKey, messageKey: mensajeFallido.messageKey, enviado: "true")
                let fechaActualizada = Fechas.fechaActualToString()
                Messsage.actualizarFechaMensaje(self.conversationKey, messageKey: mensajeFallido.messageKey, fecha: fechaActualizada)
                self.rellenarListaMensajes()
                var content = ""
                if mensajeFallido.type == "jpeg_base64" || mensajeFallido.type == "mp4_base64"{
                    content = mensajeFallido.content.replacingOccurrences(of: "+", with: "%2B", options: [], range: nil)
                }
                else{
                    content = mensajeFallido.content
                }
                var count = 0
                for failMessage in self.listaMessagesKeyFallidos{
                    count += 1
                    if failMessage == mensajeFallido.messageKey{
                        upMessage = true
                        posicion = count
                        break
                    }
                }
                if upMessage{
                    self.updateMessage(mensajeFallido.messageKey, content: mensajeFallido.content, tipo: mensajeFallido.type)
                    self.listaMessagesKeyFallidos.remove(at: posicion
                    )
                }else{
                    let sessionKey = Utils.getSessionKey()
                    let params = "action=add_message&session_key=\(sessionKey)&conversation_key=\(self.conversationKey)&type=premessage&app_version=\(appVersion)&app=\(app)"
                    self.addMessage(params, messageKey: mensajeFallido.messageKey, contenido: content, tipo: mensajeFallido.type)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Borrar mensajes fallidos", style: .default, handler: { action -> Void in
            Messsage.borrarMensajesFallidosConversacion(self.conversationKey)
            //Recuperamos el ultimo mensaje que tenemos tras el borrado para actualizar el ultimo de la conversacion
            let ultimoMensaje = Messsage.devolverUltimoMensajeConversacion(self.conversationKey)
            Conversation.updateLastMesssageConversation(ultimoMensaje.conversationKey , ultimoMensaje: ultimoMensaje.content, fechaCreacion: ultimoMensaje.created)
            self.rellenarListaMensajes()
        }))
        
        //Añdimos un boton para cancelar las opciones
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { action -> Void in
            //No hacemos nada........Solo cancelamos el alert
        }))
        
        //mostramos el alert
        self.present(alert, animated: true) { () -> Void in
            
        }

    }
    
    //Funcion que se ejecuta cuando pulsamos sobre las imagenes de las celdas
    func tapImage(_ sender: UITapGestureRecognizer){
        indiceSeleccionado = (sender.view?.tag)!
        let listaMensajesOrdenadas = Array(listaMensajesPaginada.reversed())
        if listaMensajesOrdenadas[indiceSeleccionado].type == "jpeg_base64"{
            performSegue(withIdentifier: imagenDetailSegue, sender: self)
        }else if listaMensajesOrdenadas[indiceSeleccionado].type == "mp4_base64"{
            performSegue(withIdentifier: videoSegue, sender: self)
        }else{
            performSegue(withIdentifier: pdfSegue, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == imagenDetailSegue{
            let listaMensajesOrdenadas = Array(listaMensajesPaginada.reversed())
            let imagenMostrar = decodificarImagen(listaMensajesOrdenadas[indiceSeleccionado].content)
            let imagenDetailVC = segue.destinationViewController as! ImageDetailController
            imagenDetailVC.imagenMostrada = imagenMostrar
            
        }else if segue.identifier == videoSegue{
            let listaMensajesOrdenadas = Array(listaMensajesPaginada.reversed())
            let mostrarVideoVC = segue.destinationViewController as! VideoViewController
            mostrarVideoVC.dataVideo = Utils.decodificarVideo(listaMensajesOrdenadas[indiceSeleccionado].content)
            mostrarVideoVC.messageKey = listaMensajesOrdenadas[indiceSeleccionado].messageKey
        }else if segue.identifier == pdfSegue{
            var listaMensajesOrdenadas = Array(listaMensajesPaginada.reversed())
            let urlPdf = Utils.returnUrlWS("pdf") + listaMensajesOrdenadas[indiceSeleccionado].messageKey + ".pdf"
            let detailPdf = segue.destinationViewController as! visorPdfController
            detailPdf.urlString = urlPdf
            detailPdf.titulo = listaMensajesOrdenadas[indiceSeleccionado].content
        }
    }
    
    //Funcion que se ejecuta cuando pulsamos sobre los botones de realizar encuesta o abrir pdf
    func tapCell(_ sender: UITapGestureRecognizer){
        let row = sender.view?.tag
        if let indice = row{
            indiceSeleccionado = indice
            performSegue(withIdentifier: pdfSegue, sender: self)
        }
    }
    
    func addNuevaConversacion(_ lastMessage:String){
        if let user = User.obtenerUser(userKey){
            let imageData = UIImagePNGRepresentation((user.avatar)!)
            var avatar = ""
            if let avatarImage = imageData?.base64EncodedString([]){
                avatar = avatarImage
            }
        
            let hora = NSString(string: Conversation.devolverHoraUltimaConversacion()).doubleValue
            if NSString(string: fechaCreacion).doubleValue < hora{
                fechaCreacion = "\(hora + 3)"
            }
            let auxUserDict: Dictionary<String, AnyObject> = ["user_key":userKey, "avatar": avatar,"connection-status": user.connectionStatus]
            let userNameArray = user.userName.components(separatedBy: " ")
            let userFname:String = userNameArray[0]
            var lnameUser = ""
            /*for(var i = 1; i < userNameArray.count; i += 1){
                lnameUser += userNameArray[i] + " "
            }*/
            for i in 1..<userNameArray.count {
                lnameUser += userNameArray[i] + " "
            }
            /*var count = 0
            for failMessage in self.listaMessagesKeyFallidos{
                count += 1
                if failMessage == mensajeFallido.messageKey{
                    upMessage = true
                    posicion = count
                    break
                }
            }*/
            let conversacionDict: Dictionary<String, AnyObject> = ["conversation_key": conversationKey, "user_fname": userFname, "user_lname": lnameUser,"user": auxUserDict, "flag_new_message_user": "0", "last_message": lastMessage, "last_update": fechaCreacion]
            _=Conversation(aDict: conversacionDict, aLastUpdate: fechaCreacion, existe: false)
        }
    
    }
  
    
    //Funcion para devolver la encuesta enviada formateada
    func devolverEncuestaEnviadaFormateada(_ pregunta:String, respuesta:String, puntuacion:String) -> NSMutableAttributedString{
        let style = "<style>body { font-family: HelveticaNeue; font-size:14px } b{font-size:10px}</style>" //String para formatear la font family en todas las politicas
        var mezcla = ""
        if respuesta.isEmpty && puntuacion.isEmpty{
            let tituloEncuesta = "<b>Encuesta enviada:</b><br>"
            mezcla = style + tituloEncuesta + pregunta
        }else{
            let tituloEncuesta = "<b>Encuesta enviada:</b><br>"
            let tituloRespuesta = "<b>Respuesta recibida (\(puntuacion)/5):</b><br>"
            mezcla = style + tituloEncuesta + pregunta + "<br><br>" + tituloRespuesta + respuesta
        }
        return try! NSMutableAttributedString(
            data: mezcla.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
    }
    
    
    //MARK: - ComunicacionServidor
    func recuperarListadoMensajes(){
        let sessionKey = Utils.getSessionKey()
        let lastUpdate = Conversation.obtenerLastUpdate(conversationKey)
        let params = "action=list_messages&session_key=\(sessionKey)&conversation_key=\(conversationKey)&last_update=\(lastUpdate)&offset=\(0)&limit=\(1000)&app_version=\(appVersion)&app=\(app)"
        let serverString = Utils.returnUrlWS("conversations")
        if let url = URL(string: serverString){
            ServerUtils.getAsyncResponse(method: HTTPMethods.POST.rawValue, url: url, params: params, completionBlock: { (error, json) in
                if error != TypeOfError.NOERROR.rawValue {
                    (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(error)
                    self.mostrarAlerta()
                }else{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        DispatchQueue.main.async(execute: { () -> Void in
                            if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                                let lastUp = dataResultado["last_update"] as? String ?? ""
                                Conversation.modificarLastUpdate(self.conversationKey, aLastUpdate: lastUp)
                                let needToUpdate = dataResultado["need_to_update"] as? Bool ?? true
                                if needToUpdate{
                                    Messsage.borrarMensajesConConverstaionKey(self.conversationKey)
                                    if let messagesArray = dataResultado["messages"] as? [Dictionary<String, AnyObject>]{
                                        //Llamamos por cada elemento del array de empresas al constructor
                                        for dict in messagesArray{
                                            _ = Messsage(aDict: dict, aConversationKey: self.conversationKey)
                                        }
                                    }
                                    self.rellenarListaMensajes()
                                }
                            }
                        })
                    }else{
                        let codigoError = json["error_code"] as? String ?? ""
                        self.codError = codigoError
                        self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                        (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.mostrarAlerta()
                        })
                    }
                }
            })
        }else{
            (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(TypeOfError.DEFAUTL.rawValue)
            DispatchQueue.main.async(execute: { () -> Void in
                self.mostrarAlerta()
            })
        }
    }
    
    func crearConversacion(){
        let sessionKey = Utils.getSessionKey()
         let params = "action=open_conversation&session_key=\(sessionKey)&user_key=\(userKey)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("conversations")
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let semaphore = DispatchSemaphore(value: 0)
        let openConversationTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                            let claveConversacion = dataResultado["conversation_key"] as? String ?? "-1"
                            self.conversationKey = claveConversacion
                            self.conversacionNueva = false
                            self.myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AddConversacionController.recuperarListadoMensajesTimer), userInfo: nil, repeats: true)
                            let lastUpdate = dataResultado["conversations_last_update"] as? String ?? ""
                            Utils.saveConversationsLastUpdate(lastUpdate)
                        }
                    }else{
                        let codigoError = json["error_cod"] as? String ?? ""
                        self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                        (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.mostrarAlerta()
                        })
                    }
                }
            } catch{
                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                DispatchQueue.main.async(execute: { () -> Void in
                    self.mostrarAlerta()
                })
            }
            semaphore.signal()
        }
        openConversationTask.resume()
        _=semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    func addMessage(_ params:String, messageKey:String, contenido:String, tipo:String){
        let serverString = Utils.returnUrlWS("conversations")
        if let url = URL(string: serverString){
            ServerUtils.getAsyncResponse(method: HTTPMethods.POST.rawValue, url: url, params: params, completionBlock: { (error, json) in
                /*if error!.code == -1005{
                    self.addMessage(params, messageKey: messageKey, contenido: contenido, tipo: tipo)
                }*/
                if error != TypeOfError.NOERROR.rawValue {
                    (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(error)
                    self.mostrarAlerta()
                }else{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                            DispatchQueue.main.async(execute: { () -> Void in
                                let lastUpd = dataResultado["last_update"] as? String ?? ""
                                var hora = NSString(string: Messsage.devolverHoraUltimoMensaje(self.conversationKey)).doubleValue
                                if NSString(string: lastUpd).doubleValue < hora{
                                    hora = hora + 3
                                }
                                Messsage.actualizarFechaMensaje(self.conversationKey, messageKey: messageKey, fecha: "\(hora)")
                                let messageKeyServidor = dataResultado["message_key"] as? String ?? "-1"
                                Messsage.updateMessageKeyTemporal(self.conversationKey, messageKey: messageKey, messageKeyServidor: messageKeyServidor)
                                self.updateMessage(messageKeyServidor, content: contenido,tipo: tipo)
                            })
                        }
                    }else{
                        DispatchQueue.main.async(execute: { () -> Void in
                            Messsage.cambiarEstadoEnviadoMensaje(self.conversationKey, messageKey: messageKey, enviado: "false")
                            let anUltimoMensajeEnviado = Messsage.devolverUltimoMensajeEnviadoOk(self.conversationKey)
                            if let ultimoMensajeEnviado = anUltimoMensajeEnviado{
                                Conversation.updateLastMesssageConversation(ultimoMensajeEnviado.conversationKey, ultimoMensaje: ultimoMensajeEnviado.content, fechaCreacion: ultimoMensajeEnviado.created)
                            }
                            self.rellenarListaMensajes()
                            let codigoError = json["error_code"] as? String ?? ""
                            self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                            (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                            self.mostrarAlerta()
                            
                        })
                    }
                }
            })
        }else{
            (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(TypeOfError.DEFAUTL.rawValue)
            self.mostrarAlerta()
        }
    }
    
    func updateMessage(_ messageKey:String, content:String, tipo:String){
        let sessionKey = Utils.getSessionKey()
        let params = "action=update_message&session_key=\(sessionKey)&conversation_key=\(conversationKey)&message_key=\(messageKey)&content=\(content)&type=\(tipo)&app=\(app)"
        let serverString = Utils.returnUrlWS("conversations")
        if let url = URL(string: serverString){
            ServerUtils.getAsyncResponse(method: HTTPMethods.POST.rawValue, url: url, params: params, completionBlock: { (error, json) in
                /*if error!.code == -1005{
                    self.updateMessage(messageKey, content: content,tipo: tipo)
                }*/
                if error != TypeOfError.NOERROR.rawValue {
                    (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(error)
                    self.mostrarAlerta()
                }else{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        //LogOut ok
                    }else{
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.listaMessagesKeyFallidos.append(messageKey)
                            Messsage.cambiarEstadoEnviadoMensaje(self.conversationKey, messageKey: messageKey, enviado: "false")
                            let anUltimoMensajeEnviado = Messsage.devolverUltimoMensajeEnviadoOk(self.conversationKey)
                            if let ultimoMensajeEnviado = anUltimoMensajeEnviado{
                                Conversation.updateLastMesssageConversation(ultimoMensajeEnviado.conversationKey, ultimoMensaje: ultimoMensajeEnviado.content, fechaCreacion: ultimoMensajeEnviado.created)
                            }
                            self.rellenarListaMensajes()
                            let codigoError = json["error_code"] as? String ?? ""
                            self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                            (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                            self.mostrarAlerta()
                        })
                    }
                }
            })
        }else{
            (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(TypeOfError.DEFAUTL.rawValue)
            DispatchQueue.main.async(execute: { () -> Void in
                self.mostrarAlerta()
            })
        }
    }
    
    //MARK: - Teclado
    func dissmisKeyboard(){
        self.view.endEditing(true)
    }
    
    func startObservingKeyBoard(){
        //Funcion para darnos de alta como observador en las notificaciones de teclado
        let nc:NotificationCenter = NotificationCenter.default()
        nc.addObserver(self, selector: #selector(self.notifyThatKeyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        nc.addObserver(self, selector: #selector(self.notifyThatKeyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //Funcion para darnos de alta como observador en las notificaciones de teclado
    func stopObservingKeyBoard(){
        let nc:NotificationCenter = NotificationCenter.default()
        nc.removeObserver(self)
    }

    //Funcion que se ejecuta cuando aparece el teclado
    func notifyThatKeyboardWillAppear(_ notification:Notification){
        keyboardIsShowing = true
        
        if let info = notification.userInfo {
            self.moverUltimaFila = true
            self.mostrarMensajesAnteriores = false
            self.miTabla.reloadData()

            keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue()
            bottomConstratitVistaTeclado.constant = keyboardFrame.size.height
            UIView.animate(withDuration: 0.25, animations:  {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //Funcion que se ejecuta cuando desaparece el teclado
    func notifyThatKeyboardWillDisappear(_ notification:Notification){
        keyboardIsShowing = false
        bottomConstratitVistaTeclado.constant = 0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    //Funcion que evita que el teclado solape la vista de un determinado control
    func arrangeViewOffsetFromKeyboard()
    {
            let theApp: UIApplication = UIApplication.shared()
            let windowView: UIView? = theApp.delegate!.window!
            
            let textFieldLowerPoint: CGPoint = CGPoint(x: vistaContenedoraTeclado.frame.origin.x, y: vistaContenedoraTeclado!.frame.origin.y + vistaContenedoraTeclado!.frame.size.height)
        
            let convertedTextFieldLowerPoint: CGPoint = self.view.convert(textFieldLowerPoint, to: windowView)
            
            let targetTextFieldLowerPoint: CGPoint = CGPoint(x: vistaContenedoraTeclado!.frame.origin.x, y: keyboardFrame.origin.y)
            
            let targetPointOffset: CGFloat = targetTextFieldLowerPoint.y - convertedTextFieldLowerPoint.y
            let adjustedViewFrameCenter: CGPoint = CGPoint(x: self.view.center.x, y: self.view.center.y + targetPointOffset)
            UIView.animate(withDuration: 0.25, animations:  {
                self.view.center = adjustedViewFrameCenter
            })
    }

    //Funcion que devuelve al estado origian la vista
    func returnViewToInitialFrame()
    {
        let initialViewRect: CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        if !initialViewRect.equalTo(self.view.frame)
        {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.frame = initialViewRect
            });
        }
    }
    
    //Funcion para decodificar una imagen a partir de un String
    func decodificarImagen (_ dataImage:String) -> UIImage{
        if let decodedData = Data(base64Encoded: dataImage, options: .encodingEndLineWithCarriageReturn){
            if decodedData.count > 0{
                return UIImage(data: decodedData)!
            }
            else{
                return UIImage(named: "NoImage")!
            }
        }
        else{
            return UIImage(named: "NoImage")!
        }
    }
    
    //MARK: - Table
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaMensajesPaginada.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listaMensajesOrdenadas = Array(listaMensajesPaginada.reversed())
        if listaMensajesOrdenadas[indexPath.row].sender != "brand"{
            if listaMensajesOrdenadas[indexPath.row].type == "jpeg_base64"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "FotoBrand") as! CeldaImagenMensajes
                cell.imagen.image = listaMensajesOrdenadas[indexPath.row].miniImagen
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row].created)
                
                ////////////////////Añadimos el tap a la imagen////////////////////
                cell.imagen.isUserInteractionEnabled = true
                cell.imagen.tag = indexPath.row
                let tapRec = UITapGestureRecognizer()
                tapRec.addTarget(self, action: #selector(self.tapImage(_:)))
                cell.imagen.addGestureRecognizer(tapRec)
                //////////////////////////////////////////////////////////////////
                
                //Ocultamos el boton play
                cell.playImage.isHidden = true
                
                return cell
            }else if listaMensajesOrdenadas[indexPath.row].type == "mp4_base64"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "FotoBrand") as! CeldaImagenMensajes
                cell.imagen.image = listaMensajesOrdenadas[indexPath.row].miniImagen
                cell.imagen.contentMode = UIViewContentMode.redraw
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row].created)
                
                ////////////////////Añadimos el tap a la imagen////////////////////
                cell.playImage.isUserInteractionEnabled = true
                cell.playImage.tag = indexPath.row
                cell.imagen.isUserInteractionEnabled = true
                cell.imagen.tag = indexPath.row
                let tapRec = UITapGestureRecognizer()
                tapRec.addTarget(self, action: #selector(self.tapImage(_:)))
                cell.imagen.addGestureRecognizer(tapRec)
                cell.playImage.addGestureRecognizer(tapRec)
                //////////////////////////////////////////////////////////////////
                
                return cell
            }else if listaMensajesOrdenadas[indexPath.row].type == "poll_response"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MensajeBrand") as! CeldaTextoMensaje
                let preguntaRespuesta = listaMensajesOrdenadas[indexPath.row].content
                let contenidoArray = preguntaRespuesta.components(separatedBy: "::")
                let preguntaEncuesta = contenidoArray[0]
                let puntuacionEncuesta = contenidoArray[1]
                let respuestaEncuesta = contenidoArray[2]
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row].created)
                cell.mensaje.attributedText = devolverEncuestaEnviadaFormateada(preguntaEncuesta,respuesta: respuestaEncuesta, puntuacion: puntuacionEncuesta)
                return cell
            }else if listaMensajesOrdenadas[indexPath.row].type == "botonMensajeAnterior"{
                let cell = tableView.dequeueReusableCell(withIdentifier: cargarMensajesAnterioresId) as! CeldaCargarMensajesAnteriores
                //Añadimos una accion a cada boton(llamar/Info)
                cell.btnCargarMensajesAnteriores.addTarget(self, action: #selector(self.mostrarMasMensajes), for: UIControlEvents.touchUpInside)
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MensajeBrand") as! CeldaTextoMensaje
                let mensajeString = NSMutableAttributedString(string: listaMensajesOrdenadas[indexPath.row].content)
                mensajeString.addAttribute(NSFontAttributeName, value: UIFont(name: "Helvetica Neue", size: 14.0)!, range: NSMakeRange(0, mensajeString.length))
                cell.mensaje.attributedText = mensajeString
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row ].created)
                cell.botonReenviarMensaje.isHidden = true
                return cell
            }
        }else{
            if listaMensajesOrdenadas[indexPath.row].type == "jpeg_base64"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "FotoUsuario") as! CeldaImagenMensajes
                cell.imagen.image = listaMensajesOrdenadas[indexPath.row].miniImagen
                cell.imagen.contentMode = UIViewContentMode.redraw
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row].created)
                cell.senderBrandName.text = listaMensajesOrdenadas[indexPath.row].fname + " " + listaMensajesOrdenadas[indexPath.row].lname
                if listaMensajesOrdenadas[indexPath.row].enviado == "true"{
                    cell.traillingContraitNombre.constant = 10
                    cell.traillingConstraitImagen.constant = 8
                    cell.traillingConstraitHora.constant = 10
                    cell.botonReenviarMensaje.isHidden = true
                }else{
                    cell.traillingConstraitImagen.constant = 36
                    cell.traillingConstraitHora.constant = 38
                    cell.traillingContraitNombre.constant = 38
                    cell.botonReenviarMensaje.isHidden = false
                }
                cell.botonReenviarMensaje.tag = indexPath.row
                cell.botonReenviarMensaje.addTarget(self, action: #selector(self.reenviarMensaje(_:)), for: UIControlEvents.touchUpInside)

               
                ////////////////////Añadimos el tap a la imagen////////////////////
                cell.imagen.isUserInteractionEnabled = true
                cell.imagen.tag = indexPath.row
                let tapRec = UITapGestureRecognizer()
                tapRec.addTarget(self, action: #selector(self.tapImage(_:)))
                cell.imagen.addGestureRecognizer(tapRec)
                //////////////////////////////////////////////////////////////////
                
                cell.playImage.isHidden = true
                
                return cell
            }else if listaMensajesOrdenadas[indexPath.row].type == "document_pdf"{
                let cell = tableView.dequeueReusableCell(withIdentifier: pdfEncuenstaCellId) as! CeldaPdfEncuesta
                cell.imagen.image = UIImage(named: "pdf")
                cell.mensaje.text = listaMensajesOrdenadas[indexPath.row].content
                cell.accion.text = mensajePdf
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row].created)
                cell.senderBrandName.text = listaMensajesOrdenadas[indexPath.row].fname + " " + listaMensajesOrdenadas[indexPath.row].lname
                ////////////////////Añadimos el tap a la celda////////////////////
                cell.tag = indexPath.row
                let tapRec = UITapGestureRecognizer()
                tapRec.addTarget(self, action: #selector(self.tapCell(_:)))
                cell.addGestureRecognizer(tapRec)
                //////////////////////////////////////////////////////////////////
                
                return cell
            }else if listaMensajesOrdenadas[indexPath.row].type == "poll" || listaMensajesOrdenadas[indexPath.row].type == "poll_closed"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MensajeUsuario") as! CeldaTextoMensaje
                cell.senderBrandName.text = listaMensajesOrdenadas[indexPath.row].fname + " " + listaMensajesOrdenadas[indexPath.row].lname
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row].created)
                cell.mensaje.attributedText = devolverEncuestaEnviadaFormateada(listaMensajesOrdenadas[indexPath.row].content,respuesta: "", puntuacion: "")
                //Como vendra desde el manager ocultamos los botones para reenviar
                cell.traillingContraitNombre.constant = 16
                cell.traillingConstrait.constant = 8
                cell.botonReenviarMensaje.isHidden = true
                ////////////////////////////////////
                return cell
            }else if listaMensajesOrdenadas[indexPath.row].type == "premessage"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "FotoUsuario") as! CeldaImagenMensajes
                cell.imagen.image = listaMensajesOrdenadas[indexPath.row ].miniImagen
                cell.imagen.contentMode = UIViewContentMode.redraw
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row ].created)
              
                cell.traillingConstraitImagen.constant = 8
                cell.traillingConstraitHora.constant = 10
                cell.botonReenviarMensaje.isHidden = true
                
                let activityIndicator = Utils.crearActivityLoading(160, heigth: 160)
                activityIndicator.startAnimating()
                cell.imagen.addSubview(activityIndicator)
                return cell
                
            }else if listaMensajesOrdenadas[indexPath.row].type == "mp4_base64"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "FotoUsuario") as! CeldaImagenMensajes
                cell.imagen.image = listaMensajesOrdenadas[indexPath.row].miniImagen
                cell.imagen.contentMode = UIViewContentMode.redraw
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row].created)
                cell.senderBrandName.text = listaMensajesOrdenadas[indexPath.row].fname + " " + listaMensajesOrdenadas[indexPath.row].lname
                if listaMensajesOrdenadas[indexPath.row].enviado == "true"{
                    cell.traillingContraitNombre.constant = 10
                    cell.traillingConstraitImagen.constant = 8
                    cell.traillingConstraitHora.constant = 10
                    cell.botonReenviarMensaje.isHidden = true
                }else{
                    cell.traillingConstraitImagen.constant = 36
                    cell.traillingConstraitHora.constant = 38
                    cell.traillingContraitNombre.constant = 38
                    cell.botonReenviarMensaje.isHidden = false
                }
                cell.botonReenviarMensaje.tag = indexPath.row
                cell.botonReenviarMensaje.addTarget(self, action: #selector(self.reenviarMensaje(_:)), for: UIControlEvents.touchUpInside)
                
                
                ////////////////////Añadimos el tap a la imagen////////////////////
                cell.playImage.isUserInteractionEnabled = true
                cell.playImage.tag = indexPath.row
                cell.imagen.isUserInteractionEnabled = true
                cell.imagen.tag = indexPath.row
                let tapRec = UITapGestureRecognizer()
                tapRec.addTarget(self, action: #selector(self.tapImage(_:)))
                cell.imagen.addGestureRecognizer(tapRec)
                cell.playImage.addGestureRecognizer(tapRec)
                //////////////////////////////////////////////////////////////////
                
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MensajeUsuario") as! CeldaTextoMensaje
                let mensajeString = NSMutableAttributedString(string: listaMensajesOrdenadas[indexPath.row].content)
                mensajeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black(), range: NSMakeRange(0, mensajeString.length))
                mensajeString.addAttribute(NSFontAttributeName, value: UIFont(name: "Helvetica Neue", size: 14.0)!, range: NSMakeRange(0, mensajeString.length))
                
                cell.mensaje.attributedText = mensajeString
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row ].created)
                cell.senderBrandName.text = listaMensajesOrdenadas[indexPath.row].fname + " " + listaMensajesOrdenadas[indexPath.row].lname
                if listaMensajesOrdenadas[indexPath.row].enviado == "true"{
                    cell.traillingContraitNombre.constant = 16
                    cell.traillingConstrait.constant = 8
                    cell.botonReenviarMensaje.isHidden = true
                }else{
                    cell.traillingContraitNombre.constant = 44
                    cell.traillingConstrait.constant = 36
                    cell.botonReenviarMensaje.isHidden = false
                }
                cell.botonReenviarMensaje.tag = indexPath.row
                cell.botonReenviarMensaje.addTarget(self, action: #selector(self.reenviarMensaje(_:)), for: UIControlEvents.touchUpInside)
                return cell
            }
        }
    }

    //Funcion para discernir cuando es una imagen y establecer un tamaño fijo o cuando no y ponerlo dinámico
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Usamos este metodo para ver si el indexPath es igual a la ultima celda
        if indexPath == tableView.indexPathsForVisibleRows?.last{
            if moverUltimaFila || !mostrarMensajesAnteriores{
                establecerUltimaFilaTabla()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        moverUltimaFila = false
        mostrarMensajesAnteriores = true
    }
    
    //MARK: - recuperarListadoMensajesTimer
    func recuperarListadoMensajesTimer(){
        recuperarListadoMensajes()
    }
}

//MARK: - UITextFieldDelegate
extension AddConversacionController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guardarMensajeYenviar()
        return true
    }
    
    func guardarMensajeYenviar(){
        let tipo = "text"
        //guardamos el valor del mensaje que hemos introducido y lo ponemos a blanco
        var textoMensaje = escribirMensajeOutlet.text!
        escribirMensajeOutlet.text = ""
        //Si el tamaño del texto es mayor que 0 quiere decir que hemos introducido algo
        if Utils.quitarEspacios(textoMensaje).characters.count > 0{
            fechaCreacion = Fechas.fechaActualToString()
            //si venimos de la pantalla de ListBrand, Favoritos o Busqueda es una conversacion nueva con lo cual tenemos que  crear la conversacion
            if conversacionNueva == true{
                crearConversacion()
                addNuevaConversacion(textoMensaje)
            }else{
                let hora = NSString(string: Messsage.devolverHoraUltimoMensaje(self.conversationKey)).doubleValue
                if NSString(string: fechaCreacion).doubleValue < hora{
                    fechaCreacion = "\(hora + 3)"
                }
            }
            let messageKey = Messsage.obtenerMessageKeyTemporal()
            //Añadimos un mensaje nuevo al modelo
            let mensajeTextoDict = ["message_key": messageKey, "converstation_key": conversationKey, "sender": "brand", "created": fechaCreacion, "content": textoMensaje, "type": tipo, "enviado": "true", "fname": fname, "lname": lname]
            let mensaje = MessageModel(aDict: mensajeTextoDict)
            _ = Messsage(model: mensaje)
            listaMensajes.removeAll(keepingCapacity: false)
            listaMensajes = Messsage.devolverListMessages(conversationKey)
            if listaMensajes.count > 20{
                let botonMasMensajes = ["message_key": "a", "converstation_key": "a", "sender": "a", "created": "a", "content": "a", "type": "botonMensajeAnterior","enviado":"true", "fname": "a", "lname": "a"]
                let fakeDictMasMensajeBoton = MessageModel(aDict: botonMasMensajes)
                listaMensajesPaginada = Array(listaMensajes[(0)..<20])
                listaMensajesPaginada.append(fakeDictMasMensajeBoton)
                indicePaginado = 0
            }else{
                listaMensajesPaginada = listaMensajes
            }
            moverUltimaFila = true
            miTabla.reloadData()
            Conversation.updateLastMesssageConversation(conversationKey, ultimoMensaje: textoMensaje, fechaCreacion: fechaCreacion)
            textoMensaje = Utils.removerEspaciosBlanco(textoMensaje)//Cambiamos los espacios en blanco por +
            let sessionKey = Utils.getSessionKey()
            let params = "action=add_message&session_key=\(sessionKey)&conversation_key=\(conversationKey)&type=premessage&app_version=\(appVersion)&app=\(app)"
            addMessage(params, messageKey: messageKey, contenido: textoMensaje, tipo: tipo)
        }
    }
    
}

//MARK: - 
extension AddConversacionController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //Funcion para formatear la foto a enviar
    func formatearFoto(_ imagenOriginal:UIImage){
        var reducir : Bool
        var tamaño:CGSize?
        var imagenReescalada: UIImage?
        
        listaMensajes.removeAll(keepingCapacity: false)
    
        (reducir , tamaño) = ResizeImage().devolverTamaño(imagenOriginal)
        if !reducir{
            imagenReescalada = ResizeImage().RedimensionarImagen(imagenOriginal)
        }else{
            imagenReescalada = ResizeImage().RedimensionarImagenContamaño(imagenOriginal, targetSize: tamaño!)
        }
        
        fechaCreacion = Fechas.fechaActualToString()
        
        if conversacionNueva == true{
            crearConversacion()
            addNuevaConversacion("[::image]")
        }else{
            let hora = NSString(string: Messsage.devolverHoraUltimoMensaje(self.conversationKey)).doubleValue
            if NSString(string: fechaCreacion).doubleValue < hora{
                fechaCreacion = "\(hora + 3)"
            }
        }
        let tipo = "jpeg_base64"
        let contenido = codificarImagen(imagenReescalada!)
        enviarFotoVideo(tipo, contenido: contenido, ultimoMensaje: "📷")
    }
    
    //Funcion para formatear el video a enviar
    func formatearVideo(_ dataVideo:Data, urlString:String){
        
        fechaCreacion = Fechas.fechaActualToString()
        
        if conversacionNueva == true{
            crearConversacion()
            addNuevaConversacion("[::video]")
        }else{
            let hora = NSString(string: Messsage.devolverHoraUltimoMensaje(self.conversationKey)).doubleValue
            if NSString(string: fechaCreacion).doubleValue < hora{
                fechaCreacion = "\(hora + 3)"
            }
        }
        let tipo = "mp4_base64"
        let contenido = codificarVideo(dataVideo)
        enviarFotoVideo(tipo, contenido: contenido, ultimoMensaje: "📹")
    }
    
    //Funcion para enviar tanto si es foto como video
    func enviarFotoVideo(_ tipo:String, contenido:String, ultimoMensaje:String){
        let messageKey = Messsage.obtenerMessageKeyTemporal()
        
        let mensajeTextoDict = ["message_key": messageKey, "converstation_key": conversationKey, "sender": "brand", "created": fechaCreacion, "content": contenido, "type": tipo, "enviado":"true", "fname": fname, "lname": lname]
        let mensaje = MessageModel(aDict: mensajeTextoDict)
        _ = Messsage(model: mensaje)
        listaMensajes.removeAll(keepingCapacity: false)
        listaMensajes = Messsage.devolverListMessages(conversationKey)
        if listaMensajes.count > 20{
            let botonMasMensajes = ["message_key": "a", "converstation_key": "a", "sender": "a", "created": "a", "content": "a", "type": "botonMensajeAnterior", "enviado":"true", "fname": "a", "lname": "a"]
            let fakeDictMasMensajeBoton = MessageModel(aDict: botonMasMensajes)
            listaMensajesPaginada = Array(listaMensajes[(0)..<20])
            listaMensajesPaginada.append(fakeDictMasMensajeBoton)
            indicePaginado = 0
        }else{
            listaMensajesPaginada = listaMensajes
        }
        
        miTabla.reloadData()
        Conversation.updateLastMesssageConversation(conversationKey, ultimoMensaje: ultimoMensaje, fechaCreacion: fechaCreacion)
        let content = contenido.replacingOccurrences(of: "+", with: "%2B", options: [], range: nil)
        let sessionKey = Utils.getSessionKey()
        let params = "action=add_message&session_key=\(sessionKey)&conversation_key=\(conversationKey)&type=premessage&app_version=\(appVersion)&app=\(app)"
        addMessage(params, messageKey: messageKey, contenido: content, tipo: tipo)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white()]
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
        //Comprobamos si es una imagen o un video
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //Es una imagen
            formatearFoto(pickedImage)
        }else{//Es un video
            if let urlVideo = info[UIImagePickerControllerMediaURL] as? URL{
                convertToMp4(urlVideo)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
    // Funcion que codifica la imagen
    func codificarImagen(_ dataImage:UIImage) -> String{
        let imageData = UIImagePNGRepresentation(dataImage)
        return imageData!.base64EncodedString([])
    }
    
    //Funcion que codifica el video
    func codificarVideo(_ dataVideo:Data) -> String{
        return dataVideo.base64EncodedString([])
    }
    
    //Funcion para convertir de .mov a .mp4
    func convertToMp4(_ urlMov:URL){
        let doubleNSString = NSString(string: Fechas.fechaActualToString())
        let timestampAsDouble = Int(doubleNSString.doubleValue * 1000)
        let idVideo = "\(timestampAsDouble)"
        let video = AVURLAsset(url: urlMov, options: nil)
        let exportSession = AVAssetExportSession(asset: video, presetName: AVAssetExportPresetMediumQuality)
        let myDocumentPath = applicationDocumentsDirectory().appendingPathComponent(idVideo + ".mp4")
        let url = URL(fileURLWithPath: myDocumentPath)
        exportSession!.outputURL = url
        exportSession!.outputFileType = AVFileTypeMPEG4;
        exportSession!.shouldOptimizeForNetworkUse = true;
        
        exportSession!.exportAsynchronously (completionHandler: {
            if exportSession!.status == AVAssetExportSessionStatus.completed{
                if let videoData = try? Data(contentsOf: url){
                    self.formatearVideo(videoData, urlString: "\(url)")
                }
            }else{
                //Fallo la exportacion y no hacemos nada
            }
        })
    }
    
    func applicationDocumentsDirectory() -> NSString {//En esta funcion obtenemos la ruta temporal donde guardar nuestro archivo
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    }

}
