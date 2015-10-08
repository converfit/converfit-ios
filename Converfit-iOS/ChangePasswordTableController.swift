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
    @IBAction func btnPassActu(sender: AnyObject) {
        activarBotonGuardarCambios()
    }
    @IBAction func btnPassNew(sender: AnyObject) {
        activarBotonGuardarCambios()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modificarUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addTap()
    }
    
    func modificarUI(){
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        crearBotonesBarraNavegacion()
    }
    
    //Creamos los botones de la barra de navegacion
    func crearBotonesBarraNavegacion(){
        rightButton.title = "Guardar Cambios"
        rightButton.style = .Plain
        rightButton.target = self
        rightButton.enabled = false
        rightButton.action = "updatePass"
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
        
        if(formatoCamposOk){
            cambiarPassword()
        }else{
            mostrarAlerta()
        }
    }
    
    func activarBotonGuardarCambios(){
        if(txtPassNew.text!.isEmpty || txtPassActual.text!.isEmpty){
            rightButton.enabled = false
        }else{
            rightButton.enabled = true
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
        let alertError = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.Alert)
        alertError.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausura
        if(formatoCamposOk){
            alertError.addAction(UIAlertAction(title: "Aceptar", style: .Default, handler: { action in
                    self.txtPassActual.text = ""
                    self.txtPassNew.text = ""
                    self.rightButton.enabled = false
                }))
            }else{
                alertError.addAction(UIAlertAction(title: "Aceptar", style: .Default, handler: { action in
                    self.txtPassActual.text = ""
                    self.txtPassNew.text = ""
                    self.rightButton.enabled = false
                }))
        }
        //mostramos el alert
        self.presentViewController(alertError, animated: true) { () -> Void in
            self.tituloAlert = ""
            self.mensajeAlert = ""
        }
    }
    
    func addTap(){
        let tapRec = UITapGestureRecognizer()
        tapRec.addTarget(self, action: "tappedTabla")
        miTablaPersonalizada.addGestureRecognizer(tapRec)
    }
    
    func tappedTabla(){
        self.view.endEditing(true)
    }
    
    func cambiarPassword(){
        let sessionKey = Utils.getSessionKey()
        let params = "action=update_password&session_key=\(sessionKey)&old_password=\(passActu)&new_password=\(passNew)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("access")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let changePasswordTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            self.formatoCamposOk = true
                            if let dataResultado = json.objectForKey("data") as? NSDictionary{
                                if let lastUpdate = dataResultado.objectForKey("last_update") as? String{
                                    Utils.saveLastUpdate(lastUpdate)
                                    self.mostrarAlerta()
                                }
                            }
                        }else{
                            self.formatoCamposOk = false
                            if let codigoError = json.objectForKey("error_code") as? String{
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
        changePasswordTask.resume()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
}

extension ChangePasswordTableController:UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
