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
    
    func RedimensionarImagen(_ image: UIImage) -> UIImage? {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        
        var edgeX: CGFloat
        var edgeY: CGFloat
        edgeY = originalHeight
        edgeX = originalWidth
        
        let posX = (originalWidth  - edgeX) / 2.0
        let posY = (originalHeight - edgeY) / 2.0
        
        let cropSquare = CGRect(x: posX, y: posY, width: edgeX, height: edgeY)
        
        let imageRef = image.cgImage?.cropping(to: cropSquare);
        
        
        //Comprimimos la imagen para bajar el peso
        let imagenAux = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        let dataImage = UIImageJPEGRepresentation(imagenAux, 0.5)//Usamos un 0.5 de compresion
        let imagenFinal = UIImage(data: dataImage!)
        
        return imagenFinal
    }
    
    func RedimensionarImagenContamaño(_ image: UIImage?, targetSize: CGSize) -> UIImage? {
        if let image = image {
            let size = image.size
            
            let widthRatio  = targetSize.width  / image.size.width
            let heightRatio = targetSize.height / image.size.height
            
            // Comprobamos si es mas alto que ancho para el recuadro que usaremos
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }
            
            // Creamos el CGRect con los valores que obtuvimos antes
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //Comprimimos la imagen para bajar el peso
            let imagenAux = UIImage(cgImage: (newImage?.cgImage!)!, scale: image.scale, orientation: image.imageOrientation)
            let dataImage = UIImageJPEGRepresentation(imagenAux, 1)//Usamos un 0.5 de compresion
            let imagenFinal = UIImage(data: dataImage!)
            
            return imagenFinal
        } else {
            return nil
        }
    }
    
    func devolverTamaño(_ miImagen:UIImage) -> (Bool,CGSize?){
        var tamaño:CGSize?
        var reducir: Bool = false
        
        let anchoPantalla = UIScreen.main().bounds.size.width
        let largoPantalla = UIScreen.main().bounds.size.height
        
        let originalWidth  = miImagen.size.width
        let originalHeight = miImagen.size.height
    
        if originalWidth > originalHeight {
            if(originalWidth > anchoPantalla){
                reducir = true
                tamaño = CGSize(width: largoPantalla * 2, height: anchoPantalla * 2)
            }
        }else{
            if(originalHeight > largoPantalla){
                reducir = true
                tamaño = CGSize(width: anchoPantalla * 2, height: largoPantalla * 2)
            }
        }
        return (reducir ,tamaño)
    }
    
    //Funcion para decodificar una imagen a partir de un String
    static func decodificarImagen (_ dataImage:String) -> UIImage{
        if let decodedData = Data(base64Encoded: dataImage, options: .encodingEndLineWithCarriageReturn){
            if(decodedData.count > 0){
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
