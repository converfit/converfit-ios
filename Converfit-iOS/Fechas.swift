//
//  Fechas.swift
//  Converfit-iOS
//
//  Created by Manuel Martinez Gomez on 9/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class Fechas {
    static func fechaActualToString() -> (String){
        
        //Extraemos la fecha acutal
        let fecha = Date().timeIntervalSince1970
        
        return "\(fecha)"
    }
    
    static func devolverTiempo(_ fechaUnix: String) -> String{
        let unixTimeActual = Date().timeIntervalSince1970
        let doubleNSString = NSString(string: fechaUnix)
        let fechaUnixRecibida = doubleNSString.doubleValue
        let fromNow = unixTimeActual - fechaUnixRecibida
        var d = 0
        if fromNow < 1{
            return "Ahora"
        }else{
            var timeStamp_to_str = ""
            d = Int(fromNow)
            if d >= 1{
                timeStamp_to_str += "\(d)"
                if d > 1{
                    timeStamp_to_str += " seg"
                }else{
                    timeStamp_to_str += " seg"
                }
            }
            
            //Calculamos los minutos
            d = Int(fromNow / 60)
            if d >= 1{
                timeStamp_to_str = ""
                timeStamp_to_str += "\(d)"
                if d > 1{
                    timeStamp_to_str += " min"
                }else{
                    timeStamp_to_str += " min"
                }
            }
            
            //Calculamos las horas
            d = Int(fromNow / (60*60))
            if d >= 1{
                timeStamp_to_str = ""
                timeStamp_to_str += "\(d)"
                if d > 1{
                    timeStamp_to_str += " h"
                }else{
                    timeStamp_to_str += " h"
                }
            }
            
            //Calculamos los dias
            d = Int(fromNow / (24*60*60))
            if d >= 1{
                timeStamp_to_str = ""
                timeStamp_to_str += "\(d)"
                if d > 1{
                    timeStamp_to_str += " días"
                }else{
                    timeStamp_to_str = "Ayer"
                }
            }
            
            //Calculamos los meses
            d = Int(fromNow / (30*24*60*60))
            if d >= 1{
                timeStamp_to_str = ""
                timeStamp_to_str += "\(d)"
                if d > 1{
                    timeStamp_to_str += " meses"
                }else{
                    timeStamp_to_str += " mes"
                }
            }
            
            //Calculamos los años
            d = Int(fromNow / (365*24*60*60))
            if d >= 1{
                timeStamp_to_str = ""
                timeStamp_to_str += "\(d)"
                if d > 1{
                    timeStamp_to_str += " años"
                }else{
                    timeStamp_to_str += " año"
                }
            }
            
            return timeStamp_to_str
        }
    }
}
