//
//  Radar.swift
//  Cassini
//
//  Created by 周辉 on 2017/5/22.
//  Copyright © 2017年 周辉. All rights reserved.
//

import Foundation
import UIKit

class RadarLayer: CALayer {
  
  //MARK: - variables
  var radius: CGFloat = 10 {
    didSet {
      let width = radius * 2
      let position = self.position
      self.bounds = CGRect(x: 0, y: 0, width: width, height: width)
      self.cornerRadius = radius
      self.position = position
    }
  }
  var repeatTime: TimeInterval = 4
  var delayTime: TimeInterval = 0
  var animationGroup: CAAnimationGroup?
  
  //MARK: - life cycle
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override init() {
    super.init()
    contentsScale = UIScreen.main.scale
    opacity = 0
    backgroundColor = UIColor.white.cgColor
    DispatchQueue.global(qos: .default).async {
      self.setupAnimation()
      if self.delayTime != TimeInterval.infinity {
        DispatchQueue.main.async {
          self.add(self.animationGroup!, forKey: "pulse")
        }
      }
    }
  }
  
  func setupAnimation() {
    let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
    self.animationGroup = CAAnimationGroup()
    self.animationGroup?.duration = self.repeatTime + self.delayTime
    self.animationGroup?.repeatCount = Float.infinity
    self.animationGroup?.isRemovedOnCompletion = false
    self.animationGroup?.timingFunction = defaultCurve
    
    let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
    scaleAnimation.fromValue = 0.0
    scaleAnimation.toValue = 1.2
    scaleAnimation.duration = self.repeatTime
    
    let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
    opacityAnimation.duration = self.repeatTime
    opacityAnimation.values = [0.2, 0.45, 0.5, 0]
    opacityAnimation.keyTimes = [0, 0.20, 0.6, 1]
    opacityAnimation.isRemovedOnCompletion = false
    
    let animations = [scaleAnimation, opacityAnimation]
    self.animationGroup?.animations = animations
  }
  
}
