//
//  Fechas.swift
//  Converfit-iOS
//
//  Created by Manuel Martinez Gomez on 9/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class Fechas {
    
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

}
