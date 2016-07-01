//
//  ChangePasswordTableController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 7/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class ChangePasswordTableController: UITableViewController {

    //MARK: - Variables
    let rightButton = UIBarButtonItem()
    var mensajeAlert = ""
    var tituloAlert = ""
    var formatoCamposOk = true
    var passActu = ""
    var passNew = ""
    var desLoguear = false
    
    //MARK: - Outlets
    @IBOutlet weak var txtPassActual: UITextField!
    @IBOutlet weak var txtPassNew: UITextField!
    @IBOutlet var miTablaPersonalizada: UITableView!
    
    //MARK: - Actions
    @IBAction func btnPassActu(_ sender: AnyObject) {
        activarBotonGuardarCambios()
    }
    @IBAction func btnPassNew(_ sender: AnyObject) {
        activarBotonGuardarCambios()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modificarUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addTap()
         NotificationCenter.default().addObserver(self, selector: #selector(self.cambiarBadge), name:notificationChat, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name(rawValue: notificationChat), object: nil)
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
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        crearBotonesBarraNavegacion()
    }
    
    //Creamos los botones de la barra de navegacion
    func crearBotonesBarraNavegacion(){
        rightButton.title = "Guardar Cambios"
        rightButton.style = .plain
        rightButton.target = self
        rightButton.isEnabled = false
        rightButton.action = #selector(self.updatePass)
        navigationItem.rightBarButtonItem = rightButton
    }

    func updatePass(){
        //Ocultamos el teclado
        self.view.endEditing(true)
        //Ponemos el valor por defecto a true cada vez que pulsamos el boton para hacer las comprobaciones y del mensaje de error
        formatoCamposOk = true
        mensajeAlert = ""
        tituloAlert = ""
        
        //Guardamos lo que hayamos introducido en las variables
        passActu = Utils.removerEspaciosBlanco(txtPassActual.text!)
        passNew = Utils.removerEspaciosBlanco(txtPassNew.text!)
        
        comprobarFormatos()
        
        if formatoCamposOk{
            cambiarPassword()
        }else{
            mostrarAlerta()
        }
    }
    
    func activarBotonGuardarCambios(){
        if(txtPassNew.text!.isEmpty || txtPassActual.text!.isEmpty){
            rightButton.isEnabled = false
        }else{
            rightButton.isEnabled = true
        }
    }
    
    func comprobarFormatos(){
        if(passActu.characters.count < 4 || passActu.characters.count > 25){
            (tituloAlert,mensajeAlert) = Utils.returnTitleAndMessageAlert("pass_actual")
            formatoCamposOk = false
        }else if(passNew.characters.count < 4 || passNew.characters.count > 25){
            (tituloAlert,mensajeAlert) = Utils.returnTitleAndMessageAlert("pass_nueva")
            formatoCamposOk = false
        }
    }
    
    func mostrarAlerta(){
        if(formatoCamposOk && !desLoguear){
            tituloAlert = "Cambios guardados"
            mensajeAlert = "Su información ha sido almacenada correctamente."
        }
        let alertError = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.alert)
        alertError.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausur
        if(desLoguear){
            desLoguear = false
            myTimerLeftMenu.invalidate()
            alertError.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { (action) -> Void in
                LogOut.desLoguearBorrarDatos()
                //self.navigationController?.popToRootViewControllerAnimated(false)
                self.presentingViewController!.dismiss(animated: true, completion: nil)
            }))
        }else{        //Añadimos un bonton al alert y lo que queramos que haga en la clausura
            if(formatoCamposOk){
                alertError.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { action in
                    self.txtPassActual.text = ""
                    self.txtPassNew.text = ""
                    self.rightButton.isEnabled = false
                }))
            }else{
                alertError.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { action in
                    self.txtPassActual.text = ""
                    self.txtPassNew.text = ""
                    self.rightButton.isEnabled = false
                }))
            }
        }
        //mostramos el alert
        self.present(alertError, animated: true) { () -> Void in
            self.tituloAlert = ""
            self.mensajeAlert = ""
        }
    }
    
    func addTap(){
        let tapRec = UITapGestureRecognizer()
        tapRec.addTarget(self, action: #selector(self.tappedTabla))
        miTablaPersonalizada.addGestureRecognizer(tapRec)
    }
    
    func tappedTabla(){
        self.view.endEditing(true)
    }
    
    func cambiarPassword(){
        let sessionKey = Utils.getSessionKey()
        let params = "action=update_password&session_key=\(sessionKey)&old_password=\(passActu)&new_password=\(passNew)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("access")
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let changePasswordTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                    let resultCode = json["result"] as? Int ??  0
                    if resultCode == 1{
                        self.formatoCamposOk = true
                        if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                            let lastUpdate = dataResultado["last_update"] as? String ?? ""
                            Utils.saveLastUpdate(lastUpdate)
                            self.mostrarAlerta()
                        }
                    }else{
                        self.formatoCamposOk = false
                        let codigoError = json["error_code"] as? String ?? ""
                        self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                        (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                        self.mostrarAlerta()
                    }
                }
            } catch{
                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                self.mostrarAlerta()
                
            }
        }
        changePasswordTask.resume()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}

extension ChangePasswordTableController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
