//
//  RoundedControl.swift
//  Cassini
//
//  Created by 周辉 on 2017/5/22.
//  Copyright © 2017年 周辉. All rights reserved.
//

import Foundation
import UIKit

class RoundedLabel: UILabel {
  override func layoutSubviews() {
    super.layoutSubviews()
    let radius: CGFloat = self.bounds.size.height / 2.0
    self.layer.cornerRadius = radius
    self.clipsToBounds = true
  }
}

class RoundedView: UIView {
  override func layoutSubviews() {
    super.layoutSubviews()
    let radius: CGFloat = self.bounds.size.height / 2.0
    self.layer.cornerRadius = radius
    self.clipsToBounds = true
  }
}

class RoundedButton: UIButton {
  override func layoutSubviews() {
    super.layoutSubviews()
    let radius: CGFloat = self.bounds.size.height / 2.0
    self.layer.cornerRadius = radius
    self.clipsToBounds = true
  }
}

class RoundedImageView: UIImageView {
  override func layoutSubviews() {
    super.layoutSubviews()
    let radius: CGFloat = self.bounds.size.height / 2.0
    self.layer.cornerRadius = radius
    self.clipsToBounds = true
  }
}
