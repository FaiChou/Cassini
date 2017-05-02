//
//  CassiniDroneController.swift
//  Cassini
//
//  Created by 周辉 on 2017/4/28.
//  Copyright © 2017年 周辉. All rights reserved.
//

import Foundation
import UIKit
import CocoaAsyncSocket
import QuartzCore

let HOST = "CassiniHost"
let PORT = "CassiniPort"

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
  
  lazy var sendButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setBackgroundImage(UIImage(named: "ios7-paperplane-outline"), for: .normal)
    button.addTarget(self, action: #selector(send), for: .touchUpInside)
    button.heroID = "Cassini"
    button.layer.addSublayer(self.radarLayer)
    return button
  }()
  
  let radarLayer: RadarLayer = {
    let layer = RadarLayer()
    layer.repeatTime = 3
    layer.radius = 25
    layer.backgroundColor = UIColor(red:0.13, green:0.13, blue:0.19, alpha:1.00).cgColor
    layer.position = CGPoint(x: 25, y: 25)
    return layer
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
        UserDefaults.standard.set(self.host, forKey: HOST)
        UserDefaults.standard.set(self.port, forKey: PORT)
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
  
  private let bgImageView: UIImageView = {
    let imageView = UIImageView(image: #imageLiteral(resourceName: "bg2"))
    imageView.alpha = 0.8
    return imageView
  }()
  
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
    view.addSubview(bgImageView)
    bgImageView.snp.makeConstraints { (make) in
      make.width.equalToSuperview()
      make.top.equalTo(self.serverLabel.snp.bottom)
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.sendButton.snp.top).offset(-10)
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
    
    self.host = (UserDefaults.standard.value(forKey: HOST) as? String) ?? "192.168.2.3"
    self.port = (UserDefaults.standard.value(forKey: PORT) as? Int) ?? 6666
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
