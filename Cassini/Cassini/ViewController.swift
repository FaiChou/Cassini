//
//  ViewController.swift
//  Cassini
//
//  Created by 周辉 on 2017/4/27.
//  Copyright © 2017年 周辉. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  let cassiniTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "Cassini"
    label.textAlignment = .center
    label.textColor = UIColor.cyan
    label.font = UIFont.systemFont(ofSize: 18, weight: 9)
    return label
  }()
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(cassiniTitleLabel)
    cassiniTitleLabel.snp.makeConstraints { (make) in
      make.width.equalToSuperview()
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(30)
    }
  }
}

