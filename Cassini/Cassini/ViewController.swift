//
//  ViewController.swift
//  Cassini
//
//  Created by 周辉 on 2017/4/27.
//  Copyright © 2017年 周辉. All rights reserved.
//

import UIKit

let CassiniJourneyDescription = "Saturn, get ready for your close-up! Today the Cassini spacecraft starts a series of swoops between Saturn and its rings. These cosmic acrobatics are part of Cassini's dramatic \"Grand Finale,\" a set of orbits offering Earthlings an unprecedented look at the second largest planet in our solar system.\n\n" +

"By plunging into this fascinating frontier, Cassini will help scientists learn more about the origins, mass, and age of Saturn's rings, as well as the mysteries of the gas giant's interior. And of course there will be breathtaking additions to Cassini's already stunning photo gallery. Cassini recently revealed some secrets of Saturn's icy moon Enceladus -- including conditions friendly to life!  Who knows what marvels this hardy explorer will uncover in the final chapter of its mission?\n\n" +

"Cassini is a joint endeavor of NASA, the European Space Agency (ESA), and the Italian space agency (ASI). The spacecraft began its 2.2 billion–mile journey 20 years ago and has been hanging out with Saturn since 2004. Later this year, Cassini will say goodbye and become part of Saturn when it crashes through the planet’s atmosphere. But first, it has some spectacular sightseeing to do!"


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
    cassiniTitleLabel.snp.makeConstraints { (make) in
      make.width.equalToSuperview()
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(30)
      make.height.equalTo(20)
    }
    view.addSubview(cassiniDescriptionLabel)
    cassiniDescriptionLabel.snp.makeConstraints { (make) in
      make.width.equalToSuperview().multipliedBy(0.9)
      make.centerX.equalToSuperview()
      make.top.equalTo(self.cassiniTitleLabel.snp.bottom)
      make.bottom.equalToSuperview().offset(-20)
    }
    view.addSubview(bottomView)
    bottomView.snp.makeConstraints { (make) in
      make.width.equalToSuperview()
      make.centerX.equalToSuperview()
      make.height.equalTo(LayoutConstant.bottomBarHeight)
      make.bottom.equalToSuperview()
    }
    view.addSubview(pushButton)
    pushButton.snp.makeConstraints { (make) in
      make.width.equalTo(LayoutConstant.itemWitdh)
      make.height.equalTo(LayoutConstant.itemHeight)
      make.right.equalToSuperview().offset(-LayoutConstant.itemRightPadding)
      make.bottom.equalToSuperview().offset(-LayoutConstant.itemBottomPadding)
    }
    isHeroEnabled = true
  }
}


