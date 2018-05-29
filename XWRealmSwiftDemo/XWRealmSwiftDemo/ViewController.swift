//
//  ViewController.swift
//  XWRealmSwiftDemo
//
//  Created by 邱学伟 on 2018/5/29.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageV: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stus = XWRealmTool.getStudents()
        for stu in stus {
            print(stu.name)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

