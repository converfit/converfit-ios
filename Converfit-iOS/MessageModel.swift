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
            let tamaño = CGSize(width: 400, height: 400)
            miniImagen = ResizeImage().RedimensionarImagenContamaño(imagenGrande, targetSize: tamaño)
        }else if(type == "mp4_base64"){
            if(!content.isEmpty){
                if let videoData = decodificarVideoBase64(content){
                    if(videoData.count > 0){
                        let filePath = applicationDocumentsDirectory().appendingPathComponent("\(messageKey).mp4")
                        _=try? videoData.write(to: URL(fileURLWithPath: filePath), options: [.dataWritingAtomic])
                        let url = URL(fileURLWithPath: filePath)
                        let imagenThumnail = generateThumnail(url)
                        let tamaño = CGSize(width: 400, height: 400)
                        miniImagen = ResizeImage().RedimensionarImagenContamaño(imagenThumnail, targetSize: tamaño)
                    }
                }
            }
        }
    }
    
   //Inicializador con los datos que obtenemos de CoreData
    convenience init(aDict:Dictionary<String, AnyObject>){
        self.init()
        messageKey =  aDict["message_key"] as? String ?? ""
        conversationKey = aDict["converstation_key"] as? String ?? ""
        sender = aDict["sender"] as? String ?? ""
        created = aDict["created"] as? String ?? ""
        content = aDict["content"] as? String ?? ""
        type = aDict["type"] as? String ?? ""
        let anEnviado = aDict["enviado"] as? String ?? ""
        enviado = (anEnviado == "true") ? "true" : "false"
        fname = aDict["fname"] as? String ?? ""
        lname = aDict["lname"] as? String ?? ""
        
        if type == "jpeg_base64"{
            let imagenGrande = ResizeImage.decodificarImagen(content)
            let tamaño = CGSize(width: 400, height: 400)
            miniImagen = ResizeImage().RedimensionarImagenContamaño(imagenGrande, targetSize: tamaño)
        }else if type == "mp4_base64"{
            if !content.isEmpty{
                if let videoData = decodificarVideoBase64(content){
                    if videoData.count > 0{
                        let filePath = applicationDocumentsDirectory().appendingPathComponent("\(messageKey).mp4")
                        _=try? videoData.write(to: URL(fileURLWithPath: filePath), options: [.dataWritingAtomic])
                        let url = URL(fileURLWithPath: filePath)
                        let imagenThumnail = generateThumnail(url)
                        let tamaño = CGSize(width: 400, height: 400)
                        miniImagen = ResizeImage().RedimensionarImagenContamaño(imagenThumnail, targetSize: tamaño)
                    }
                }
            }
        }
    }
    
    func generateThumnail(_ url : URL) -> UIImage?{
        //let asset : AVAsset = AVAsset.assetWithURL(url)
        let asset: AVAsset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time        : CMTime = CMTimeMake(1, 30)
        let img         : CGImage
        do {
            try img = assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let frameImg: UIImage = UIImage(cgImage: img)
            return frameImg
        } catch {
            
        }
        return nil
    }
    
    func applicationDocumentsDirectory() -> NSString {//En esta funcion obtenemos la ruta temporal donde guardar nuestro archivo
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    }
    
    func decodificarVideoBase64(_ videoString:String) -> Data?{
        return Data(base64Encoded: videoString, options: .encodingEndLineWithCarriageReturn)
    }
}
