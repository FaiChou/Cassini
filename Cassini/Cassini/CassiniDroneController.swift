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

class CassiniDroneController: UIViewController {
  
  //MARK: - variables
  var host = "192.168.2.3" {
    didSet {
      serverLabel.text = "\(host):\(port)"
    }
  }
  var port = 6666 {
    didSet {
      serverLabel.text = "\(host):\(port)"
    }
  }
  var msg = "c<c050" {
    didSet {
      
    }
  }
  
  var timer = Timer()
  
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
  
  let closeButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setBackgroundImage(UIImage(named: "close-round"), for: .normal)
    button.addTarget(self,
                     action: #selector(close),
                     for: .touchUpInside)
    button.heroID = "close"
    return button
  }()
  func close() {
    socketUdp.close()
    socketTcp.disconnect()
    dismiss(animated: true, completion: nil)
  }
  
  lazy var socketUdp: GCDAsyncUdpSocket = {
    let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
    let port = UInt16(3333)
    do {
      try socket.bind(toPort: port)
    } catch let err as NSError {
      print(">>> Error while initializing socket: \(err.localizedDescription)")
      socket.close()
    }
    return socket
  }()

  lazy var socketTcp: GCDAsyncSocket = {
    let socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    do {
      try socket.connect(toHost: self.host, onPort: UInt16(self.port))
    } catch let err as NSError {
      print(">>> Error while initializing socket: \(err.localizedDescription)")
      socket.disconnect()
    }
    return socket
  }()

  private func reconnectTcp() {
    if socketTcp.isConnected {
      socketTcp.disconnect()
    }
    do {
      try self.socketTcp.connect(toHost: host, onPort: UInt16(port))
    } catch let err as NSError {
      print(">>> Error while initializing socket: \(err.localizedDescription)")
      socketTcp.disconnect()
    }
  }
  
  func send() {
    let data = msg.data(using: .utf8)
    switch currentSocketMode {
    case .UDP:
      socketUdp.send(data!, toHost: host, port: UInt16(port), withTimeout: 2, tag: 0)
    case .TCP:
      socketTcp.write(data!, withTimeout: -1, tag: 0)
    default:
      break
    }
  }
  
  let settingButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setBackgroundImage(UIImage(named: "ios7-gear-outline"), for: .normal)
    button.addTarget(self,
                     action: #selector(setting),
                     for: .touchUpInside)
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
      textField.addTarget(self,
                          action: #selector(self.alertTextFieldChangeCharactor(sender:)),
                          for: .editingChanged)
    }
    alertController.addTextField { (textField) in
      textField.placeholder = "port(\(self.port))"
      textField.keyboardType = .decimalPad
      textField.addTarget(self,
                          action: #selector(self.alertTextFieldChangeCharactor(sender:)),
                          for: .editingChanged)
    }
    let okAction = UIAlertAction(
      title: "OK",
      style: .default) { (action) in
        let hostTF = alertController.textFields![0] as UITextField
        let portTF = alertController.textFields![1] as UITextField
        self.host = hostTF.text ?? "192.168.2.3"
        self.port = ((portTF.text ?? "6666") as NSString).integerValue
        self.reconnectTcp()
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
    present(
      alertController,
      animated: true,
      completion: nil)
  }
  func alertTextFieldChangeCharactor(sender: UITextField) {
    let alertController = presentedViewController as? UIAlertController
    if alertController != nil {
      let hostTF = alertController?.textFields?[0]
      let portTF = alertController?.textFields?[1]
      if (hostTF?.text?.characters.count)! > 8
        && (portTF?.text?.characters.count)! > 3 {
        alertController?.actions.first?.isEnabled = true
      }
    }
  }
  
  enum SocketMode {
    case None
    case TCP
    case UDP
  }
  
  var currentSocketMode: SocketMode = .UDP {
    didSet {
      if currentSocketMode == .UDP {

      } else {

      }
    }
  }
  
  let tcpUdpSegmentControl: UISegmentedControl = {
    let ct = UISegmentedControl(items: ["UDP", "TCP"])
    ct.selectedSegmentIndex = 0
    ct.addTarget(self,
                 action: #selector(switchTcpUdp),
                 for: .valueChanged)
    return ct
  }()
  @objc private func switchTcpUdp(sc: UISegmentedControl) {
    switch sc.selectedSegmentIndex {
    case 0:
      currentSocketMode = .UDP
    case 1:
      currentSocketMode = .TCP
    default:
      currentSocketMode = .None
    }
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
  
  let speedSlider: UISlider = {
    let s = UISlider()
    s.minimumValue = 0
    
    s.maximumValue = 200
    s.addTarget(self,
                action: #selector(changeSpeed),
                for: .valueChanged)
    s.setValue(50, animated: true)
    return s
  }()
  func changeSpeed(_ stepper: UISlider) {
    let s = Int(stepper.value)
    let ss = String(format: "%03d", s)
    msg = MSGLEADING + ss
    print(msg)
  }
  let speedMinimumValueLabel: UILabel = {
    let l = UILabel()
    l.text = "0"
    l.font = UIFont.systemFont(ofSize: 10)
    l.textAlignment = .center
    return l
  }()
  let speedMaximunValueLabel: UILabel = {
    let l = UILabel()
    l.text = "200"
    l.font = UIFont.systemFont(ofSize: 10)
    l.textAlignment = .center
    return l
  }()
  let openSwitcher: UISwitch = {
    let s = UISwitch()
    s.isOn = false
    s.addTarget(self,
                action: #selector(switchSpeed),
                for: .valueChanged)
    return s
  }()
  func switchSpeed(_ switcher: UISwitch) {
    let state = switcher.isOn ? "开" : "关"
    print(state)
    if switcher.isOn {
      timer = Timer.scheduledTimer(
        timeInterval: 0.1,
        target: self,
        selector: #selector(send),
        userInfo: nil,
        repeats: true)
    } else {
      timer.invalidate()
    }
  }
  func tickTimerAction() {
    
  }
  //MARK: - life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    
    view.addSubview(bottomView)
    bottomView.snp.makeConstraints { (make) in
      make.width.equalToSuperview()
      make.centerX.equalToSuperview()
      make.height.equalTo(LayoutConstant.bottomBarHeight)
      make.bottom.equalToSuperview()
    }
    
    view.addSubview(closeButton)
    closeButton.snp.makeConstraints { (make) in
      make.width.equalTo(LayoutConstant.itemWitdh)
      make.height.equalTo(LayoutConstant.itemHeight)
      make.bottom.equalToSuperview().offset(-LayoutConstant.itemBottomPadding)
      make.right.equalToSuperview().offset(-LayoutConstant.itemRightPadding)
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
      make.size.equalTo(closeButton)
      make.left.equalToSuperview().offset(LayoutConstant.itemLeftPadding)
      make.bottom.equalToSuperview().offset(-LayoutConstant.itemBottomPadding)
    }
    view.addSubview(tcpUdpSegmentControl)
    tcpUdpSegmentControl.snp.makeConstraints { (make) in
      make.width.equalToSuperview().multipliedBy(0.5)
      make.top.equalTo(serverLabel.snp.bottom).offset(10)
      make.centerX.equalToSuperview()
      make.height.equalTo(25)
    }
    
    view.addSubview(speedSlider)
    view.addSubview(openSwitcher)
    view.addSubview(speedMinimumValueLabel)
    view.addSubview(speedMaximunValueLabel)
    
    speedSlider.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
      make.width.equalToSuperview().multipliedBy(0.8)
      make.height.equalTo(20)
    }
    speedMinimumValueLabel.snp.makeConstraints { (make) in
      make.size.equalTo(30)
      make.centerY.equalTo(speedSlider)
      make.right.equalTo(speedSlider.snp.left)
    }
    speedMaximunValueLabel.snp.makeConstraints { (make) in
      make.size.equalTo(speedMinimumValueLabel)
      make.centerY.equalTo(speedSlider)
      make.left.equalTo(speedSlider.snp.right)
    }
    openSwitcher.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().offset(-60)
    }
    
    isHeroEnabled = true
    
    host = (UserDefaults.standard.value(forKey: HOST) as? String) ?? "192.168.2.3"
    port = (UserDefaults.standard.value(forKey: PORT) as? Int) ?? 6666
  }
  deinit {
    print(">>> socket dead..")
  }
}
extension CassiniDroneController: GCDAsyncSocketDelegate {
  //MARK: - GCDAsyncSocketDelegate
  func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    SBHUD.showSuccess(msg: "TCP已连接")
    print("\(#function): \(host):\(port)")
  }
  func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
    SBHUD.showSuccess(msg: "TCP已断开连接")
    print(err ?? "")
  }
  func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
    print("\(#function):\(data)")
  }
}
extension CassiniDroneController: GCDAsyncUdpSocketDelegate {
  //MARK: - GCDAsyncUdpSocketDelegate
  func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
    print("\(#function): \(address)")
  }
  func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
    print(#function)
  }
  func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
    print(#function)
  }
}
