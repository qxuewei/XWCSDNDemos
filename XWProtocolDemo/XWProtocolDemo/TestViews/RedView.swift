//
//  RedView.swift
//  XWProtocolDemo
//
//  Created by 邱学伟 on 2016/12/30.
//  Copyright © 2016年 邱学伟. All rights reserved.
//

import UIKit

class RedView: UIView  {
    
    class func loadWithNib() -> RedView {
        return Bundle.main.loadNibNamed("RedView", owner: nil, options: nil)?.last! as! RedView
    }

}
