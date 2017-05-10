//
//  UIView+Extension.swift
//  Cassini
//
//  Created by 周辉 on 2017/5/10.
//  Copyright © 2017年 周辉. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
  func addTopBorderWithColor(color: UIColor, width: CGFloat = 0.5) {
    let view = UIView()
    view.backgroundColor = color
    addSubview(view)
    view.snp.makeConstraints { (make) in
      make.width.equalToSuperview()
      make.height.equalTo(width)
      make.top.equalToSuperview()
      make.left.equalToSuperview()
    }
  }
}
