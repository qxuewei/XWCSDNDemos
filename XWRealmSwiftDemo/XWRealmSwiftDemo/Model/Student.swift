//
//  Student.swift
//  XWRealmSwiftDemo
//
//  Created by 邱学伟 on 2018/5/29.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

import UIKit
import RealmSwift

class Student: Object {
    @objc dynamic var name = ""
    @objc dynamic var age = 18
    @objc dynamic var weight = 156
    @objc dynamic var id = 0
    @objc dynamic var address = ""
    @objc dynamic var birthday : NSDate? = nil
    @objc dynamic var photo : NSData?  = nil
}

extension Student {
    /// 头像赋值
    public func setPhotoWitName(_ imageName : String) -> Void {
        let image = UIImage(named: imageName);
        guard image == nil else {
            self.photo = (UIImagePNGRepresentation(image!)! as NSData)
            return
        }
    }
    
    /// 获取头像
    public func getPhotoImage() -> UIImage? {
        return UIImage(data: self.photo! as Data);
    }
}
