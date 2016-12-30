//
//  Particleable.swift
//  XWParticleDemo-粒子效果
//
//  Created by 邱学伟 on 2016/12/30.
//  Copyright © 2016年 邱学伟. All rights reserved.
//

import Foundation
import UIKit

protocol Particleable {
    // 此处定义的方法,在继承此协议的类中必须实现否则会报错! - 保留OC特性
//    func addParticleEffectTest(_ view : UIView)
}

extension Particleable where Self : UIViewController {
    func addParticleEffect(_ point : CGPoint = CGPoint(x: UIScreen.main.bounds.width * 0.85, y: UIScreen.main.bounds.height - 20) )  {
        // 1.创建发射器
        let emitter = CAEmitterLayer()
        // 2.发射器位置
        emitter.emitterPosition = point
        // 3.开启三维效果
        emitter.preservesDepth = true
        var cells = [CAEmitterCell]()
        for i in 0..<10 {
            // 4.设置 Cell(对应其中一个粒子)
            // 4.0.创建粒子
            let cell = CAEmitterCell()
            // 4.1.每秒发射粒子数
            cell.birthRate = Float(arc4random_uniform(4)) + 3
            // 4.2.粒子存活时间
            cell.lifetime = 5
            cell.lifetimeRange = 2.5
            // 4.3.缩放比例
            cell.scale = 0.7
            cell.scaleRange = 0.3
            // 4.4.粒子发射方向
            cell.emissionLongitude = CGFloat(-M_PI_2)
            cell.emissionRange = CGFloat(M_PI_4 * 0.6)
            // 4.5.粒子速度
            cell.velocity = 100
            cell.velocityRange = 50
            // 4.6.旋转速度
            cell.spin = CGFloat(M_PI_2)
            // 4.7.粒子内容
            cell.contents = UIImage(named: "good\(i)_30x30")?.cgImage
            cells.append(cell)
        }
        // 5.将粒子添加到发射器中
        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)
    }
    
    func removeParticleEffect() {
        //方式1: 常规遍历
//        for layer in view.layer.sublayers! {
//            if layer.isKind(of: CAEmitterLayer.self) {
//                layer.removeFromSuperlayer()
//            }
//        }
        //方式2: 映射
        view.layer.sublayers?.filter({ $0.isKind(of: CAEmitterLayer.self)}).last?.removeFromSuperlayer()
    }
}
