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

    //MARK: - Outlets
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var apellidos: UITextField!
    @IBOutlet var miTablaPersonalizada: UITableView!
    
    //MARK: - Actions
    @IBAction func btnCambioNombre(sender: AnyObject) {
        activarBotonGuardarCambios()
    }
    @IBAction func btnCambioApellidos(sender: AnyObject) {
        activarBotonGuardarCambios()
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        modificarUI()
    }
    
    //MARK: - Utils
    func modificarUI(){
        self.tabBarController?.tabBar.hidden = true
        //Creamos un footer con un UIView para eliminar los separator extras
        miTablaPersonalizada.tableFooterView = UIView()
        crearBotonesBarraNavegacion()
        addTap()
    }
    
    //Creamos los botones de la barra de navegacion
    func crearBotonesBarraNavegacion(){
        rightButton.title = "Guardar Cambios"
        rightButton.style = .Plain
        rightButton.target = self
        rightButton.enabled = false
        rightButton.action = "updatePersonalData"
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
        if(formatoCamposOk){
            updateData()
        }else{
            mostrarAlerta()
        }
    }

    func activarBotonGuardarCambios(){
        if(nombre.text!.isEmpty || apellidos.text!.isEmpty){
            rightButton.enabled = false
        }else{
            rightButton.enabled = true
        }
    }
    
    func comprobarFormatos(){
        if(nombre.text!.characters.count < 3 || nombre.text!.characters.count > 50){
            (tituloAlert,mensajeAlert) = Utils.returnTitleAndMessageAlert("formato_nombre")
            formatoCamposOk = false
        }else if(apellidos.text!.characters.count < 3                      || apellidos.text!.characters.count > 50){
            (tituloAlert,mensajeAlert) = Utils.returnTitleAndMessageAlert("formato_apellidos")
            formatoCamposOk = false
        }
    }
    
    func mostrarAlerta(){
        if(formatoCamposOk){
            tituloAlert = "Cambios guardados"
            mensajeAlert = "Su información ha sido almacenada correctamente."
        }
        let alertError = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.Alert)
        alertError.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        alertError.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler:{ action in
                    
        }))
        
        self.presentViewController(alertError, animated: true, completion: nil)
        
    }
    
    //Añadir un UITapGestureRecognizer para ocultar el teclado al pulsar sobre la tabla
    func addTap(){
        let tapRec = UITapGestureRecognizer()
        tapRec.addTarget(self, action: "tappedTabla")
        miTablaPersonalizada.addGestureRecognizer(tapRec)
    }
    
    func tappedTabla(){
        self.view.endEditing(true)
    }
        
    func updateData(){
        let sessionKey = Utils.getSessionKey()
        let params = "action=update_personal_data&session_key=\(sessionKey)&fname=\(nombreTexto)&lname=\(apellidosTexto)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("access")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let updateTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
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
        updateTask.resume()

    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
}

//MARK: - UITextFieldDelegate
extension PersonalDataTablaController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
