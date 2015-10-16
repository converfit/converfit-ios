//
//  RecuperarPassController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 7/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class RecuperarPassController: UIViewController {

    //MARK: - Variables
    let rightButton = UIBarButtonItem()
    var mensajeAlert = ""
    var tituloAlert = ""
    var formatoCamposOk = true
    var desLoguear = false

    //MARK: - Outlets
    @IBOutlet weak var lblMensajeAdvertencia: UILabel!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        modificarUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cambiarBadge", name:notificationChat, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: notificationChat, object: nil)
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
        crearBotonesBarraNavegacion()
        lblMensajeAdvertencia.text = "Para poder recuperar su contraseña y confirmar que no se está suplantando su identidad, enviaremos un correo electrónico con las instrucciones para recuperar la contraseña. Su cuenta se mantendrá activa en todo momento."
    }
    
    //Creamos los botones de la barra de navegacion
    func crearBotonesBarraNavegacion(){
        rightButton.title = "Recuperar Contraseña"
        rightButton.style = .Plain
        rightButton.target = self
        rightButton.enabled = true
        rightButton.action = "recuPass"
        navigationItem.rightBarButtonItem = rightButton
    }
    
    func recuPass(){
        //Ponemos el valor por defecto a true cada vez que pulsamos el boton para hacer las comprobaciones y del mensaje de error
        formatoCamposOk = true
        mensajeAlert = ""
        tituloAlert = ""
        recuPass()
    }
    
    func mostrarAlerta(){
        if(formatoCamposOk && !desLoguear){
            tituloAlert = "Revise su correo electrónico"
            mensajeAlert = "Siga las instrucciones que se indican en el correo para recuperar la contraseña. Puede que el correo llegue a su cuenta de Spam."
        }
        
        let alertError = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.Alert)
        alertError.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausur
        if(desLoguear){
            desLoguear = false
            alertError.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler: { (action) -> Void in
                LogOut.desLoguearBorrarDatos()
                self.navigationController?.popToRootViewControllerAnimated(false)
            }))
        }else{
            alertError.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler: { action in
                
            }))
        }
        //mostramos el alert
        self.presentViewController(alertError, animated: true) { () -> Void in
            self.tituloAlert = ""
            self.mensajeAlert = ""
        }
    }
    
    func recuperarPassword(){
        let sessionKey = Utils.getSessionKey()
        let params = "action=recover_password&session_key=\(sessionKey)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("access")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let recuperarPasswordTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            if let dataResultado = json.objectForKey("data") as? NSDictionary{
                                if let lastUpdate = dataResultado.objectForKey("last_update") as? String{
                                    Utils.saveLastUpdate(lastUpdate)
                                }
                            }
                        }else{
                            self.formatoCamposOk = false
                            if let codigoError = json.objectForKey("error_code") as? String{
                                self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                self.mostrarAlerta()
                            }
                        }
                    }
                }
            } catch{
                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                self.mostrarAlerta()
                
            }
        }
        recuperarPasswordTask.resume()
    }
}
