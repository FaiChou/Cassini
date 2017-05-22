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
    label.textColor = UIColor.brown
    label.font = UIFont.systemFont(ofSize: 18, weight: 9)
    label.heroID = "Cassini"
    return label
  }()
  let cassiniDescriptionLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 50
    label.textColor = UIColor.black
    label.text = CassiniJourneyDescription
    label.font = UIFont.italicSystemFont(ofSize: 13)
    return label
  }()
  
  let pushButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setBackgroundImage(UIImage(named: "arrow-right-c"), for: .normal)
    button.addTarget(self, action: #selector(push), for: .touchUpInside)
    button.heroID = "close"
    return button
  }()
  func push() {
    let vc = CassiniDroneController()
    present(vc, animated: true, completion: nil)
  }
  
  let bottomView: UIView = {
    let v = UIView()
    v.backgroundColor = .blue
    v.alpha = 0.3
    v.addTopBorderWithColor(color: .red)
    return v
  }()
  
  private struct LayoutConstant {
    static let itemWitdh = 25
    static let itemHeight = 25
    static let itemLeftPadding = 30
    static let itemRightPadding = 30
    static let itemBottomPadding = 5
    static let bottomBarHeight = 40
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(cassiniTitleLabel)
    view.addSubview(cassiniDescriptionLabel)
    view.addSubview(bottomView)
    view.addSubview(pushButton)
    isHeroEnabled = true
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    cassiniTitleLabel.snp.makeConstraints { (make) in
      make.width.equalToSuperview()
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(30)
      make.height.equalTo(20)
    }
    cassiniDescriptionLabel.snp.makeConstraints { (make) in
      make.width.equalToSuperview().multipliedBy(0.9)
      make.centerX.equalToSuperview()
      make.top.equalTo(self.cassiniTitleLabel.snp.bottom)
      make.bottom.equalToSuperview().offset(-20)
    }
    bottomView.snp.makeConstraints { (make) in
      make.width.equalToSuperview()
      make.centerX.equalToSuperview()
      make.height.equalTo(LayoutConstant.bottomBarHeight)
      make.bottom.equalToSuperview()
    }
    pushButton.snp.makeConstraints { (make) in
      make.width.equalTo(LayoutConstant.itemWitdh)
      make.height.equalTo(LayoutConstant.itemHeight)
      make.right.equalToSuperview().offset(-LayoutConstant.itemRightPadding)
      make.bottom.equalToSuperview().offset(-LayoutConstant.itemBottomPadding)
    }
  }
}

