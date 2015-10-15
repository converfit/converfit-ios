//
//  TimeLineViewController.swift
//  Converfit-iOS
//
//  Created by Manuel Martinez Gomez on 14/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class DetailTimeLineUser: UIViewController, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIWebViewDelegate {
    
    //MARK: - Variables
    private let reuseIdentifier = "timeLineCollectionCell"
    private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var listadoPost  = [TimeLineModel]()
    var mensajeAlert = ""
    var tituloAlert = ""
    let detailTimeLineSegue = "detailTimeLineSegue"
    var titleUsuario = ""
    var userKey = ""
    
    //MARK: - Outlets
    @IBOutlet weak var miCollectionView: UICollectionView!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = titleUsuario
        self.tabBarController?.tabBar.hidden = true
        Utils.customAppear(self)
        listadoPost = TimeLine.devolverPostUserKey(userKey)
        miCollectionView.reloadData()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
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
    
    //MARK: - MostrarAlerta
    func mostrarAlerta(){
        self.view.endEditing(true)
        let alert = UIAlertController(title: tituloAlert, message: mensajeAlert, preferredStyle: UIAlertControllerStyle.Alert)
        //Añadimos un bonton al alert y lo que queramos que haga en la clausura
        alert.addAction(UIAlertAction(title: "ACEPTAR", style: .Default, handler: { action in
            
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
    
    //MARK: - Lanzar enlace del webView en safari
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if(navigationType == UIWebViewNavigationType.LinkClicked){
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        return true
    }
}
