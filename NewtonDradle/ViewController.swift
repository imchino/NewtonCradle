//
//  ViewController.swift
//  NewtonDradle
//
//  Created by chino on 2016/04/10.
//  Copyright © 2016年 chino. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let colors = [UIColor.blueColor(), UIColor.redColor(), UIColor.yellowColor()]
        let frame = CGRect(x: 0, y: 0, width: view.frame.maxX, height: view.frame.maxY)
        let newtonCradle = NewtonCradle(colors: colors, viewFrame: frame)
        self.view.addSubview(newtonCradle)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

