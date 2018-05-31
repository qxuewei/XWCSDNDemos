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
        let stus = XWStudentRealmTool.getStudents()
        for stu in stus {
            print(stu.name)
            if stu.photo != nil {
                self.imageV.image = stu.getPhotoImage()
            }
            if stu.books.count > 0 {
                for book in stu.books {
                    print(book.name + "+" + book.author)
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

