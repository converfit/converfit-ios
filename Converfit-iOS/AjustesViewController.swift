//
//  AjustesViewController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 1/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class AjustesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Variables
    let cellId = "CeldaUserSettings"

    //MARK: - Outlets
    @IBOutlet weak var miTablaPersonalizada: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modificarUI()
    }
    
    override func viewWillAppear(animated: Bool) {
       super.viewWillAppear(animated)
        vieneDeListadoMensajes = false
        Utils.customAppear(self)
    }
    
    func modificarUI(){
        miTablaPersonalizada.backgroundColor = UIColor.clearColor()
        //Creamos un footer con un UIView para eliminar los separator extras
        miTablaPersonalizada.tableFooterView = UIView()
    }
    
    //UITableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var textoCelda = ""
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
        //Como solo tendremos dos filas ponemos a cada uno el titulo que le corresponda
        if(indexPath.row == 0){
            textoCelda = "Perfil"
        }else{
            textoCelda = "Cerrar sesión"
        }
        cell.textLabel?.text = textoCelda
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            self.performSegueWithIdentifier("showPerfil", sender: self)
        }else{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                LogOut.desLoguearBorrarDatos(self)
                ocultarLogIn = false
                //self.dismissViewControllerAnimated(true, completion: nil)
            })
            LogOut.desLoguear()
        }
    }
}
