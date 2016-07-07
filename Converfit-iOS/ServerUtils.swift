//
//  ServerUtils.swift
//  Empremize-IOs
//
//  Created by Manuel Citious on 4/7/16.
//  Copyright © 2016 Citious Team. All rights reserved.
//

import Foundation

struct ServerUtils {
    
    static func getAsyncResponse(method: String, url: URL, params: String, completionBlock: (error: String, json: Dictionary<String, AnyObject>) -> Void){
        
        var request = URLRequest(url: url)
        let session = URLSession.shared
        request.httpMethod = method
        if method != HTTPMethods.GET.rawValue{
            request.httpBody = params.data(using: String.Encoding.utf8)
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            do{
                if let mJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionBlock(error: TypeOfError.NOERROR.rawValue, json: mJson)
                    })
                }else{
                    let mJson = Dictionary<String, AnyObject>()
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionBlock(error: TypeOfError.DEFAUTL.rawValue, json: mJson)
                    })
                }
            }catch let error as NSError{
                print("Error al obtener el listado de archivos")
                print(error.localizedDescription)
                let mJson = Dictionary<String, AnyObject>()
                DispatchQueue.main.async(execute: { () -> Void in
                    completionBlock(error: TypeOfError.DEFAUTL.rawValue, json: mJson)
                })
            }
        }
        task.resume()
    }
}


//Enum with types of HTTP methods
enum HTTPMethods: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}
