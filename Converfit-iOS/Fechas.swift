//
//  Fechas.swift
//  Converfit-iOS
//
//  Created by Manuel Martinez Gomez on 9/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class Fechas {
    
    /*
    static func convertirFechaUnixToString(fechaUnixString:String) -> String{
        var resultado = ""
        
        //En esta parte extraemos la fecha del mensaje recibido a minuto, mes, dia, mes,año
        let doubleNSString = NSString(string: fechaUnixString)
        let timestampAsDouble = doubleNSString.doubleValue
        let fechaCompleta = NSDate(timeIntervalSince1970:timestampAsDouble)
        //Llamamos a la funcion para extraer los valores
        let (minutoMensaje,horaMensaje,diaMensaje,mesMensaje,yearMensaje) = extraerFechaEnMinutoHoraDiaMesYear(fechaCompleta)
        /////////////////
        
        //Aqui extraemos la fecha actual
        let fechaActual = NSDate()
        let (_,_,diaHoy,mesHoy,yearHoy) = extraerFechaEnMinutoHoraDiaMesYear(fechaActual)
        
        //Comparamos las fechas concatenando dia mes y año para ver si son el mismo dia
        if("\(diaMensaje)\(mesMensaje)\(yearMensaje)"=="\(diaHoy)\(mesHoy)\(yearHoy)"){
            if(minutoMensaje <= 9){
                resultado = "\(horaMensaje):0\(minutoMensaje)"
            }else{
                resultado = "\(horaMensaje):\(minutoMensaje)"
            }
        }else if(("\(mesMensaje)\(yearMensaje)"=="\(mesHoy)\(yearHoy)") && (diaHoy - diaMensaje == 1) ){
            resultado = "Ayer"
        }else{
            resultado = "\(diaMensaje)/\(mesMensaje)/\(yearMensaje)"
        }
        
        return resultado
    }
    
    static func extraerFechaEnMinutoHoraDiaMesYear(fecha:NSDate) -> (Int, Int, Int, Int, Int){
        let calendar = NSCalendar.currentCalendar()
        let componentsFechaRecibida = calendar.components([.Hour, .Minute, .Day, .Month, .Year], fromDate:  fecha)
        
        let minutoshoraMensaje = componentsFechaRecibida.minute
        let horaMensaje = componentsFechaRecibida.hour
        let diaMensaje = componentsFechaRecibida.day
        let mesMensaje = componentsFechaRecibida.month
        let yearMensaje = componentsFechaRecibida.year
        
        return (minutoshoraMensaje,horaMensaje,diaMensaje,mesMensaje,yearMensaje)
    }

*/
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
        if(fromNow < 1){
            return "Ahora"
        }else{
            var timeStamp_to_str = ""
            d = Int(fromNow)
            if(d >= 1){
                timeStamp_to_str += "\(d)"
                if(d > 1){
                    timeStamp_to_str += " seg"
                }else{
                    timeStamp_to_str += " seg"
                }
            }
            
            //Calculamos los minutos
            d = Int(fromNow / 60)
            if(d >= 1){
                timeStamp_to_str = ""
                timeStamp_to_str += "\(d)"
                if(d > 1){
                    timeStamp_to_str += " min"
                }else{
                    timeStamp_to_str += " min"
                }
            }
            
            //Calculamos las horas
            d = Int(fromNow / (60*60))
            if(d >= 1){
                timeStamp_to_str = ""
                timeStamp_to_str += "\(d)"
                if(d > 1){
                    timeStamp_to_str += " h"
                }else{
                    timeStamp_to_str += " h"
                }
            }
            
            //Calculamos los dias
            d = Int(fromNow / (24*60*60))
            if(d >= 1){
                timeStamp_to_str = ""
                timeStamp_to_str += "\(d)"
                if(d > 1){
                    timeStamp_to_str += " días"
                }else{
                    timeStamp_to_str = "Ayer"
                }
            }
            
            //Calculamos los meses
            d = Int(fromNow / (30*24*60*60))
            if(d >= 1){
                timeStamp_to_str = ""
                timeStamp_to_str += "\(d)"
                if(d > 1){
                    timeStamp_to_str += " meses"
                }else{
                    timeStamp_to_str += " mes"
                }
            }
            
            //Calculamos los años
            d = Int(fromNow / (365*24*60*60))
            if(d >= 1){
                timeStamp_to_str = ""
                timeStamp_to_str += "\(d)"
                if(d > 1){
                    timeStamp_to_str += " años"
                }else{
                    timeStamp_to_str += " año"
                }
            }
            
            return timeStamp_to_str
        }
    }
}
