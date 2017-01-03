//
//  ViewController.swift
//  XWProtocolDemo
//
//  Created by 邱学伟 on 2016/12/30.
//  Copyright © 2016年 邱学伟. All rights reserved.
//

import UIKit

class ViewController: UIViewController , Particleable {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func addParticle(_ sender: UIButton) {
        addParticle(sender.center)
    }
    @IBAction func removeParticle(_ sender: UIButton) {
        removeParticle()
    }
}

