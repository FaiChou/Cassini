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
  enum BubbleDirection {
    case left, right
  }
  func bubble(_ direction: BubbleDirection = .left) {
    let iv = UIImageView()
    iv.frame = CGRect(origin: .zero, size: bounds.size)
    let imageDirName = direction == .left ? "bubble-left" : "bubble-right"
    let capInsets = direction == .left ? UIEdgeInsetsMake(20, 20, 20, 20) : UIEdgeInsetsMake(30, 50, 30, 50)
    iv.image = UIImage(named: imageDirName)?
      .resizableImage(withCapInsets: capInsets,
                      resizingMode: .stretch)
    self.layer.mask = iv.layer
  }
}
extension UIView {
  func contains(point: CGPoint) -> Bool {
    let radius = bounds.width / 2
    let dx = point.x-center.x
    let dy = point.y-center.y
    if (dx*dx + dy*dy) <= radius*radius {
      return true
    } else {
      return false
    }
  }
}
extension UIView {
  func rotate360Degrees(duration: CFTimeInterval = 3) {
    let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
    rotateAnimation.fromValue = 0.0
    rotateAnimation.toValue = CGFloat(Double.pi * 2)
    rotateAnimation.isRemovedOnCompletion = false
    rotateAnimation.duration = duration
    rotateAnimation.repeatCount=Float.infinity
    self.layer.add(rotateAnimation, forKey: nil)
  }
}
