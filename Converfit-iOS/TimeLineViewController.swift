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
    var myTimer = Timer.init()
    
    //MARK: - Outlets
    @IBOutlet weak var miCollectionView: UICollectionView!
    @IBOutlet weak var caritaTristeView: UIView!
    @IBOutlet weak var openManualLbl: UIView!
    @IBOutlet weak var manualTextLbl: UILabel!
    
    //MARK: - Actions
    
    @IBAction func tapButon(_ sender: AnyObject) {
        enableUserInterface()
        NotificationCenter.default().post(name: Notification.Name(rawValue: notificationToggleMenu), object: nil)
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.recargarTimeLine), userInfo: nil, repeats: true)
        Utils.customAppear(self)
        customizeopenManualTextLbl()
        addManualTap()
        if(irPantallaLogin){
            irPantallaLogin = false
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
        }else{
            if(vieneDeListadoMensajes){
                self.tabBarController?.selectedIndex = 2
                vieneDeListadoMensajes = false
            }else{
                listadoPost = TimeLine.devolverListTimeLine()
                miCollectionView.reloadData()
                NotificationCenter.default().addObserver(self, selector: #selector(self.cambiarBadge), name:notificationChat, object: nil)
                NotificationCenter.default().addObserver(self, selector: #selector(self.itemMenuSelected), name:notificationItemMenuSelected , object: nil)
                miCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name(rawValue: notificationChat), object: nil)
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name(rawValue: notificationItemMenuSelected), object: nil)
        myTimer.invalidate()
    }

    //MARK: - Notification Oberser cuando clickamos en el menuLateral
    func itemMenuSelected(){
        enableUserInterface()
        performSegue(withIdentifier: segueShowMessagesTimeLine, sender: self)
    }
    
    func cambiarBadge(){
        let tabArray =  self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabArray?.object(at: 2) as! UITabBarItem
        let numeroMensajesSinLeer = Conversation.numeroMensajesSinLeer()
        DispatchQueue.main.async(execute: { () -> Void in
            if(numeroMensajesSinLeer > 0){
                tabItem.badgeValue = "\(numeroMensajesSinLeer)"
                UIApplication.shared().applicationIconBadgeNumber = numeroMensajesSinLeer
            }else{
                tabItem.badgeValue = nil
                UIApplication.shared().applicationIconBadgeNumber = 0
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
            miCollectionView.isUserInteractionEnabled = false
        }else{
            miCollectionView.isUserInteractionEnabled = true
        }
        activarCollectionViewUserInterface = !activarCollectionViewUserInterface
    }
    
    //MARK: - CollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listadoPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TimeLineCollectionViewCell
        
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        let contenido = listadoPost[indexPath.row].content
        var height = CGFloat(130)
        let contenidoSize = contenido.characters.count
        if contenido.contains("<img"){
            height = 320
        }else if contenidoSize < 50{
            height = 100
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        indiceSeleccionado = indexPath.row
        performSegue(withIdentifier: detailTimeLineSegue, sender: self)
    }

    //MARK: - Servidor
    func recuperarTimeLine(){
        let sessionKey = Utils.getSessionKey()
        let brandsNotificationsLastUpdate = Utils.getLastUpdateBrandsNotifications()
        let params = "action=list_brand_notifications&session_key=\(sessionKey)&brand_notifications_last_update=\(brandsNotificationsLastUpdate)&offset=\(0)&limit=\(1000)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("brand_notifications")
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let recuperarTimeLineTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.caritaTristeView.alpha = 0
                            self.openManualLbl.isUserInteractionEnabled = false
                            if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                                let brandNotiLastUp = dataResultado["brand_notifications_last_update"] as? String ?? ""
                                Utils.saveLastUpdateBrandsNotifications(brandNotiLastUp)
                                let needUpdate = dataResultado["need_to_update"] as? Bool ?? true
                                if needUpdate{
                                    TimeLine.borrarAllPost()
                                    if let listPost = dataResultado["brand_notifications"] as? [Dictionary<String, AnyObject>]{
                                        for post in listPost{
                                            _=TimeLine(aDict: post)
                                        }
                                        self.listadoPost = TimeLine.devolverListTimeLine()
                                       self.miCollectionView.reloadData()
                                    }
                                }
                            }
                        })
                    }else{
                        let codigoError = json["error_code"] as? String ?? ""
                        if codigoError != "brand_activities_empty"{
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.desLoguear = LogOut.comprobarDesloguear(codigoError)
                                (self.tituloAlert,self.mensajeAlert) = Utils.returnTitleAndMessageAlert(codigoError)
                                self.mostrarAlerta()
                            })
                        }else{
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.caritaTristeView.alpha = 1
                                self.openManualLbl.isUserInteractionEnabled = true
                            })
                        }
                    }
                }
            } catch{
                DispatchQueue.main.async(execute: { () -> Void in
                    self.caritaTristeView.alpha = 0
                    self.openManualLbl.isUserInteractionEnabled = false
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
        let alert = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = UIColor(red: 193/255, green: 24/255, blue: 20/255, alpha: 1)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausur
        if(desLoguear){
            desLoguear = false
            myTimerLeftMenu.invalidate()
            myTimer.invalidate()
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { (action) -> Void in
                LogOut.desLoguearBorrarDatos()
                self.dismiss(animated: true, completion: { () -> Void in
                })
            }))
        }else{
            //Añadimos un bonton al alert y lo que queramos que haga en la clausura
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: .default, handler: { action in
            
            }))
        }
        //mostramos el alert
        self.present(alert, animated: true) { () -> Void in
            self.tituloAlert = ""
            self.mensajeAlert = ""
        }
    }

    //Hora Formateada
    func devolverHoraFormateada(_ unixTimeString:String) -> String{
        var fechaFormateada = ""
        if unixTimeString.contains("seg"){
            var cadena = "segundos"
            if(unixTimeString == "1 seg"){
                cadena = "segundo"
            }
            fechaFormateada = unixTimeString.replacingOccurrences(of: "seg", with: cadena, options: [], range: nil)
        }else if unixTimeString.contains("min"){
            var cadena = "minutos"
            if(unixTimeString == "1 min"){
                cadena = "minuto"
            }
            fechaFormateada = unixTimeString.replacingOccurrences(of: "min", with: cadena, options: [], range: nil)
        }else if unixTimeString.contains("h") && unixTimeString != "Ahora"{
            var cadena = "horas"
            if(unixTimeString == "1 h"){
                cadena = "hora"
            }
            fechaFormateada = unixTimeString.replacingOccurrences(of: "h", with: cadena, options: [], range: nil)
        }else{
            fechaFormateada = unixTimeString
        }
        return fechaFormateada
    }
    
    //MARK: - Lanzar enlace del webView en safari
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if(navigationType == UIWebViewNavigationType.linkClicked){
            UIApplication.shared().openURL(request.url!)
            return false
        }
        return true
    }
    
    //MARK: - PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
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
        tapManualLabel.addTarget(self, action: #selector(self.tappedManual))
        openManualLbl.addGestureRecognizer(tapManualLabel)
    }
    
    func tappedManual(){
        if let requestUrl = URL(string: "http://www.converfit.com/es/integration/index.html") {
            UIApplication.shared().openURL(requestUrl)
        }
    }
    
    //MARK : - openManualLbl customize
    func customizeopenManualTextLbl(){
        let manualText = "No podemos mostrarte la información de tu web. Comprueba que has integrado el código correctamente para acceder a los datos de tus usuarios. Para mas información consulta nuestro manual de integración."
        let myMutableString = NSMutableAttributedString(string: manualText)
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue(), range: NSRange(location:manualText.characters.count - 22 , length: 22))
        manualTextLbl.attributedText = myMutableString
    }
}
