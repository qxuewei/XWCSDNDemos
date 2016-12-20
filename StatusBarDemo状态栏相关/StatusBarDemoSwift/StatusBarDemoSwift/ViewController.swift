//
//  ViewController.swift
//  StatusBarDemoSwift
//
//  Created by 邱学伟 on 2016/12/20.
//  Copyright © 2016年 邱学伟. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.green
        setStatusBarBackgroundColor(color: .green)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    ///设置状态栏背景颜色
    func setStatusBarBackgroundColor(color : UIColor) {
        let statusBarWindow : UIView = UIApplication.shared.value(forKey: "statusBarWindow") as! UIView
        let statusBar : UIView = statusBarWindow.value(forKey: "statusBar") as! UIView
        /*
        if statusBar.responds(to:Selector("setBackgroundColor:")) {
            statusBar.backgroundColor = color
        }*/
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = color
        }
    }
//    @IBOutlet weak var toNavigaitionController: UIButton!
//    
//    @IBAction func toNavigationController(_ sender: UIButton) {
//        let testVC : TestViewController = TestViewController()
//        let nav : UINavigationController = UINavigationController(rootViewController: testVC)
//        present(nav, animated: true, completion: nil)
//        
//    }
}

