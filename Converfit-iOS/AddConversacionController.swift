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
    var myTimer = NSTimer.init()
    
    //MARK: - Outlets
    @IBOutlet weak var escribirMensajeOutlet: UITextField!
    @IBOutlet weak var miTabla: UITableView!
    @IBOutlet weak var vistaContenedoraTeclado: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var bottomConstratitVistaTeclado: NSLayoutConstraint!
    
    
    //MARK: - Actions
    @IBAction func takePhoto(sender: AnyObject) {
        self.view.endEditing(true)
        hacerFoto = true
        //Creamos el picker para la foto
        let photoPicker = UIImagePickerController()
        //Nos declaramos delegado
        photoPicker.delegate = self
        let alert = UIAlertController(title: "Elija una opción", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        //Añadimos un boton para sacar una foto con la camara
        alert.addAction(UIAlertAction(title: "Hacer foto", style: .Default, handler: { action -> Void in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
                photoPicker.sourceType = UIImagePickerControllerSourceType.Camera
                //Lo mostramos
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(photoPicker, animated: true, completion: { () -> Void in
                        
                    })
                }
            }
        }))
        
        //Añdimos un boton para coger una foto de la galeria
        alert.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action -> Void in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)){
                photoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                photoPicker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera)!
                //Lo mostramos
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(photoPicker, animated: true, completion: { () -> Void in
                        
                    })
                }
            }
        }))
        
        ////Añdimos un boton para coger una foto de la galeria
        alert.addAction(UIAlertAction(title: "Video", style: .Default, handler: { action -> Void in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
                photoPicker.sourceType = UIImagePickerControllerSourceType.Camera
                photoPicker.mediaTypes = [kUTTypeMovie as String]
                photoPicker.allowsEditing = false
                //photoPicker.videoMaximumDuration = 10.0
                //Lo mostramos
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(photoPicker, animated: true, completion: { () -> Void in
                        
                    })
                }
            }
        }))

        
        //Añdimos un boton para cancelar las opciones
        alert.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: { action -> Void in
            
        }))

        //mostramos el alert
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true) { () -> Void in
                
            }
        }
    }
    
    //MARK: - LifeCycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(!conversacionNueva){
            myTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "recuperarListadoMensajesTimer", userInfo: nil, repeats: true)
        }
        vistaContenedoraTeclado.layer.borderWidth = 0.5
        vistaContenedoraTeclado.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 0.3).CGColor
        //Nos damos de alta para responder a la notificacion enviada por push
        modificarUI()
        startObservingKeyBoard()
        
        //Nos aseguramos de activar el spinner por si volvemos de mas info
        spinner.hidden = false
        spinner.startAnimating()
        rellenarListaMensajes()
        if(!conversacionNueva && !hacerFoto){
            recuperarListadoMensajes()
        }else if(hacerFoto){
            hacerFoto = false
        }
        addTap()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recargarPantalla", name:notificationChat, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
        listaMensajes.removeAll(keepCapacity: false)
        listaMensajesPaginada.removeAll(keepCapacity: false)
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
        NSNotificationCenter.defaultCenter().removeObserver(self, name: notificationChat, object: nil)
        myTimer.invalidate()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(listaMensajes.isEmpty && !conversacionNueva){
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
        if(numeroMensajesSinLeer > 0){
            UIApplication.sharedApplication().applicationIconBadgeNumber = numeroMensajesSinLeer
        }else{
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
    }
    
    func addTap(){
        let tapRec = UITapGestureRecognizer()
        tapRec.addTarget(self, action: "tappedTabla")
        miTabla.addGestureRecognizer(tapRec)
    }
    
    func tappedTabla(){
        self.view.endEditing(true)
    }
    
    func rellenarListaMensajes(){
        //Recogemos los datos en segundo plano para no bloquear la interfaz
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.listaMensajes = Messsage.devolverListMessages(self.conversationKey)
            
            if(!self.listaMensajes.isEmpty){
                self.conversacionNueva = false
                Conversation.cambiarFlagNewMessageUserConversation(self.conversationKey,nuevo: false)
                self.resetearBadgeIconoApp()
                if(self.listaMensajes.count > 20){
                    let botonMasMensajes = ["message_key": "a","converstation_key": "a", "sender": "a", "created": "a", "content": "a", "type": "botonMensajeAnterior", "enviado":"true", "fname": "a", "lname": "a"]
                    let fakeDictMasMensajeBoton = MessageModel(aDict: botonMasMensajes)
                    self.listaMensajesPaginada = Array(self.listaMensajes[(0)..<20])//Copiamos los 20 primeros elementos de la lista
                    self.listaMensajesPaginada.append(fakeDictMasMensajeBoton)
                }else{
                    self.listaMensajesPaginada = self.listaMensajes
                }
            }
            //Cuando acabamos todo lo demas volvemos al hilo principal para actualizar la UI
            dispatch_async(dispatch_get_main_queue()) {
                self.miTabla.reloadData()
                self.spinner.stopAnimating()
            }
        //})
            })
    }
    
    func recargarPantalla(){//Recargamos la pantalla cuando nos llegue una notificacion
        listaMensajes.removeAll(keepCapacity: false)
        listaMensajesPaginada.removeAll(keepCapacity: false)
        mostrarMensajesAnteriores = false
        moverUltimaFila = true
        Conversation.cambiarFlagNewMessageUserConversation(conversationKey,nuevo: true)
        resetearBadgeIconoApp()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.rellenarListaMensajes()
        })
    }
    
    //Funcion que va aumentando la lista de mensajes de 20 en 20 siempre que sea posible
    func mostrarMasMensajes(){
        indicePaginado += 1
        if(listaMensajes.count > (indicePaginado * 20)){
            listaMensajesPaginada.removeAll(keepCapacity: false)//Vaciamos la lista para añadir los elementos paginados
            let indiceFinal = (indicePaginado + 1) * 20
            if( indiceFinal < listaMensajes.count){ //Comprobamos si se pueden mostrar los 20 siguientes mensajes enteros
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
        self.tabBarController?.tabBar.hidden = true
    }
    
    //Funcion para visualizar la ultima fila de la tabla
    func establecerUltimaFilaTabla(){
        let lastSection = miTabla.numberOfSections - 1
        let lastRow = miTabla.numberOfRowsInSection(lastSection) - 1
        let ip = NSIndexPath(forRow: lastRow, inSection: lastSection)
        miTabla.scrollToRowAtIndexPath(ip, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
    }
    
    func mostrarAlerta(){
        //Nos aseguramos que esta en el hilo principal o rompera
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.endEditing(true)
            let alert = UIAlertController(title: self.tituloAlert, message: self.mensajeAlert, preferredStyle: UIAlertControllerStyle.Alert)
            alert.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
            //Añadimos un bonton al alert y lo que queramos que haga en la clausur
            if(self.desLoguear){
                self.desLoguear = false
                myTimerLeftMenu.invalidate()
                alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler: { (action) -> Void in
                    LogOut.desLoguearBorrarDatos()
                    self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                }))
            }else{
                //Añadimos un bonton al alert y lo que queramos que haga en la clausur
                alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler: { (action) -> Void in
                    if(self.codError == "list_messages_empty"){
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                }))
            }
            //mostramos el alert
            self.presentViewController(alert, animated: true) { () -> Void in
                self.tituloAlert = ""
                self.mensajeAlert = ""
            }
        })
    }
    
    //Funcion para reenviar el mensaje cuando fallo y pulsamos el boton
    func reenviarMensaje(sender:UIButton){
        var upMessage = false
        var posicion = 0
        let alert = UIAlertController(title: "Elija una opción", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Reenviar mensajes fallidos", style: .Default, handler: { action -> Void in
            let listaMensajesFallidos = Messsage.devolverMensajesFallidos(self.conversationKey)
            for mensajeFallido in listaMensajesFallidos{
                Messsage.cambiarEstadoEnviadoMensaje(mensajeFallido.conversationKey, messageKey: mensajeFallido.messageKey, enviado: "true")
                let fechaActualizada = Fechas.fechaActualToString()
                Messsage.actualizarFechaMensaje(self.conversationKey, messageKey: mensajeFallido.messageKey, fecha: fechaActualizada)
                self.rellenarListaMensajes()
                var content = ""
                if(mensajeFallido.type == "jpeg_base64" || mensajeFallido.type == "mp4_base64"){
                    content = mensajeFallido.content.stringByReplacingOccurrencesOfString("+", withString: "%2B", options: [], range: nil)
                }
                else{
                    content = mensajeFallido.content
                }
                for (var i=0 ; i < self.listaMessagesKeyFallidos.count; i++){
                    if (mensajeFallido.messageKey == self.listaMessagesKeyFallidos[i]){
                        upMessage = true
                        posicion = i
                        i = self.listaMessagesKeyFallidos.count
                    }
                }
                if(upMessage){
                    self.updateMessage(mensajeFallido.messageKey, content: mensajeFallido.content, tipo: mensajeFallido.type)
                    self.listaMessagesKeyFallidos.removeAtIndex(posicion
                    )
                }else{
                    let sessionKey = Utils.getSessionKey()
                    let params = "action=add_message&session_key=\(sessionKey)&conversation_key=\(self.conversationKey)&type=premessage&app_version=\(appVersion)&app=\(app)"
                    self.addMessage(params, messageKey: mensajeFallido.messageKey, contenido: content, tipo: mensajeFallido.type)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Borrar mensajes fallidos", style: .Default, handler: { action -> Void in
            Messsage.borrarMensajesFallidosConversacion(self.conversationKey)
            //Recuperamos el ultimo mensaje que tenemos tras el borrado para actualizar el ultimo de la conversacion
            let ultimoMensaje = Messsage.devolverUltimoMensajeConversacion(self.conversationKey)
            Conversation.updateLastMesssageConversation(ultimoMensaje.conversationKey , ultimoMensaje: ultimoMensaje.content, fechaCreacion: ultimoMensaje.created)
            self.rellenarListaMensajes()
        }))
        
        //Añdimos un boton para cancelar las opciones
        alert.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: { action -> Void in
            //No hacemos nada........Solo cancelamos el alert
        }))
        
        //mostramos el alert
        self.presentViewController(alert, animated: true) { () -> Void in
            
        }

    }
    
    //Funcion que se ejecuta cuando pulsamos sobre las imagenes de las celdas
    func tapImage(sender: UITapGestureRecognizer){
        indiceSeleccionado = (sender.view?.tag)!
        let listaMensajesOrdenadas = Array(listaMensajesPaginada.reverse())
        if(listaMensajesOrdenadas[indiceSeleccionado].type == "jpeg_base64"){
            performSegueWithIdentifier(imagenDetailSegue, sender: self)
        }else if(listaMensajesOrdenadas[indiceSeleccionado].type == "mp4_base64"){
            performSegueWithIdentifier(videoSegue, sender: self)
        }else{
            performSegueWithIdentifier(pdfSegue, sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == imagenDetailSegue){
            let listaMensajesOrdenadas = Array(listaMensajesPaginada.reverse())
            let imagenMostrar = decodificarImagen(listaMensajesOrdenadas[indiceSeleccionado].content)
            let imagenDetailVC = segue.destinationViewController as! ImageDetailController
            imagenDetailVC.imagenMostrada = imagenMostrar
            
        }else if(segue.identifier == videoSegue){
            let listaMensajesOrdenadas = Array(listaMensajesPaginada.reverse())
            let mostrarVideoVC = segue.destinationViewController as! VideoViewController
            mostrarVideoVC.dataVideo = Utils.decodificarVideo(listaMensajesOrdenadas[indiceSeleccionado].content)
            mostrarVideoVC.messageKey = listaMensajesOrdenadas[indiceSeleccionado].messageKey
        }else if(segue.identifier == pdfSegue){
            var listaMensajesOrdenadas = Array(listaMensajesPaginada.reverse())
            let urlPdf = Utils.returnUrlWS("pdf") + listaMensajesOrdenadas[indiceSeleccionado].messageKey + ".pdf"
            let detailPdf = segue.destinationViewController as! visorPdfController
            detailPdf.urlString = urlPdf
            detailPdf.titulo = listaMensajesOrdenadas[indiceSeleccionado].content
        }
    }
    
    //Funcion que se ejecuta cuando pulsamos sobre los botones de realizar encuesta o abrir pdf
    func tapCell(sender: UITapGestureRecognizer){
        let row = sender.view?.tag
        if let indice = row{
            indiceSeleccionado = indice
            performSegueWithIdentifier(pdfSegue, sender: self)
        }
    }
    
    func addNuevaConversacion(lastMessage:String){
        if let user = User.obtenerUser(userKey){
            let imageData = UIImagePNGRepresentation((user.avatar)!)
            var avatar = ""
            if let avatarImage = imageData?.base64EncodedStringWithOptions([]){
                avatar = avatarImage
            }
        
            let hora = NSString(string: Conversation.devolverHoraUltimaConversacion()).doubleValue
            if(NSString(string: fechaCreacion).doubleValue < hora){
                fechaCreacion = "\(hora + 3)"
            }
            let auxUserDict = ["user_key":userKey, "avatar": avatar,"connection-status": user.connectionStatus]
            let userNameArray = user.userName.componentsSeparatedByString(" ")
            let userFname:String = userNameArray[0]
            var lnameUser = ""
            for(var i = 1; i < userNameArray.count; i++){
                lnameUser += userNameArray[i] + " "
            }
            let conversacionDict = ["conversation_key": conversationKey, "user_fname": userFname, "user_lname": lnameUser,"user": auxUserDict, "flag_new_message_user": "0", "last_message": lastMessage, "last_update": fechaCreacion]
            _=Conversation(aDict: conversacionDict, aLastUpdate: fechaCreacion, existe: false)
        }
    
    }
  
    
    //Funcion para devolver la encuesta enviada formateada
    func devolverEncuestaEnviadaFormateada(pregunta:String, respuesta:String, puntuacion:String) -> NSMutableAttributedString{
        let style = "<style>body { font-family: HelveticaNeue; font-size:14px } b{font-size:10px}</style>" //String para formatear la font family en todas las politicas
        var mezcla = ""
        if(respuesta.isEmpty && puntuacion.isEmpty){
            let tituloEncuesta = "<b>Encuesta enviada:</b><br>"
            mezcla = style + tituloEncuesta + pregunta
        }else{
            let tituloEncuesta = "<b>Encuesta enviada:</b><br>"
            let tituloRespuesta = "<b>Respuesta recibida (\(puntuacion)/5):</b><br>"
            mezcla = style + tituloEncuesta + pregunta + "<br><br>" + tituloRespuesta + respuesta
        }
        return try! NSMutableAttributedString(
            data: mezcla.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
    }
    
    
    //MARK: - ComunicacionServidor
    func recuperarListadoMensajes(){
        let sessionKey = Utils.getSessionKey()
        let lastUpdate = Conversation.obtenerLastUpdate(conversationKey)
        let params = "action=list_messages&session_key=\(sessionKey)&conversation_key=\(conversationKey)&last_update=\(lastUpdate)&offset=\(0)&limit=\(1000)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("conversations")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let recuperarListadoMensajesTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                if let dataResultado = json.objectForKey("data") as? NSDictionary{//4
                                    if let lastUp = dataResultado.objectForKey("last_update") as? String{//5
                                        Conversation.modificarLastUpdate(self.conversationKey, aLastUpdate: lastUp)
                                    }//5
                                    if let needToUpdate = dataResultado.objectForKey("need_to_update") as? Bool{//6
                                        if (needToUpdate){//7
                                            Messsage.borrarMensajesConConverstaionKey(self.conversationKey)
                                            if let messagesArray = dataResultado.objectForKey("messages") as? [NSDictionary]{//8
                                                //Llamamos por cada elemento del array de empresas al constructor
                                                for dict in messagesArray{//9
                                                    _ = Messsage(aDict: dict, aConversationKey: self.conversationKey)
                                                }//9
                                            }//8
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                self.rellenarListaMensajes()
                                            })
                                        }//7
                                    }//6
                                }//4
                            })
                        }//3
                        else{
                            if let codigoError = json.objectForKey("error_code") as? String{
                                self.codError = codigoError
                                self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.mostrarAlerta()
                                })
                            }
                        }
                    }
                }
            } catch{
                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.mostrarAlerta()
                })
            }
        }
        recuperarListadoMensajesTask.resume()
    }
    
    func crearConversacion(){
        let sessionKey = Utils.getSessionKey()
         let params = "action=open_conversation&session_key=\(sessionKey)&user_key=\(userKey)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("conversations")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let semaphore = dispatch_semaphore_create(0)
        let openConversationTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            if let dataResultado = json.objectForKey("data") as? NSDictionary{
                                if let claveConversacion  = dataResultado.objectForKey("conversation_key") as? String{
                                    self.conversationKey = claveConversacion
                                    self.conversacionNueva = false
                                    self.myTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "recuperarListadoMensajesTimer", userInfo: nil, repeats: true)
                                    if let lastUpdate = dataResultado.objectForKey("conversations_last_update") as? String{
                                        Utils.saveConversationsLastUpdate(lastUpdate)
                                    }
                                }
                            }
                        }else{
                            if let codigoError = json.objectForKey("error_code") as? String{
                                self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.mostrarAlerta()
                                })
                            }
                        }
                    }
                }
            } catch{
                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.mostrarAlerta()
                })
            }
            dispatch_semaphore_signal(semaphore)
        }
        openConversationTask.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    func addMessage(params:String, messageKey:String, contenido:String, tipo:String){
        let urlServidor = Utils.returnUrlWS("conversations")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let addMensajeTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if(error != nil){
                    if(error!.code == -1005){
                        self.addMessage(params, messageKey: messageKey, contenido: contenido, tipo: tipo)
                    }
                }else{
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                        if let resultCode = json.objectForKey("result") as? Int{
                            if(resultCode == 1){
                                //Se ha insertado  el mensaje correctamente y por lo tanto guardamos el lastUpdate
                                if let dataResultado = json.objectForKey("data") as? NSDictionary{
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        if let lastUpd = dataResultado.objectForKey("last_update") as?String{
                                            var hora = NSString(string: Messsage.devolverHoraUltimoMensaje(self.conversationKey)).doubleValue
                                            if(NSString(string: lastUpd).doubleValue < hora){
                                                hora = hora + 3
                                            }
                                            Messsage.actualizarFechaMensaje(self.conversationKey, messageKey: messageKey, fecha: "\(hora)")
                                        }
                                        if let messageKeyServidor = dataResultado.objectForKey("message_key") as?String {
                                            Messsage.updateMessageKeyTemporal(self.conversationKey, messageKey: messageKey, messageKeyServidor: messageKeyServidor)
                                            self.updateMessage(messageKeyServidor, content: contenido,tipo: tipo)
                                        }
                                    })
                                }
                            }else{
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    Messsage.cambiarEstadoEnviadoMensaje(self.conversationKey, messageKey: messageKey, enviado: "false")
                                    let anUltimoMensajeEnviado = Messsage.devolverUltimoMensajeEnviadoOk(self.conversationKey)
                                    if let ultimoMensajeEnviado = anUltimoMensajeEnviado{
                                        Conversation.updateLastMesssageConversation(ultimoMensajeEnviado.conversationKey, ultimoMensaje: ultimoMensajeEnviado.content, fechaCreacion: ultimoMensajeEnviado.created)
                                    }
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.rellenarListaMensajes()
                                    })
                                    if let codigoError = json.objectForKey("error_code") as? String{
                                        self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                                        (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            self.mostrarAlerta()
                                        })
                                    }
                                })
                            }
                        }
                    }
                }
            } catch{
                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.mostrarAlerta()
                })
            }
        }
        addMensajeTask.resume()
    }
    
    func updateMessage(messageKey:String, content:String, tipo:String){
        let sessionKey = Utils.getSessionKey()
        let params = "action=update_message&session_key=\(sessionKey)&conversation_key=\(conversationKey)&message_key=\(messageKey)&content=\(content)&type=\(tipo)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("conversations")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let udpateMensajeTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if(error != nil){
                    if(error!.code == -1005){
                        self.updateMessage(messageKey, content: content,tipo: tipo)
                    }
                }else{
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                        if let resultCode = json.objectForKey("result") as? Int{
                            if(resultCode == 1){
                            //LogOutCorrecto
                            }else{
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.listaMessagesKeyFallidos.append(messageKey)
                                    Messsage.cambiarEstadoEnviadoMensaje(self.conversationKey, messageKey: messageKey, enviado: "false")
                                    let anUltimoMensajeEnviado = Messsage.devolverUltimoMensajeEnviadoOk(self.conversationKey)
                                    if let ultimoMensajeEnviado = anUltimoMensajeEnviado{
                                        Conversation.updateLastMesssageConversation(ultimoMensajeEnviado.conversationKey, ultimoMensaje: ultimoMensajeEnviado.content, fechaCreacion: ultimoMensajeEnviado.created)
                                    }
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.rellenarListaMensajes()
                                    })
                                    if let codigoError = json.objectForKey("error_code") as? String{
                                        self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                                        (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            self.mostrarAlerta()
                                        })
                                    }
                                })
                            }
                        }
                    }
                }
            } catch{
                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.mostrarAlerta()
                })
            }
        }
        udpateMensajeTask.resume()
    }
    
    //MARK: - Teclado
    func dissmisKeyboard(){
        self.view.endEditing(true)
    }
    
    func startObservingKeyBoard(){
        //Funcion para darnos de alta como observador en las notificaciones de teclado
        let nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "notifyThatKeyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: "notifyThatKeyboardWillDisappear:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Funcion para darnos de alta como observador en las notificaciones de teclado
    func stopObservingKeyBoard(){
        let nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
    }

    //Funcion que se ejecuta cuando aparece el teclado
    func notifyThatKeyboardWillAppear(notification:NSNotification){
        keyboardIsShowing = true
        
        if let info = notification.userInfo {
            self.moverUltimaFila = true
            self.mostrarMensajesAnteriores = false
            self.miTabla.reloadData()

            keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            bottomConstratitVistaTeclado.constant = keyboardFrame.size.height
            UIView.animateWithDuration(0.25, animations:  {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //Funcion que se ejecuta cuando desaparece el teclado
    func notifyThatKeyboardWillDisappear(notification:NSNotification){
        keyboardIsShowing = false
        bottomConstratitVistaTeclado.constant = 0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    //Funcion que evita que el teclado solape la vista de un determinado control
    func arrangeViewOffsetFromKeyboard()
    {
            let theApp: UIApplication = UIApplication.sharedApplication()
            let windowView: UIView? = theApp.delegate!.window!
            
            let textFieldLowerPoint: CGPoint = CGPointMake(vistaContenedoraTeclado.frame.origin.x, vistaContenedoraTeclado!.frame.origin.y + vistaContenedoraTeclado!.frame.size.height)
        
            let convertedTextFieldLowerPoint: CGPoint = self.view.convertPoint(textFieldLowerPoint, toView: windowView)
            
            let targetTextFieldLowerPoint: CGPoint = CGPointMake(vistaContenedoraTeclado!.frame.origin.x, keyboardFrame.origin.y)
            
            let targetPointOffset: CGFloat = targetTextFieldLowerPoint.y - convertedTextFieldLowerPoint.y
            let adjustedViewFrameCenter: CGPoint = CGPointMake(self.view.center.x, self.view.center.y + targetPointOffset)
            UIView.animateWithDuration(0.25, animations:  {
                self.view.center = adjustedViewFrameCenter
            })
    }

    //Funcion que devuelve al estado origian la vista
    func returnViewToInitialFrame()
    {
        let initialViewRect: CGRect = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        
        if (!CGRectEqualToRect(initialViewRect, self.view.frame))
        {
            UIView.animateWithDuration(0.2, animations: {
                self.view.frame = initialViewRect
            });
        }
    }
    
    //Funcion para decodificar una imagen a partir de un String
    func decodificarImagen (dataImage:String) -> UIImage{
        if let decodedData = NSData(base64EncodedString: dataImage, options:NSDataBase64DecodingOptions.IgnoreUnknownCharacters){
            if(decodedData.length > 0){
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
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaMensajesPaginada.count
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let listaMensajesOrdenadas = Array(listaMensajesPaginada.reverse())
        if(listaMensajesOrdenadas[indexPath.row].sender != "brand"){
            if(listaMensajesOrdenadas[indexPath.row].type == "jpeg_base64"){
                let cell = tableView.dequeueReusableCellWithIdentifier("FotoBrand") as! CeldaImagenMensajes
                cell.imagen.image = listaMensajesOrdenadas[indexPath.row ].miniImagen
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row ].created)
                
                ////////////////////Añadimos el tap a la imagen////////////////////
                cell.imagen.userInteractionEnabled = true
                cell.imagen.tag = indexPath.row
                let tapRec = UITapGestureRecognizer()
                tapRec.addTarget(self, action: "tapImage:")
                cell.imagen.addGestureRecognizer(tapRec)
                //////////////////////////////////////////////////////////////////
                
                //Ocultamos el boton play
                cell.playImage.hidden = true
                
                return cell
            }else if(listaMensajesOrdenadas[indexPath.row].type == "mp4_base64"){
                let cell = tableView.dequeueReusableCellWithIdentifier("FotoBrand") as! CeldaImagenMensajes
                cell.imagen.image = listaMensajesOrdenadas[indexPath.row ].miniImagen
                cell.imagen.contentMode = UIViewContentMode.Redraw
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row ].created)
                
                ////////////////////Añadimos el tap a la imagen////////////////////
                cell.playImage.userInteractionEnabled = true
                cell.playImage.tag = indexPath.row
                cell.imagen.userInteractionEnabled = true
                cell.imagen.tag = indexPath.row
                let tapRec = UITapGestureRecognizer()
                tapRec.addTarget(self, action: "tapImage:")
                cell.imagen.addGestureRecognizer(tapRec)
                cell.playImage.addGestureRecognizer(tapRec)
                //////////////////////////////////////////////////////////////////
                
                return cell
            }else if(listaMensajesOrdenadas[indexPath.row].type == "poll_response"){
                let cell = tableView.dequeueReusableCellWithIdentifier("MensajeBrand") as! CeldaTextoMensaje
                let preguntaRespuesta = listaMensajesOrdenadas[indexPath.row].content
                let contenidoArray = preguntaRespuesta.componentsSeparatedByString("::")
                let preguntaEncuesta = contenidoArray[0]
                let puntuacionEncuesta = contenidoArray[1]
                let respuestaEncuesta = contenidoArray[2]
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row].created)
                cell.mensaje.attributedText = devolverEncuestaEnviadaFormateada(preguntaEncuesta,respuesta: respuestaEncuesta, puntuacion: puntuacionEncuesta)
                return cell
            }else if(listaMensajesOrdenadas[indexPath.row].type == "botonMensajeAnterior"){
                let cell = tableView.dequeueReusableCellWithIdentifier(cargarMensajesAnterioresId) as! CeldaCargarMensajesAnteriores
                //Añadimos una accion a cada boton(llamar/Info)
                cell.btnCargarMensajesAnteriores.addTarget(self, action: "mostrarMasMensajes", forControlEvents: UIControlEvents.TouchUpInside)
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("MensajeBrand") as! CeldaTextoMensaje
                let mensajeString = NSMutableAttributedString(string: listaMensajesOrdenadas[indexPath.row].content)
                mensajeString.addAttribute(NSFontAttributeName, value: UIFont(name: "Helvetica Neue", size: 14.0)!, range: NSMakeRange(0, mensajeString.length))
                cell.mensaje.attributedText = mensajeString
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row ].created)
                cell.botonReenviarMensaje.hidden = true
                return cell
            }
        }else{
            if(listaMensajesOrdenadas[indexPath.row].type == "jpeg_base64"){
                let cell = tableView.dequeueReusableCellWithIdentifier("FotoUsuario") as! CeldaImagenMensajes
                cell.imagen.image = listaMensajesOrdenadas[indexPath.row ].miniImagen
                cell.imagen.contentMode = UIViewContentMode.Redraw
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row ].created)
                cell.senderBrandName.text = listaMensajesOrdenadas[indexPath.row].fname + " " + listaMensajesOrdenadas[indexPath.row].lname
                if(listaMensajesOrdenadas[indexPath.row].enviado == "true"){
                    cell.traillingContraitNombre.constant = 10
                    cell.traillingConstraitImagen.constant = 8
                    cell.traillingConstraitHora.constant = 10
                    cell.botonReenviarMensaje.hidden = true
                }else{
                    cell.traillingConstraitImagen.constant = 36
                    cell.traillingConstraitHora.constant = 38
                    cell.traillingContraitNombre.constant = 38
                    cell.botonReenviarMensaje.hidden = false
                }
                cell.botonReenviarMensaje.tag = indexPath.row
                cell.botonReenviarMensaje.addTarget(self, action: "reenviarMensaje:", forControlEvents: UIControlEvents.TouchUpInside)

               
                ////////////////////Añadimos el tap a la imagen////////////////////
                cell.imagen.userInteractionEnabled = true
                cell.imagen.tag = indexPath.row
                let tapRec = UITapGestureRecognizer()
                tapRec.addTarget(self, action: "tapImage:")
                cell.imagen.addGestureRecognizer(tapRec)
                //////////////////////////////////////////////////////////////////
                
                cell.playImage.hidden = true
                
                return cell
            }else if(listaMensajesOrdenadas[indexPath.row].type == "document_pdf"){
                let cell = tableView.dequeueReusableCellWithIdentifier(pdfEncuenstaCellId) as! CeldaPdfEncuesta
                cell.imagen.image = UIImage(named: "pdf")
                cell.mensaje.text = listaMensajesOrdenadas[indexPath.row].content
                cell.accion.text = mensajePdf
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row].created)
                cell.senderBrandName.text = listaMensajesOrdenadas[indexPath.row].fname + " " + listaMensajesOrdenadas[indexPath.row].lname
                ////////////////////Añadimos el tap a la celda////////////////////
                cell.tag = indexPath.row
                let tapRec = UITapGestureRecognizer()
                tapRec.addTarget(self, action: "tapCell:")
                cell.addGestureRecognizer(tapRec)
                //////////////////////////////////////////////////////////////////
                
                return cell
            }else if(listaMensajesOrdenadas[indexPath.row].type == "poll" || listaMensajesOrdenadas[indexPath.row].type == "poll_closed"){
                let cell = tableView.dequeueReusableCellWithIdentifier("MensajeUsuario") as! CeldaTextoMensaje
                cell.senderBrandName.text = listaMensajesOrdenadas[indexPath.row].fname + " " + listaMensajesOrdenadas[indexPath.row].lname
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row].created)
                cell.mensaje.attributedText = devolverEncuestaEnviadaFormateada(listaMensajesOrdenadas[indexPath.row].content,respuesta: "", puntuacion: "")
                //Como vendra desde el manager ocultamos los botones para reenviar
                cell.traillingContraitNombre.constant = 16
                cell.traillingConstrait.constant = 8
                cell.botonReenviarMensaje.hidden = true
                ////////////////////////////////////
                return cell
            }else if(listaMensajesOrdenadas[indexPath.row].type == "premessage"){
                let cell = tableView.dequeueReusableCellWithIdentifier("FotoUsuario") as! CeldaImagenMensajes
                cell.imagen.image = listaMensajesOrdenadas[indexPath.row ].miniImagen
                cell.imagen.contentMode = UIViewContentMode.Redraw
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row ].created)
              
                cell.traillingConstraitImagen.constant = 8
                cell.traillingConstraitHora.constant = 10
                cell.botonReenviarMensaje.hidden = true
                
                let activityIndicator = Utils.crearActivityLoading(160, heigth: 160)
                activityIndicator.startAnimating()
                cell.imagen.addSubview(activityIndicator)
                return cell
                
            }else if(listaMensajesOrdenadas[indexPath.row].type == "mp4_base64"){
                let cell = tableView.dequeueReusableCellWithIdentifier("FotoUsuario") as! CeldaImagenMensajes
                cell.imagen.image = listaMensajesOrdenadas[indexPath.row ].miniImagen
                cell.imagen.contentMode = UIViewContentMode.Redraw
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row ].created)
                cell.senderBrandName.text = listaMensajesOrdenadas[indexPath.row].fname + " " + listaMensajesOrdenadas[indexPath.row].lname
                if(listaMensajesOrdenadas[indexPath.row].enviado == "true"){
                    cell.traillingContraitNombre.constant = 10
                    cell.traillingConstraitImagen.constant = 8
                    cell.traillingConstraitHora.constant = 10
                    cell.botonReenviarMensaje.hidden = true
                }else{
                    cell.traillingConstraitImagen.constant = 36
                    cell.traillingConstraitHora.constant = 38
                    cell.traillingContraitNombre.constant = 38
                    cell.botonReenviarMensaje.hidden = false
                }
                cell.botonReenviarMensaje.tag = indexPath.row
                cell.botonReenviarMensaje.addTarget(self, action: "reenviarMensaje:", forControlEvents: UIControlEvents.TouchUpInside)
                
                
                ////////////////////Añadimos el tap a la imagen////////////////////
                cell.playImage.userInteractionEnabled = true
                cell.playImage.tag = indexPath.row
                cell.imagen.userInteractionEnabled = true
                cell.imagen.tag = indexPath.row
                let tapRec = UITapGestureRecognizer()
                tapRec.addTarget(self, action: "tapImage:")
                cell.imagen.addGestureRecognizer(tapRec)
                cell.playImage.addGestureRecognizer(tapRec)
                //////////////////////////////////////////////////////////////////
                
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("MensajeUsuario") as! CeldaTextoMensaje
                let mensajeString = NSMutableAttributedString(string: listaMensajesOrdenadas[indexPath.row].content)
                mensajeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, mensajeString.length))
                mensajeString.addAttribute(NSFontAttributeName, value: UIFont(name: "Helvetica Neue", size: 14.0)!, range: NSMakeRange(0, mensajeString.length))
                
                cell.mensaje.attributedText = mensajeString
                cell.hora.text = Fechas.devolverTiempo(listaMensajesOrdenadas[indexPath.row ].created)
                cell.senderBrandName.text = listaMensajesOrdenadas[indexPath.row].fname + " " + listaMensajesOrdenadas[indexPath.row].lname
                if(listaMensajesOrdenadas[indexPath.row].enviado == "true"){
                    cell.traillingContraitNombre.constant = 16
                    cell.traillingConstrait.constant = 8
                    cell.botonReenviarMensaje.hidden = true
                }else{
                    cell.traillingContraitNombre.constant = 44
                    cell.traillingConstrait.constant = 36
                    cell.botonReenviarMensaje.hidden = false
                }
                cell.botonReenviarMensaje.tag = indexPath.row
                cell.botonReenviarMensaje.addTarget(self, action: "reenviarMensaje:", forControlEvents: UIControlEvents.TouchUpInside)
                return cell
            }
        }
    }

    //Funcion para discernir cuando es una imagen y establecer un tamaño fijo o cuando no y ponerlo dinámico
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //Usamos este metodo para ver si el indexPath es igual a la ultima celda
        if(indexPath.isEqual(tableView.indexPathsForVisibleRows?.last)){
            if(moverUltimaFila || !mostrarMensajesAnteriores){
                establecerUltimaFilaTabla()
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guardarMensajeYenviar()
        return true
    }
    
    func guardarMensajeYenviar(){
        let tipo = "text"
        //guardamos el valor del mensaje que hemos introducido y lo ponemos a blanco
        var textoMensaje = escribirMensajeOutlet.text!
        escribirMensajeOutlet.text = ""
        //Si el tamaño del texto es mayor que 0 quiere decir que hemos introducido algo
        if(Utils.quitarEspacios(textoMensaje).characters.count > 0){
            
            fechaCreacion = Fechas.fechaActualToString()
            //si venimos de la pantalla de ListBrand, Favoritos o Busqueda es una conversacion nueva con lo cual tenemos que  crear la conversacion
            if(conversacionNueva == true){
                crearConversacion()
                addNuevaConversacion(textoMensaje)
            }else{
                let hora = NSString(string: Messsage.devolverHoraUltimoMensaje(self.conversationKey)).doubleValue
                if(NSString(string: fechaCreacion).doubleValue < hora){
                    fechaCreacion = "\(hora + 3)"
                }
            }
            let messageKey = Messsage.obtenerMessageKeyTemporal()
            //Añadimos un mensaje nuevo al modelo
            let mensajeTextoDict = ["message_key": messageKey, "converstation_key": conversationKey, "sender": "brand", "created": fechaCreacion, "content": textoMensaje, "type": tipo, "enviado": "true", "fname": fname, "lname": lname]
            let mensaje = MessageModel(aDict: mensajeTextoDict)
            _ = Messsage(model: mensaje)
            listaMensajes.removeAll(keepCapacity: false)
            listaMensajes = Messsage.devolverListMessages(conversationKey)
            if(listaMensajes.count > 20){
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
    func formatearFoto(imagenOriginal:UIImage){
        var reducir : Bool
        var tamaño:CGSize?
        var imagenReescalada: UIImage?
        
        listaMensajes.removeAll(keepCapacity: false)
    
        (reducir , tamaño) = ResizeImage().devolverTamaño(imagenOriginal)
        if(!reducir){
            imagenReescalada = ResizeImage().RedimensionarImagen(imagenOriginal)
        }else{
            imagenReescalada = ResizeImage().RedimensionarImagenContamaño(imagenOriginal, targetSize: tamaño!)
        }
        
        fechaCreacion = Fechas.fechaActualToString()
        
        if(conversacionNueva == true){
            crearConversacion()
            addNuevaConversacion("[::image]")
        }else{
            let hora = NSString(string: Messsage.devolverHoraUltimoMensaje(self.conversationKey)).doubleValue
            if(NSString(string: fechaCreacion).doubleValue < hora){
                fechaCreacion = "\(hora + 3)"
            }
        }
        let tipo = "jpeg_base64"
        let contenido = codificarImagen(imagenReescalada!)
        enviarFotoVideo(tipo, contenido: contenido, ultimoMensaje: "📷")
    }
    
    //Funcion para formatear el video a enviar
    func formatearVideo(dataVideo:NSData, urlString:String){
        
        fechaCreacion = Fechas.fechaActualToString()
        
        if(conversacionNueva == true){
            crearConversacion()
            addNuevaConversacion("[::video]")
        }else{
            let hora = NSString(string: Messsage.devolverHoraUltimoMensaje(self.conversationKey)).doubleValue
            if(NSString(string: fechaCreacion).doubleValue < hora){
                fechaCreacion = "\(hora + 3)"
            }
        }
        let tipo = "mp4_base64"
        let contenido = codificarVideo(dataVideo)
        enviarFotoVideo(tipo, contenido: contenido, ultimoMensaje: "📹")
    }
    
    //Funcion para enviar tanto si es foto como video
    func enviarFotoVideo(tipo:String, contenido:String, ultimoMensaje:String){
        let messageKey = Messsage.obtenerMessageKeyTemporal()
        
        let mensajeTextoDict = ["message_key": messageKey, "converstation_key": conversationKey, "sender": "brand", "created": fechaCreacion, "content": contenido, "type": tipo, "enviado":"true", "fname": fname, "lname": lname]
        let mensaje = MessageModel(aDict: mensajeTextoDict)
        _ = Messsage(model: mensaje)
        listaMensajes.removeAll(keepCapacity: false)
        listaMensajes = Messsage.devolverListMessages(conversationKey)
        if(listaMensajes.count > 20){
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
        let content = contenido.stringByReplacingOccurrencesOfString("+", withString: "%2B", options: [], range: nil)
        let sessionKey = Utils.getSessionKey()
        let params = "action=add_message&session_key=\(sessionKey)&conversation_key=\(conversationKey)&type=premessage&app_version=\(appVersion)&app=\(app)"
        addMessage(params, messageKey: messageKey, contenido: content, tipo: tipo)

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        //Comprobamos si es una imagen o un video
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //Es una imagen
            formatearFoto(pickedImage)
        }else{//Es un video
            if let urlVideo = info[UIImagePickerControllerMediaURL] as? NSURL{
                convertToMp4(urlVideo)
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    // Funcion que codifica la imagen
    func codificarImagen(dataImage:UIImage) -> String{
        let imageData = UIImagePNGRepresentation(dataImage)
        return imageData!.base64EncodedStringWithOptions([])
    }
    
    //Funcion que codifica el video
    func codificarVideo(dataVideo:NSData) -> String{
        return dataVideo.base64EncodedStringWithOptions([])
    }
    
    //Funcion para convertir de .mov a .mp4
    func convertToMp4(urlMov:NSURL){
        let doubleNSString = NSString(string: Fechas.fechaActualToString())
        let timestampAsDouble = Int(doubleNSString.doubleValue * 1000)
        let idVideo = "\(timestampAsDouble)"
        let video = AVURLAsset(URL: urlMov, options: nil)
        let exportSession = AVAssetExportSession(asset: video, presetName: AVAssetExportPresetMediumQuality)
        let myDocumentPath = applicationDocumentsDirectory().stringByAppendingPathComponent(idVideo + ".mp4")
        let url = NSURL(fileURLWithPath: myDocumentPath)
        exportSession!.outputURL = url
        exportSession!.outputFileType = AVFileTypeMPEG4;
        exportSession!.shouldOptimizeForNetworkUse = true;
        
        exportSession!.exportAsynchronouslyWithCompletionHandler ({
            if(exportSession!.status == AVAssetExportSessionStatus.Completed){
                if let videoData = NSData(contentsOfURL: url){
                    self.formatearVideo(videoData, urlString: "\(url)")
                }
            }else{
                //Fallo la exportacion y no hacemos nada
            }
        })
    }
    
    func applicationDocumentsDirectory() -> NSString {//En esta funcion obtenemos la ruta temporal donde guardar nuestro archivo
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    }

}
