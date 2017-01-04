//
//  NibLoadable.swift
//  XWProtocolDemo
//
//  Created by 邱学伟 on 2016/12/30.
//  Copyright © 2016年 邱学伟. All rights reserved.
//

import Foundation
import UIKit

protocol NibLoadable {
    
}

extension NibLoadable where Self : UIView {
    static func loadViewWithNib() -> Self {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.last! as! Self
    }
}
