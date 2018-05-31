//
//  Book.swift
//  XWRealmSwiftDemo
//
//  Created by 邱学伟 on 2018/5/30.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

import UIKit
import RealmSwift

class Book: Object {
    @objc dynamic var name
    @objc dynamic var author
}
