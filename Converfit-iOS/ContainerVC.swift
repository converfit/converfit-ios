//
//  ContainerVC.swift
//  Converfit-iOS
//
//  Created by Manuel Citious on 15/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class ContainerVC: UIViewController {

    //MARK:- Variables
    let tabBarSegue = "tabBarSegue"
    // This value matches the left menu's width in the Storyboard
    let leftMenuWidth:CGFloat = -260
    
    //MARK: - Outlets
    @IBOutlet weak var miScrollView: UIScrollView!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Tab bar controller's child pages have a top-left button toggles the menu
        NotificationCenter.default().addObserver(self, selector: #selector(self.toggleMenu), name: notificationToggleMenu, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
           // self.toggleMenu()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == tabBarSegue){
            let tabBar = segue.destinationViewController as? UITabBarController
            tabBar?.selectedIndex = 0
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Mostrar u ocultar el menu
    func toggleMenu(){
        miScrollView.contentOffset.x == 0  ? closeMenu() : openMenu()
    }
    
    // Use scrollview content offset-x to slide the menu.
    func closeMenu(){
        miScrollView.setContentOffset(CGPoint(x: leftMenuWidth, y: 0), animated: true)
    }
    
    // Open is the natural state of the menu because of how the storyboard is setup.
    func openMenu(){
        miScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        NotificationCenter.default().post(name: Notification.Name(rawValue: notificationsOpenDrawerMenu), object: nil)
    }
}
