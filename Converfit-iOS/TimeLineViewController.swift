//
//  TimeLineViewController.swift
//  Converfit-iOS
//
//  Created by Manuel Martinez Gomez on 14/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class TimeLineViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIWebViewDelegate {
    
    //MARK: - Variables
    private let reuseIdentifier = "timeLineCollectionCell"
    private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var listadoPost  = [TimeLineModel]()
    var mensajeAlert = ""
    var tituloAlert = ""
    let detailTimeLineSegue = "detailTimeLineSegue"
    var indiceSeleccionado = 0
    var desLoguear = false
    var activarCollectionViewUserInterface = true
    
    //MARK: - Outlets
    @IBOutlet weak var miCollectionView: UICollectionView!
    
    //MARK: - Actions
    
    @IBAction func tapButon(sender: AnyObject) {
        if(activarCollectionViewUserInterface){
            miCollectionView.userInteractionEnabled = false
        }else{
            miCollectionView.userInteractionEnabled = true
        }
        activarCollectionViewUserInterface = !activarCollectionViewUserInterface
        NSNotificationCenter.defaultCenter().postNotificationName(notificationToggleMenu, object: nil)
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Utils.customAppear(self)
        if(irPantallaLogin){
            irPantallaLogin = false
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }else{
            listadoPost = TimeLine.devolverListTimeLine()
            miCollectionView.reloadData()
            recuperarTimeLine()
             NSNotificationCenter.defaultCenter().addObserver(self, selector: "cambiarBadge", name:notificationChat, object: nil)
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: notificationChat, object: nil)
    }

    func cambiarBadge(){
        let tabArray =  self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabArray.objectAtIndex(2) as! UITabBarItem
        let numeroMensajesSinLeer = Conversation.numeroMensajesSinLeer()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if(numeroMensajesSinLeer > 0){
                tabItem.badgeValue = "\(numeroMensajesSinLeer)"
                UIApplication.sharedApplication().applicationIconBadgeNumber = numeroMensajesSinLeer
            }else{
                tabItem.badgeValue = nil
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
        })
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
        cell.avatarImage.layer.cornerRadius = cell.avatarImage.frame.height/2
        cell.avatarImage.clipsToBounds = true
        
        cell.userName.text = listadoPost[indexPath.row].userName
        let hora = Fechas.devolverTiempo(listadoPost[indexPath.row].created)
        cell.time.text = devolverHoraFormateada(hora)
        cell.html.loadHTMLString(listadoPost[indexPath.row].content, baseURL: nil)
        
        cell.html.scrollView.scrollEnabled = false
        cell.html.scrollView.bounces = false
        cell.html.delegate = self
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.view.frame.width
        let contenido = listadoPost[indexPath.row].content
        var height = CGFloat(130)
        let contenidoSize = contenido.characters.count
        if(contenido.containsString("<img")){
            height = 320
        }else if(contenidoSize < 50){
            height = 100
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        indiceSeleccionado = indexPath.row
        performSegueWithIdentifier(detailTimeLineSegue, sender: self)
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
                                    self.desLoguear = LogOut.comprobarDesloguear(codigoError)
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
        alert.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausur
        if(desLoguear){
            desLoguear = false
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler: { (action) -> Void in
                LogOut.desLoguearBorrarDatos()
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                })
            }))
        }else{
            //Añadimos un bonton al alert y lo que queramos que haga en la clausura
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler: { action in
            
            }))
        }
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
    
    //MARK: - Lanzar enlace del webView en safari
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if(navigationType == UIWebViewNavigationType.LinkClicked){
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        return true
    }
    
    //MARK: - PrepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == detailTimeLineSegue){
            let detailTimeLineVC = segue.destinationViewController as! DetailTimeLineUser
            detailTimeLineVC.titleUsuario = listadoPost[indiceSeleccionado].userName
            detailTimeLineVC.userKey = listadoPost[indiceSeleccionado].userKey
        }
    }
}
