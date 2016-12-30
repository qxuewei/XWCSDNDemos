//
//  BaseNavigationController.swift
//  XWFullScreenPop
//
//  Created by 邱学伟 on 2016/12/30.
//  Copyright © 2016年 邱学伟. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //测试 利用 runtime 打印 UIGestureRecognizer 所以 成员属性和变量
        //printAllPropertyWithRuntime(UIGestureRecognizer.self)
        
        // 添加全屏pop手势 -> 若不实现 右滑返回只能作用于 不隐藏navigationBar 前提下 屏幕左侧一部分区域
        addFullScreenPopGes()
    }
    
    /// 添加全屏 pop 手势
    func addFullScreenPopGes() {
        guard let targetsValue : NSArray = interactivePopGestureRecognizer?.value(forKey: "_targets") as! NSArray? else { return }
        guard let interactivePopGestureRecognizerTarget : NSObject = targetsValue.lastObject as! NSObject? else { return }
        // 获取需要的 target
        guard let target : Any = interactivePopGestureRecognizerTarget.value(forKey: "target") else { return }
        // 获取需要的 action
        let action : Selector = Selector(("handleNavigationTransition:"))
        let fullScreenPopPan : UIPanGestureRecognizer = UIPanGestureRecognizer(target: target, action: action)
        self.view.addGestureRecognizer(fullScreenPopPan)
    }
    
    /// RunTime 打印类所有属性(包括变量和成员属性)
    func printAllPropertyWithRuntime(_ anyClass : AnyClass) {
        var count : UInt32 = 0
        // 获取某类的所以变量和成员属性
        guard let ivars = class_copyIvarList(anyClass, &count) else{ return }
        for i in 0..<count {
            // 取出属性
            guard let ivar = ivars[Int(i)] else { return }
            // 获取某属性名称 - 获取到指针
            let propertyNamePointer = ivar_getName(ivar)
            let propertyNameStr : String = String.init(cString: propertyNamePointer!)
            print(propertyNameStr)
        }
    }
}
