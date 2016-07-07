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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        modificarUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.cambiarBadge), name:NSNotification.Name(rawValue: notificationChat), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notificationChat), object: nil)
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
        crearBotonesBarraNavegacion()
        lblMensajeAdvertencia.text = "Para poder recuperar su contraseña y confirmar que no se está suplantando su identidad, enviaremos un correo electrónico con las instrucciones para recuperar la contraseña. Su cuenta se mantendrá activa en todo momento."
    }
    
    //Creamos los botones de la barra de navegacion
    func crearBotonesBarraNavegacion(){
        rightButton.title = "Recuperar Contraseña"
        rightButton.style = .plain
        rightButton.target = self
        rightButton.isEnabled = true
        rightButton.action = #selector(self.recuPass)
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
        if formatoCamposOk && !desLoguear{
            tituloAlert = "Revise su correo electrónico"
            mensajeAlert = "Siga las instrucciones que se indican en el correo para recuperar la contraseña. Puede que el correo llegue a su cuenta de Spam."
        }
        
        let alertError = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.alert)
        alertError.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausur
        if desLoguear{
            desLoguear = false
            myTimerLeftMenu.invalidate()
            alertError.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { (action) -> Void in
                LogOut.desLoguearBorrarDatos()
                //self.navigationController?.popToRootViewControllerAnimated(false)
                self.presentingViewController!.dismiss(animated: true, completion: nil)
            }))
        }else{
            alertError.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { action in
                
            }))
        }
        //mostramos el alert
        self.present(alertError, animated: true) { () -> Void in
            self.tituloAlert = ""
            self.mensajeAlert = ""
        }
    }
    
    func recuperarPassword(){
        let sessionKey = Utils.getSessionKey()
        let params = "action=recover_password&session_key=\(sessionKey)&app_version=\(appVersion)&app=\(app)"
        let serverString = Utils.returnUrlWS("access")
        if let url = URL(string: serverString){
            ServerUtils.getAsyncResponse(method: HTTPMethods.POST.rawValue, url: url, params: params, completionBlock: { (error, json) in
                if error != TypeOfError.NOERROR.rawValue{
                    (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(error)
                    self.mostrarAlerta()
                }else{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                            let lastUpdate = dataResultado["last_update"] as? String ?? ""
                            Utils.saveLastUpdate(lastUpdate)
                        }
                    }else{
                        self.formatoCamposOk = false
                        let codigoError = json["error_code"] as? String ?? ""
                        self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                        (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                        self.mostrarAlerta()
                    }
                }
            })
        }else{
            (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(TypeOfError.DEFAUTL.rawValue)
            self.mostrarAlerta()
        }
    }
}
