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
    view.addSubview(pushButton)
    pushButton.snp.makeConstraints { (make) in
      make.width.equalTo(30)
      make.height.equalTo(30)
      make.right.equalToSuperview().offset(-10)
      make.bottom.equalToSuperview().offset(-10)
    }
    isHeroEnabled = true
  }
}

class CassiniDroneController: UIViewController, GCDAsyncUdpSocketDelegate, UITextFieldDelegate {
  
  //MARK: - variables
  var host = "192.168.2.3" {
    didSet {
      self.serverLabel.text = "\(host):\(self.port)"
    }
  }
  var port = 6666 {
    didSet {
      self.serverLabel.text = "\(self.host):\(port)"
    }
  }
  var msg = "FaiChou" {
    didSet {
      self.msgLabel.text = msg
    }
  }
  
  //MARK: - control & his action
  lazy var serverLabel: UILabel = {
    [unowned self] in
    let label = UILabel()
    label.textAlignment = .center
    label.textColor = UIColor.black
    label.text = "\(self.host):\(self.port)"
    label.font = UIFont.boldSystemFont(ofSize: 13)
    label.heroID = "content"
    return label
  }()
  lazy var msgLabel: UILabel = {
    let label = UILabel()
    label.text = self.msg
    label.textAlignment = .center
    label.textColor = UIColor.black
    label.font = UIFont.boldSystemFont(ofSize: 13)
    return label
  }()
  
  let closeButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setBackgroundImage(UIImage(named: "close-round"), for: .normal)
    button.addTarget(self, action: #selector(close), for: .touchUpInside)
    button.heroID = "close"
    return button
  }()
  func close() {
    dismiss(animated: true, completion: nil)
  }
  
  var _socket: GCDAsyncUdpSocket?
  var socket: GCDAsyncUdpSocket? {
    get {
      if _socket == nil {
        let port = UInt16(3333)
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
    button.setBackgroundImage(UIImage(named: "ios7-paperplane-outline"), for: .normal)
    button.addTarget(self, action: #selector(send), for: .touchUpInside)
    button.heroID = "Cassini"
    return button
  }()
  
  func send() {
    let data = self.msg.data(using: .utf8)
    socket?.send(data!, toHost: self.host, port: UInt16(port), withTimeout: 2, tag: 0)
  }
  
  let settingButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setBackgroundImage(UIImage(named: "ios7-settings-strong"), for: .normal)
    button.addTarget(self, action: #selector(setting), for: .touchUpInside)
    button.heroID = "setting"
    return button
  }()
  
  func setting() {
    let alertController = UIAlertController(
      title: "Add Configs",
      message: "host & port",
      preferredStyle: .alert)
    alertController.addTextField { (textField) in
      textField.placeholder = "host(\(self.host))"
      textField.keyboardType = .decimalPad
      textField.delegate = self
      textField.addTarget(self, action: #selector(self.alertTextFieldChangeCharactor(sender:)), for: .editingChanged)
    }
    alertController.addTextField { (textField) in
      textField.placeholder = "port(\(self.port))"
      textField.keyboardType = .decimalPad
      textField.delegate = self
      textField.addTarget(self, action: #selector(self.alertTextFieldChangeCharactor(sender:)), for: .editingChanged)
    }
    let okAction = UIAlertAction(
      title: "OK",
      style: .default) { (action) in
        let hostTF = alertController.textFields![0] as UITextField
        let portTF = alertController.textFields![1] as UITextField
        self.host = hostTF.text ?? "192.168.2.3"
        self.port = ((portTF.text ?? "6666") as NSString).integerValue
    }
    okAction.isEnabled = false
    let cancleAction = UIAlertAction(
      title: "Cancel",
      style: .cancel) { (action) in
        print("cancel..")
    }
    alertController.addAction(okAction)
    alertController.addAction(cancleAction)
    self.present(
      alertController,
      animated: true,
      completion: nil)
  }
  func alertTextFieldChangeCharactor(sender: UITextField) {
    let alertController = self.presentedViewController as? UIAlertController
    if alertController != nil {
      let hostTF = alertController?.textFields?[0]
      let portTF = alertController?.textFields?[1]
      if (hostTF?.text?.characters.count)! > 8
      && (portTF?.text?.characters.count)! > 3 {
        alertController?.actions.first?.isEnabled = true
      }
    }
  }
  
  let msgButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setBackgroundImage(UIImage(named: "ios7-keypad-outline"), for: .normal)
    button.addTarget(self, action: #selector(writeMyMsg), for: .touchUpInside)
    return button
  }()
  
  func writeMyMsg() {
    let alertController = UIAlertController(
      title: "Type Your Message",
      message: "Message Sent to Server",
      preferredStyle: .alert)
    alertController.addTextField { (textField) in
      textField.placeholder = "message(\(self.msg))"
      textField.delegate = self
      textField.addTarget(self, action: #selector(self.msgAlertTextFieldChang), for: .editingChanged)
    }

    let okAction = UIAlertAction(
      title: "OK",
      style: .default) { (action) in
        let msgTF = alertController.textFields![0] as UITextField
        self.msg = msgTF.text ?? "FaiChou"
    }
    okAction.isEnabled = false
    let cancleAction = UIAlertAction(
      title: "Cancel",
      style: .cancel) { (action) in
        print("cancel..")
    }
    alertController.addAction(okAction)
    alertController.addAction(cancleAction)
    self.present(
      alertController,
      animated: true,
      completion: nil)
  }
  func msgAlertTextFieldChang() {
    let alertController = self.presentedViewController as? UIAlertController
    if alertController != nil {
      let msgTF = alertController?.textFields?[0]
      if (msgTF?.text?.characters.count)! > 0 {
        alertController?.actions.first?.isEnabled = true
      }
    }
  }
  
  //MARK: - life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    
    view.addSubview(closeButton)
    closeButton.snp.makeConstraints { (make) in
      make.width.equalTo(25)
      make.height.equalTo(25)
      make.bottom.equalToSuperview().offset(-10)
      make.right.equalToSuperview().offset(-10)
    }
    view.addSubview(serverLabel)
    serverLabel.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(20)
      make.width.equalTo(200)
      make.height.equalTo(50)
    }
    view.addSubview(settingButton)
    settingButton.snp.makeConstraints { (make) in
      make.size.equalTo(self.closeButton)
      make.top.equalToSuperview().offset(30)
      make.right.equalToSuperview().offset(-10)
    }
    view.addSubview(sendButton)
    sendButton.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
      make.width.equalTo(50)
      make.height.equalTo(50)
    }
    view.addSubview(msgLabel)
    msgLabel.snp.makeConstraints { (make) in
      make.width.equalToSuperview()
      make.height.equalTo(40)
      make.centerX.equalToSuperview()
      make.top.equalTo(self.sendButton.snp.bottom).offset(5)
    }
    view.addSubview(msgButton)
    msgButton.snp.makeConstraints { (make) in
      make.size.equalTo(self.closeButton)
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().offset(-10)
    }
    isHeroEnabled = true
  }
  deinit {
    socket = nil
    print(">>> socket dead..")
  }
  //MARK: - GCDAsyncUdpSocketDelegate
  func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
    print(#function)
  }
  func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
    print(#function)
  }

  //MARK: - UITextFieldDelegate
  func textFieldDidEndEditing(_ textField: UITextField) {
    print(#function)
  }
  func textFieldDidBeginEditing(_ textField: UITextField) {
    print(#function)
  }

}

