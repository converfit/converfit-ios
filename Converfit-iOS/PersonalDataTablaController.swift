//
//  PersonalDataTablaController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 7/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class PersonalDataTablaController: UITableViewController {
    
    //MARK: - Variables
    let rightButton = UIBarButtonItem()
    var mensajeAlert = ""
    var tituloAlert = ""
    var formatoCamposOk = true
    var nombreTexto = ""
    var apellidosTexto = ""
    var desLoguear = false

    //MARK: - Outlets
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var apellidos: UITextField!
    @IBOutlet var miTablaPersonalizada: UITableView!
    
    //MARK: - Actions
    @IBAction func btnCambioNombre(_ sender: AnyObject) {
        activarBotonGuardarCambios()
    }
    @IBAction func btnCambioApellidos(_ sender: AnyObject) {
        activarBotonGuardarCambios()
    }
    
    //MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        modificarUI()
        //Nos damos de alta para responder a la notificacion enviada por push
        NotificationCenter.default.addObserver(self, selector: #selector(self.cambiarBadge), name:NSNotification.Name(rawValue: notificationChat), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notificationChat), object: nil)
    }
    
    //MARK: - Utils
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
        self.tabBarController?.tabBar.isHidden = true
        //Creamos un footer con un UIView para eliminar los separator extras
        miTablaPersonalizada.tableFooterView = UIView()
        crearBotonesBarraNavegacion()
        addTap()
    }
    
    //Creamos los botones de la barra de navegacion
    func crearBotonesBarraNavegacion(){
        rightButton.title = "Guardar Cambios"
        rightButton.style = .plain
        rightButton.target = self
        rightButton.isEnabled = false
        rightButton.action = #selector(self.updatePersonalData)
        navigationItem.rightBarButtonItem = rightButton
    }

    func updatePersonalData(){
        //Ocultamos el teclado
        self.view.endEditing(true)
        //Ponemos el valor por defecto a true cada vez que pulsamos el boton para hacer las comprobaciones y del mensaje de error
        formatoCamposOk = true
        mensajeAlert = ""
        tituloAlert = ""
        
        nombreTexto = Utils.removerEspaciosBlanco(nombre.text!)
        apellidosTexto = Utils.removerEspaciosBlanco(apellidos.text!)
        comprobarFormatos()
        if formatoCamposOk{
            updateData()
        }else{
            mostrarAlerta()
        }
    }

    func activarBotonGuardarCambios(){
        if nombre.text!.isEmpty || apellidos.text!.isEmpty{
            rightButton.isEnabled = false
        }else{
            rightButton.isEnabled = true
        }
    }
    
    func comprobarFormatos(){
        if nombre.text!.characters.count < 3 || nombre.text!.characters.count > 50{
            (tituloAlert,mensajeAlert) = Utils.returnTitleAndMessageAlert("formato_nombre")
            formatoCamposOk = false
        }else if apellidos.text!.characters.count < 3 || apellidos.text!.characters.count > 50{
            (tituloAlert,mensajeAlert) = Utils.returnTitleAndMessageAlert("formato_apellidos")
            formatoCamposOk = false
        }
    }
    
    func mostrarAlerta(){
        if formatoCamposOk{
            tituloAlert = "Cambios guardados"
            mensajeAlert = "Su información ha sido almacenada correctamente."
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
            alertError.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler:{ action in
                    
            }))
        }
        self.present(alertError, animated: true, completion: nil)
        
    }
    
    //Añadir un UITapGestureRecognizer para ocultar el teclado al pulsar sobre la tabla
    func addTap(){
        let tapRec = UITapGestureRecognizer()
        tapRec.addTarget(self, action: #selector(self.tappedTabla))
        miTablaPersonalizada.addGestureRecognizer(tapRec)
    }
    
    func tappedTabla(){
        self.view.endEditing(true)
    }
        
    func updateData(){
        let sessionKey = Utils.getSessionKey()
        let params = "action=update_personal_data&session_key=\(sessionKey)&fname=\(nombreTexto)&lname=\(apellidosTexto)&app_version=\(appVersion)&app=\(app)"
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
                            self.mostrarAlerta()
                        }
                    }else{
                        self.formatoCamposOk = false
                        let codigoError = json["error_code"] as? String ?? ""
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
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}

//MARK: - UITextFieldDelegate
extension PersonalDataTablaController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
