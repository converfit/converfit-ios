//
//  InitialViewController.swift
//  Citious-IOs
//
//  Created by Manuel Citious on 19/10/15.
//  Copyright © 2015 Citious Team. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    //MARK:- Variables
    var erroAppDelegar = false
    let segueShowTabs = "segueShowTabs"
    let segueShowLogin = "segueShowLogin"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = UserDefaults.standard()
        
        if let _ = defaults.string(forKey: "session_key")
        {
            enviarDatosServidor()
        }else{
            mostrarPantallaInicio(false)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func enviarDatosServidor(){
        let sessionKey = Utils.getSessionKey()
        let lastUpdate = Utils.getLastUpdate()
        let deviceKey = Utils.getDeviceKey()
        let params = "action=check_session&session_key=\(sessionKey)&device_key=\(deviceKey)&last_update=\(lastUpdate)&system=\(sistema)&app_version=\(appVersion)&app=\(app)"
        let serverString = Utils.returnUrlWS("access")
        if let url = URL(string: serverString){
            ServerUtils.getAsyncResponse(method: HTTPMethods.POST.rawValue, url: url, params: params, completionBlock: { (error, json) in
                if error != TypeOfError.NOERROR.rawValue{
                    self.mostrarPantallaInicio(false)
                }else{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                            let lastUpdate = dataResultado["last_update"] as? String ?? ""
                            Utils.saveLastUpdate(lastUpdate)
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.mostrarPantallaInicio(true)
                            })
                        }else{
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.mostrarPantallaInicio(false)
                            })
                        }
                    }else{
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.mostrarPantallaInicio(false)
                        })
                    }
                }
            })
        }else{
            DispatchQueue.main.async(execute: { () -> Void in
                self.mostrarPantallaInicio(false)
            })
        }
    }

    func mostrarPantallaInicio(_ mostrarPantallaInicio:Bool){
        if mostrarPantallaInicio{
            performSegue(withIdentifier: segueShowTabs, sender: self)
        }else{
            performSegue(withIdentifier: segueShowLogin, sender: self)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
}
