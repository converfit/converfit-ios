//
//  LogOut.swift
//  Converfit-iOS
//
//  Created by Manuel Martinez Gomez on 8/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class LogOut {

    static func desLoguear(){
        let sessionKey = Utils.getSessionKey()
        let params = "action=logout&session_key=\(sessionKey)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("access")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let logOutTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                guard data != nil else {
                    print("no data found: \(error)")
                    return
                }
                
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                        if let resultCode = json.objectForKey("result") as? Int{
                            if(resultCode == 1){
                            //LogOutCorrecto
                            }
                        }
                    }
                } catch{
                    
                }
            }
            logOutTask.resume()
        }
}
