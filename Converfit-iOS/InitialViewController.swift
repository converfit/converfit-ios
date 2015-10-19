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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let _ = defaults.stringForKey("session_key")
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
        let urlServidor = Utils.returnUrlWS("access")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let checkSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            /*guard data != nil else {
            print("no data found: \(error)")
            return
            }
            */
            if(data != nil){
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                        if let resultCode = json.objectForKey("result") as? Int{
                            if(resultCode == 1){
                                if let dataResultado = json.objectForKey("data") as? NSDictionary{
                                    if let lastUpdate = dataResultado.objectForKey("last_update") as? String{
                                        Utils.saveLastUpdate(lastUpdate)
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            self.mostrarPantallaInicio(true)
                                        })
                                    }else{
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            self.mostrarPantallaInicio(false)
                                        })
                                    }
                                }else{
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.mostrarPantallaInicio(false)
                                    })
                                }
                            }else{
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.mostrarPantallaInicio(false)
                                })
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.mostrarPantallaInicio(false)
                            })
                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.mostrarPantallaInicio(false)
                        })
                    }
                } catch{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.mostrarPantallaInicio(false)
                    })
                }
            }
        }
        checkSessionTask.resume()
    }

    func mostrarPantallaInicio(mostrarPantallaInicio:Bool){
        if(mostrarPantallaInicio){
            performSegueWithIdentifier(segueShowTabs, sender: self)
        }else{
            performSegueWithIdentifier(segueShowLogin, sender: self)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
