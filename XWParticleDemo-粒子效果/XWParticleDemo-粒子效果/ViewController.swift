//
//  ViewController.swift
//  XWParticleDemo-粒子效果
//
//  Created by 邱学伟 on 2016/12/30.
//  Copyright © 2016年 邱学伟. All rights reserved.
//

import UIKit

class ViewController: UIViewController,Particleable {

    override func viewDidLoad() {
        super.viewDidLoad()
        let poiter = CGPoint(x: UIScreen.main.bounds.width * 0.85, y: UIScreen.main.bounds.height - 20)
        addParticleEffect(poiter)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeParticleEffect()
    }
}

