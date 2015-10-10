//
//  MessageModel.swift
//  Citious-IOs
//
//  Created by Manuel Citious on 20/5/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit
import AVFoundation

class MessageModel {
    var content = ""
    var conversationKey = ""
    var created = ""
    var enviado = ""
    var fname = ""
    var lname = ""
    var messageKey = ""
    var sender = ""
    var type = ""
    var miniImagen:UIImage?
    
    //Inicializador con los datos que obtenemos de CoreData
    convenience init(modelo:Messsage){
        self.init()
        messageKey = modelo.messageKey
        conversationKey = modelo.conversationKey
        sender = modelo.sender
        created = modelo.created
        content = modelo.content
        type = modelo.type
        enviado = modelo.enviado
        fname = modelo.fname
        lname = modelo.lname
        
        if(type == "jpeg_base64"){
            let imagenGrande = ResizeImage.decodificarImagen(content)
            let tamaño = CGSizeMake(400, 400)
            miniImagen = ResizeImage().RedimensionarImagenContamaño(imagenGrande, targetSize: tamaño)
        }else if(type == "mp4_base64"){
            if(!content.isEmpty){
                if let videoData = decodificarVideoBase64(content){
                    if(videoData.length > 0){
                        let filePath = applicationDocumentsDirectory().stringByAppendingPathComponent("\(messageKey).mp4")
                        videoData.writeToFile(filePath, atomically: true)
                        let url = NSURL(fileURLWithPath: filePath)
                        let imagenThumnail = generateThumnail(url)
                        let tamaño = CGSizeMake(400, 400)
                        miniImagen = ResizeImage().RedimensionarImagenContamaño(imagenThumnail, targetSize: tamaño)
                    }
                }
            }
        }
    }
    
   //Inicializador con los datos que obtenemos de CoreData
    convenience init(aDict:NSDictionary){
        self.init()
        messageKey =  aDict.objectForKey("message_key") as! String
        conversationKey = aDict.objectForKey("converstation_key") as! String
        sender = aDict.objectForKey("sender") as! String
        created = aDict.objectForKey("created") as! String
        content = aDict.objectForKey("content") as! String
        type = aDict.objectForKey("type") as! String
        enviado = aDict.objectForKey("enviado") as! String
        fname = aDict.objectForKey("fname") as! String
        lname = aDict.objectForKey("lname") as! String
        
        if(type == "jpeg_base64"){
            let imagenGrande = ResizeImage.decodificarImagen(content)
            let tamaño = CGSizeMake(400, 400)
            miniImagen = ResizeImage().RedimensionarImagenContamaño(imagenGrande, targetSize: tamaño)
        }else if(type == "mp4_base64"){
            if(!content.isEmpty){
                if let videoData = decodificarVideoBase64(content){
                    if(videoData.length > 0){
                        let filePath = applicationDocumentsDirectory().stringByAppendingPathComponent("\(messageKey).mp4")
                        videoData.writeToFile(filePath, atomically: true)
                        let url = NSURL(fileURLWithPath: filePath)
                        let imagenThumnail = generateThumnail(url)
                        let tamaño = CGSizeMake(400, 400)
                        miniImagen = ResizeImage().RedimensionarImagenContamaño(imagenThumnail, targetSize: tamaño)
                    }
                }
            }
        }
    }
    
    func generateThumnail(url : NSURL) -> UIImage{
        //let asset : AVAsset = AVAsset.assetWithURL(url)
        let asset: AVAsset = AVAsset(URL: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time        : CMTime = CMTimeMake(1, 30)
        let img         : CGImageRef
        do {
            try img = assetImgGenerate.copyCGImageAtTime(time, actualTime: nil)
            let frameImg: UIImage = UIImage(CGImage: img)
            return frameImg
        } catch {
            
        }
        return nil
    }
    
    func applicationDocumentsDirectory() -> NSString {//En esta funcion obtenemos la ruta temporal donde guardar nuestro archivo
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    }
    
    func decodificarVideoBase64(videoString:String) -> NSData?{
        return NSData(base64EncodedString: videoString, options:NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
    }
}
