//
//  ViewController.swift
//  Cassini
//
//  Created by 周辉 on 2017/4/27.
//  Copyright © 2017年 周辉. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

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
  
  let button: UIButton = {
    let button = UIButton(type: .custom)
    button.setBackgroundImage(UIImage(named: "arrow-right-c"), for: .normal)
    button.addTarget(self, action: #selector(action), for: .touchUpInside)
    button.heroID = "button"
    return button
  }()
  func action() {
    let vc = CassiniDroneController()
    present(vc, animated: true, completion: nil)
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
      make.bottom.equalToSuperview().offset(-10)
    }
    view.addSubview(button)
    button.snp.makeConstraints { (make) in
      make.width.equalTo(30)
      make.height.equalTo(30)
      make.right.equalToSuperview().offset(-10)
      make.bottom.equalToSuperview().offset(-10)
    }
    isHeroEnabled = true
  }
}

class CassiniDroneController: UIViewController, GCDAsyncUdpSocketDelegate {
  let button: UIButton = {
    let button = UIButton(type: .custom)
    button.setBackgroundImage(UIImage(named: "close-round"), for: .normal)
    button.addTarget(self, action: #selector(action), for: .touchUpInside)
    button.heroID = "button"
    return button
  }()
  func action() {
    dismiss(animated: true, completion: nil)
  }
  
  var _socket: GCDAsyncUdpSocket?
  var socket: GCDAsyncUdpSocket? {
    get {
      if _socket == nil {
//        guard let port = UInt16(6666) else {
//          print(">>> Unable to init socket: local port unspecified.")
//          return nil
//        }
        let port = UInt16(6666)
        let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
          try sock.bind(toPort: port)
          try sock.beginReceiving()
        } catch let err as NSError {
          print(">>> Error while initializing socket: \(err.localizedDescription)")
          sock.close()
          return nil
        }
        _socket = sock
      }
      return _socket
    }
    set {
      _socket?.close()
      _socket = newValue
    }
  }
  
  let sendButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setBackgroundImage(UIImage(named: "paper-airplane"), for: .normal)
    button.addTarget(self, action: #selector(send), for: .touchUpInside)
    button.heroID = "Cassini"
    return button
  }()
  
  func send() -> Void {
    let value = "FaiChou"
    let data = value.data(using: .utf8)
    socket?.send(data!, toHost: "192.168.2.3", port: 6666, withTimeout: 2, tag: 0)
  }
  
  //MARK: - life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    
    view.addSubview(button)
    button.snp.makeConstraints { (make) in
      make.width.equalTo(20)
      make.height.equalTo(20)
      make.top.equalToSuperview().offset(30)
      make.left.equalToSuperview().offset(10)
    }
    view.addSubview(sendButton)
    sendButton.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
      make.width.equalTo(50)
      make.height.equalTo(40)
    }
    isHeroEnabled = true
  }
  deinit {
    socket = nil
    print(">>> socket dead..")
  }
  //MARK: - GCDAsyncUdpSocketDelegate
  func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
    print(#function)
  }
  func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
    print(#function)
  }
  func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
    print(#function)
  }
  func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
    print(#function)
  }
  func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
    print(#function)
  }
  func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
    print(#function)
  }
}

