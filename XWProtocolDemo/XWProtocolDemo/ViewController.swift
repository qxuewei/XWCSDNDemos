//
//  ViewController.swift
//  XWProtocolDemo
//
//  Created by 邱学伟 on 2016/12/30.
//  Copyright © 2016年 邱学伟. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let redView : RedView = RedView.loadWithNib()
        view.addSubview(redView)
        
        view.addSubview(GreenView.loadViewWithNib())
    }
}

