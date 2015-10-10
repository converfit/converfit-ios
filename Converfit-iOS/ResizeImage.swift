//
//  ResizeImage.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 22/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class ResizeImage {
    
    //Funciones para redimensionar la foto
    
    func RedimensionarImagen(image: UIImage) -> UIImage? {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        
        var edgeX: CGFloat
        var edgeY: CGFloat
        edgeY = originalHeight
        edgeX = originalWidth
        
        let posX = (originalWidth  - edgeX) / 2.0
        let posY = (originalHeight - edgeY) / 2.0
        
        let cropSquare = CGRectMake(posX, posY, edgeX, edgeY)
        
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        
        
        //Comprimimos la imagen para bajar el peso
        let imagenAux = UIImage(CGImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        let dataImage = UIImageJPEGRepresentation(imagenAux, 0.5)//Usamos un 0.5 de compresion
        let imagenFinal = UIImage(data: dataImage!)
        
        return imagenFinal
    }
    
    func RedimensionarImagenContamaño(image: UIImage?, targetSize: CGSize) -> UIImage? {
        if let image = image {
            let size = image.size
            
            let widthRatio  = targetSize.width  / image.size.width
            let heightRatio = targetSize.height / image.size.height
            
            // Comprobamos si es mas alto que ancho para el recuadro que usaremos
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
            } else {
                newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
            }
            
            // Creamos el CGRect con los valores que obtuvimos antes
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //Comprimimos la imagen para bajar el peso
            let imagenAux = UIImage(CGImage: newImage.CGImage!, scale: image.scale, orientation: image.imageOrientation)
            let dataImage = UIImageJPEGRepresentation(imagenAux, 1)//Usamos un 0.5 de compresion
            let imagenFinal = UIImage(data: dataImage!)
            
            return imagenFinal
        } else {
            return nil
        }
    }
    
    func devolverTamaño(miImagen:UIImage) -> (Bool,CGSize?){
        var tamaño:CGSize?
        var reducir: Bool = false
        
        let anchoPantalla = UIScreen.mainScreen().bounds.size.width
        let largoPantalla = UIScreen.mainScreen().bounds.size.height
        
        let originalWidth  = miImagen.size.width
        let originalHeight = miImagen.size.height
    
        if originalWidth > originalHeight {
            if(originalWidth > anchoPantalla){
                reducir = true
                tamaño = CGSizeMake(largoPantalla * 2, anchoPantalla * 2)
            }
        }else{
            if(originalHeight > largoPantalla){
                reducir = true
                tamaño = CGSizeMake(anchoPantalla * 2, largoPantalla * 2)
            }
        }
        return (reducir ,tamaño)
    }
    
    //Funcion para decodificar una imagen a partir de un String
    static func decodificarImagen (dataImage:String) -> UIImage{
        if let decodedData = NSData(base64EncodedString: dataImage, options:NSDataBase64DecodingOptions.IgnoreUnknownCharacters){
            if(decodedData.length > 0){
                return UIImage(data: decodedData)!
            }
            else{
                return UIImage(named: "NoImage")!
            }
        }
        else{
            return UIImage(named: "NoImage")!
        }
        
    }
}
