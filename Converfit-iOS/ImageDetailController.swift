//
//  pruebasViewController.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 10/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class ImageDetailController: UIViewController,UIScrollViewDelegate {

    var imagenMostrada: UIImage?

    @IBOutlet weak var imagenGrande: UIImageView!
    @IBOutlet weak var miScroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miScroll.maximumZoomScale = 10.0
        miScroll.minimumZoomScale = 1.0
        imagenGrande.image = imagenMostrada
        self.automaticallyAdjustsScrollViewInsets = false
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        miScroll.addGestureRecognizer(doubleTapRecognizer)
        self.tabBarController?.tabBar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imagenGrande
    }
    
    //Con un dobleTap volvemos al tamaño original de la foto
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        // 1
        let pointInView = recognizer.locationInView(imagenGrande)
        
        // 2
        var newZoomScale = miScroll.zoomScale * 1.5
        newZoomScale = min(newZoomScale, miScroll.minimumZoomScale)
        
        // 3
        let scrollViewSize = miScroll.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        // 4
        miScroll.zoomToRect(rectToZoomTo, animated: true)
    }
}
