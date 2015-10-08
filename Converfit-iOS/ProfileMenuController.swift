//
//  ProfileMenuController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 7/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class ProfileMenuController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Variables
    let cellId = "CeldaUserSettings"

    //MARK: - Outlets
    @IBOutlet weak var miTablaPersonalizada: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modificarUI()
    }

    //MARK: - Utils
    
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
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
        if (cell == nil){
            //No teniamos ninguna celda y tenemos que crearla
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        //Como solo tendremos dos filas ponemos a cada uno el titulo que le corresponda
        if(indexPath.row == 0){
            textoCelda = "Datos personales"
        }else{
            textoCelda = "Contraseña"
        }
        cell?.textLabel?.text = textoCelda
        return cell!
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            performSegueWithIdentifier("personalDataSegue", sender: self)
        }else{
            //let destinationVC = self.storyboard?.instantiateViewControllerWithIdentifier("PasswordMenu") as! PasswordMenuController
            //self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    //MARK: - Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "personalDataSegue"){
            
        }
    }
}
