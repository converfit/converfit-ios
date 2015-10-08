//
//  PasswordMenuController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 7/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class PasswordMenuController: UIViewController {
    
    //MARK: - Variables
    let cellId = "CeldaPasswordMenu"
    
    //MARK: - Outlets
    @IBOutlet weak var miTablaPersonalizada: UITableView!
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        modificarUI()
    }    
    
    func modificarUI(){
        self.tabBarController?.tabBar.hidden = true
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
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
        if (cell == nil){
            //No teniamos ninguna celda y tenemos que crearla
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        //Como solo tendremos dos filas ponemos a cada uno el titulo que le corresponda
        if(indexPath.row == 0){
            textoCelda = "Cambiar contraseña"
        }else{
            textoCelda = "Recuperar contraseña"
        }
        cell?.textLabel?.text = textoCelda
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            //let destinationVC = self.storyboard?.instantiateViewControllerWithIdentifier("ChangePassword") as! ChangePasswordTableController
            //self.navigationController?.pushViewController(destinationVC, animated: true)
        }else{
            performSegueWithIdentifier("recuPassSegue", sender: self)
        }
    }
}
