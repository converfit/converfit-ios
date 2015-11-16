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
    let segueShowMessagesTimeLine = "segueShowMessagesTimeLine"
    var indiceSeleccionado = 0
    var desLoguear = false
    var activarCollectionViewUserInterface = true
    var myTimer = NSTimer.init()
    
    //MARK: - Outlets
    @IBOutlet weak var miCollectionView: UICollectionView!
    @IBOutlet weak var caritaTristeView: UIView!
    @IBOutlet weak var openManualLbl: UIView!
    @IBOutlet weak var manualTextLbl: UILabel!
    
    //MARK: - Actions
    
    @IBAction func tapButon(sender: AnyObject) {
        enableUserInterface()
        NSNotificationCenter.defaultCenter().postNotificationName(notificationToggleMenu, object: nil)
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        myTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "recargarTimeLine", userInfo: nil, repeats: true)
        Utils.customAppear(self)
        customizeopenManualTextLbl()
        addManualTap()
        if(irPantallaLogin){
            irPantallaLogin = false
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }else{
            if(vieneDeListadoMensajes){
                self.tabBarController?.selectedIndex = 2
                vieneDeListadoMensajes = false
            }else{
                listadoPost = TimeLine.devolverListTimeLine()
                miCollectionView.reloadData()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "cambiarBadge", name:notificationChat, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemMenuSelected", name:notificationItemMenuSelected , object: nil)
                miCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
            }
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: notificationChat, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: notificationItemMenuSelected, object: nil)
        myTimer.invalidate()
    }

    //MARK: - Notification Oberser cuando clickamos en el menuLateral
    func itemMenuSelected(){
        enableUserInterface()
        performSegueWithIdentifier(segueShowMessagesTimeLine, sender: self)
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
    
    //MARK: - Enable or disable userInterface in collectionView
    func enableUserInterface(){
        if(activarCollectionViewUserInterface){
            miCollectionView.userInteractionEnabled = false
        }else{
            miCollectionView.userInteractionEnabled = true
        }
        activarCollectionViewUserInterface = !activarCollectionViewUserInterface
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
        
        //cell.html.scrollView.scrollEnabled = false
        //cell.html.scrollView.bounces = false
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
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.caritaTristeView.alpha = 0
                                self.openManualLbl.userInteractionEnabled = false
                            })
                            if let data = json.objectForKey("data") as? NSDictionary{
                                if let brandNotiLastUp = data.objectForKey("brand_notifications_last_update") as? String{
                                    Utils.saveLastUpdateBrandsNotifications(brandNotiLastUp)
                                }
                                if let needUpdate = data.objectForKey("need_to_update") as? Bool{
                                    if(needUpdate){
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
                                        })
                                    }
                                }
                            }
                        }else{
                            if let codigoError = json.objectForKey("error_code") as? String{
                                if(codigoError != "brand_activities_empty"){
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                                        (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                        self.mostrarAlerta()
                                    })
                                }else{
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.caritaTristeView.alpha = 1
                                        self.openManualLbl.userInteractionEnabled = true
                                    })
                                }
                            }

                        }
                    }
                }
            } catch{
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.caritaTristeView.alpha = 0
                    self.openManualLbl.userInteractionEnabled = false
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
            myTimerLeftMenu.invalidate()
            myTimer.invalidate()
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
        }else if(unixTimeString.containsString("h") && unixTimeString != "Ahora"){
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
        }else if(segue.identifier == segueShowMessagesTimeLine){
            let messagesVC = segue.destinationViewController as! AddConversacionController
            let (userHasConversation, conversationKey) = Conversation.existeConversacionDeUsuario(userKeyMenuSeleccionado)
            if(userHasConversation){
                messagesVC.conversacionNueva = false
                messagesVC.conversationKey = conversationKey
                
            }else{
                messagesVC.conversacionNueva = true
            }
            messagesVC.userKey = userKeyMenuSeleccionado
            messagesVC.userName = User.obtenerUser(userKeyMenuSeleccionado)?.userName
        }
    }
    
    //MARK: - Timer RecargarTimeLine
    func recargarTimeLine(){
        recuperarTimeLine()
    }
    
    //MARK: - addManualTap
    func addManualTap(){
        let tapManualLabel =  UITapGestureRecognizer()
        tapManualLabel.addTarget(self, action: "tappedManual")
        openManualLbl.addGestureRecognizer(tapManualLabel)
    }
    
    func tappedManual(){
        if let requestUrl = NSURL(string: "http://www.converfit.com/app/es/signup/index.html") {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    //MARK : - openManualLbl customize
    func customizeopenManualTextLbl(){
        let manualText = "No podemos mostrarte la información de tu web. Comprueba que has integrado el código correctamente para acceder a los datos de tus usuarios. Para mas información consulta nuestro manual de integración."
        let myMutableString = NSMutableAttributedString(string: manualText)
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: NSRange(location:manualText.characters.count - 22 , length: 22))
        manualTextLbl.attributedText = myMutableString
    }
}
