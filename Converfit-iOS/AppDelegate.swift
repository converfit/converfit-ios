//
//  AppDelegate.swift
//  Converfit-iOS
//
//  Created by Manuel Martinez Gomez on 8/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

let appVersion = "1.0.0"
//let sistema = "ios"
let sistema = "android"
let app = "converfit"
var ocultarLogIn = false
var coreDataStack = MMGCoreDataStack2(modelName: "Model")
var bloquearSistema = false
var errorCheckSession = ""
var irPantallaLogin = false
let notificationChat = "com.converfit.notificacionChat"
let notificationToggleMenu = "toggleMenu"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let type: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
        let setting = UIUserNotificationSettings(forTypes: type, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(setting)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        comprobarCheckSession()
        customizeAppearance()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to     the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: - Comprobar checkSession
    func comprobarCheckSession(){
        let sessionKey = Utils.getSessionKey()
        let lastUpdate = Utils.getLastUpdate()
        let deviceKey = Utils.getDeviceKey()
        let params = "action=check_session&session_key=\(sessionKey)&device_key=\(deviceKey)&last_update=\(lastUpdate)&system=\(sistema)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("access")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let semaphore = dispatch_semaphore_create(0)
        let checkSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            /*guard data != nil else {
                print("no data found: \(error)")
                return
            }
            */
            if(data != nil){
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                        if let resultCode = json.objectForKey("result") as? Int{
                            if(resultCode == 1){
                                if let dataResultado = json.objectForKey("data") as? NSDictionary{
                                    if let lastUpdate = dataResultado.objectForKey("last_update") as? String{
                                    Utils.saveLastUpdate(lastUpdate)
                                    ocultarLogIn = true
                                    }
                                }
                            }
                        }
                    }
                } catch{
                
                }
            }
            dispatch_semaphore_signal(semaphore)
        }
        checkSessionTask.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    func customizeAppearance(){
        window!.tintColor = Utils.returnRedConverfit()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    //MARK: - Push Notifications
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var stringDeviceToken = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        stringDeviceToken = stringDeviceToken.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
        Utils.saveDeviceKey(stringDeviceToken)
       _=PostServidor.actualizarDeviceKey()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        _=PostServidor.actualizarDeviceKey()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let dictNotification = userInfo as NSDictionary
        var action = ""
        var actionData = ""
        //var body = ""
        if let dictAps =  dictNotification.objectForKey("aps") as? NSDictionary{
            if let dictAlert = dictAps.objectForKey("alert") as? NSDictionary{
                if let actionDict = dictAlert.objectForKey("action") as? String{
                    action = actionDict
                }
                
                if let actionDataDict = dictAlert.objectForKey("actionData") as? String{
                    actionData = actionDataDict
                }
                
                /*if let bodyDict = dictAlert.objectForKey("body") as? String{
                    body = bodyDict
                }*/
            }
        }
        
        if(action == "new_message"){
            PostServidor.getConversacion(actionData)
        }
       // updatePush(dictNotification)
    }

}

