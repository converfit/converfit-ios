//
//  TimeLineViewController.swift
//  Converfit-iOS
//
//  Created by Manuel Martinez Gomez on 14/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class TimeLineViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //MARK: - Variables
    private let reuseIdentifier = "timeLineCollectionCell"
    private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var listadoPost  = [TimeLineModel]()
    var mensajeAlert = ""
    var tituloAlert = ""
    
    //MARK: - Outlets
    @IBOutlet weak var miCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        listadoPost = TimeLine.devolverListTimeLine()
        miCollectionView.reloadData()
        recuperarTimeLine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - CollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listadoPost.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TimeLineCollectionViewCell
        
        cell.avatarImage.image = listadoPost[indexPath.row].avatar
        cell.userName.text = listadoPost[indexPath.row].userName
        let hora = Fechas.devolverTiempo(listadoPost[indexPath.row].created)
        cell.time.text = devolverHoraFormateada(hora)
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.view.frame.width
        return CGSize(width: width, height: 156)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    //MARK: - Servidor
    func recuperarTimeLine(){
        let sessionKey = Utils.getSessionKey()
        let brandsNotificationsLastUpdate = Utils.getLastUpdateBrandsNotifications()
        let params = "action=list_brand_notifications&session_key=\(sessionKey)&brand_notifications_last_update=\(brandsNotificationsLastUpdate)&offset=\(0)&limit=\(1000)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("brand_notifications")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let recuperarTimeLineTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            if let data = json.objectForKey("data") as? NSDictionary{
                                if let brandNotiLastUp = data.objectForKey("brand_notifications_last_update") as? String{
                                    Utils.saveLastUpdateBrandsNotifications(brandNotiLastUp)
                                }
                                if let needUpdate = data.objectForKey("need_to_update") as? Bool{
                                    if(needUpdate){
                                        TimeLine.borrarAllPost()
                                        if let listPost = data.objectForKey("brand_notifications") as? [NSDictionary]{
                                            for post in listPost{
                                                _=TimeLine(aDict: post)
                                            }
                                            self.listadoPost = TimeLine.devolverListTimeLine()
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                self.miCollectionView.reloadData()
                                            })
                                        }
                                    }
                                }
                            }
                        }else{
                            if let codigoError = json.objectForKey("error_code") as? String{
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                    self.mostrarAlerta()
                                })
                            }

                        }
                    }
                }
            } catch{
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert("error")
                    self.mostrarAlerta()
                })

            }
        }
        recuperarTimeLineTask.resume()
    }
    
    //MARK: - MostrarAlerta
    func mostrarAlerta(){
        self.view.endEditing(true)
        let alert = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.Alert)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausura
        alert.addAction(UIAlertAction(title: "Aceptar", style: .Default, handler: { action in
            
        }))
        //mostramos el alert
        self.presentViewController(alert, animated: true) { () -> Void in
            self.tituloAlert = ""
            self.mensajeAlert = ""
        }
    }

    //Hora Formateada
    func devolverHoraFormateada(unixTimeString:String) -> String{
        var fechaFormateada = ""
        if(unixTimeString.containsString("seg")){
            var cadena = "segundos"
            if(unixTimeString == "1 seg"){
                cadena = "segundo"
            }
            fechaFormateada = unixTimeString.stringByReplacingOccurrencesOfString("seg", withString: cadena, options: [], range: nil)
        }else if(unixTimeString.containsString("min")){
            var cadena = "minutos"
            if(unixTimeString == "1 min"){
                cadena = "minuto"
            }
            fechaFormateada = unixTimeString.stringByReplacingOccurrencesOfString("min", withString: cadena, options: [], range: nil)
        }else if(unixTimeString.containsString("h")){
            var cadena = "horas"
            if(unixTimeString == "1 h"){
                cadena = "hora"
            }
            fechaFormateada = unixTimeString.stringByReplacingOccurrencesOfString("h", withString: cadena, options: [], range: nil)
        }else{
            fechaFormateada = unixTimeString
        }
        return fechaFormateada
    }
}
