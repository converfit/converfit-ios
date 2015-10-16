//
//  LefMenuWiewController.swift
//  Converfit-iOS
//
//  Created by Manuel Citious on 16/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class LefMenuWiewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var miTablaPersonalizada: UITableView!
    @IBOutlet weak var lblEstadoChat: UILabel!
    
    //MARK: - Actions
    @IBAction func tapQuickOptions(sender: AnyObject) {
        let status = Utils.getStatusLeftMenu()
        if(status == "0"){
            showAlertSheet("Activar chat")
        }else{
            showAlertSheet("Desactivar chat")
        }
        
    }
    
    //MARK: - LifeCycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        modificarUI()
        checkStatusleftMenu()
    }
    
    //MARK: - Utils
    func modificarUI(){
        miTablaPersonalizada.tableFooterView = UIView()
        miTablaPersonalizada.backgroundColor = UIColor.clearColor()
    }
    
    //MARK: - Check status left menu
    func checkStatusleftMenu(){
        let status = Utils.getStatusLeftMenu()
        if(status == "0"){
            lblEstadoChat.text = "CHAT DESACTIVADO"
        }else{
            lblEstadoChat.text = "CHAT ACTIVADO"
        }
    }
    
    //MARK: - Show alertSheet
    func showAlertSheet(titleAction:String){
        let alertSheetMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertSheetMenu.addAction(UIAlertAction(title: titleAction, style: .Default, handler: { (action) -> Void in
            if(titleAction == "Activar chat"){
                self.enableOrDisableChat("1")
            }else{
                self.enableOrDisableChat("0")
            }
        }))
        
        alertSheetMenu.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: { (action) -> Void in
            
        }))
        self.presentViewController(alertSheetMenu, animated: true, completion: nil)
    }
    
    //MARK: - Enable or disable Chat
    func enableOrDisableChat(enableString:String){
        let sessionKey = Utils.getSessionKey()
        let params = "action=update_brand_webchat_status&session_key=\(sessionKey)&webchat_status=\(enableString)"
        let urlServidor = Utils.returnUrlWS("webchat")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let enableTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                dbErrorContador = 0
                                Utils.saveStatusLeftMenu(enableString)
                                self.checkStatusleftMenu()
                            })
                        }else{
                            //MostrarAlerta error
                        }
                    }
                }
            } catch{
                
            }
        }
        enableTask.resume()
    }
    
    /*
    func mostrarAlerta(){
        self.view.endEditing(true)
        let alert = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.Alert)
        alert.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausur
        if(desLoguear){
            desLoguear = false
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler: { (action) -> Void in
                LogOut.desLoguearBorrarDatos()
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                })
            }))
        }else{
            //Añadimos un bonton al alert y lo que queramos que haga en la clausur
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler:nil))
        }
        //mostramos el alert
        self.navigationController?.presentViewController(alert, animated: true) { () -> Void in
            self.tituloAlert = ""
            self.mensajeAlert = ""
        }
    }*/
}
