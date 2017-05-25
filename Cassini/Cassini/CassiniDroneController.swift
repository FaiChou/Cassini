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
import CoreMotion
import simd

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
  var signal = Signal()
  
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
    disconnectTcp()
    dismiss(animated: true, completion: nil)
  }
  
  lazy var socketUdp: GCDAsyncUdpSocket = {
    let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
    let port = UInt16(3333)
    do {
      try socket.bind(toPort: port) // bind 是给自己
    } catch let err as NSError {
      print(">>> Error while initializing socket: \(err.localizedDescription)")
      socket.close()
    }
    return socket
  }()

  lazy var socketTcp: GCDAsyncSocket = {
    let socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    return socket
  }()

  private func reconnectTcp() {
    disconnectTcp()
    do {
      try socketTcp.connect(toHost: host, onPort: UInt16(port))
    } catch let err as NSError {
      print(">>> Error while initializing socket: \(err.localizedDescription)")
      socketTcp.disconnect()
    }
  }
  private func disconnectTcp() {
    if socketTcp.isConnected {
      socketTcp.disconnect()
    }
  }
  
  func send() {
    let data = signal.message.data(using: .utf8)
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
    button.setBackgroundImage(UIImage(named: "ios7-cog"), for: .normal)
    button.addTarget(self,
                     action: #selector(setting),
                     for: .touchUpInside)
    button.heroID = "setting"
    return button
  }()
  
  func setting() {
    let alertController = UIAlertController(
      title: "Add Settings",
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
        if self.currentSocketMode == .TCP {
          self.reconnectTcp()
        }
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
  
  let configButton: UIButton = {
    let b = UIButton(type: .custom)
    b.setBackgroundImage(UIImage(named: "ios7-information-outline"), for: .normal)
    b.addTarget(self,
                action: #selector(config),
                for: .touchUpInside)
    return b
  }()
  func config() {
    let alertController = UIAlertController(
      title: "Add Configs",
      message: "Pitch, Roll & Yaw",
      preferredStyle: .alert)
    alertController.addTextField { (textField) in
      textField.placeholder = "Pitch"
      textField.addTarget(self,
                          action: #selector(self.configTFChangeCharactor(sender:)),
                          for: .editingChanged)
    }
    alertController.addTextField { (textField) in
      textField.placeholder = "Roll"
      textField.addTarget(self,
                          action: #selector(self.configTFChangeCharactor(sender:)),
                          for: .editingChanged)
    }
    alertController.addTextField { (textField) in
      textField.placeholder = "Yaw"
      textField.addTarget(self,
                          action: #selector(self.configTFChangeCharactor(sender:)),
                          for: .editingChanged)
    }
    let okAction = UIAlertAction(
      title: "OK",
      style: .default) { (action) in
        let pitchTF = alertController.textFields![0] as UITextField
        let rollTF = alertController.textFields![1] as UITextField
        let yawTF = alertController.textFields![2] as UITextField
        self.sendConfig(pitch: pitchTF.text!, roll: rollTF.text!, yaw: yawTF.text!)
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
  func configTFChangeCharactor(sender: UITextField) {
    let alertController = presentedViewController as? UIAlertController
    if alertController != nil {
      let pitchTF = alertController?.textFields?[0]
      let rollTF = alertController?.textFields?[1]
      let yawTF = alertController?.textFields?[2]
      if (pitchTF?.text?.characters.count)! > 0
        && (rollTF?.text?.characters.count)! > 0
        && (yawTF?.text?.characters.count)! > 0 {
        alertController?.actions.first?.isEnabled = true
      }
    }
  }
  func sendConfig(pitch: String, roll: String, yaw: String) {
    
    var dataString: String
    
    let pA = pitch.components(separatedBy: " ")
    let rA = roll.components(separatedBy: " ")
    let yA = yaw.components(separatedBy: " ")
    
    let pp = pA[0]
    let pi = pA[1]
    let pd = pA[2]
    
    let rp = rA[0]
    let ri = rA[1]
    let rd = rA[2]
    
    let yp = yA[0]
    let yi = yA[1]
    let yd = yA[2]
    
    dataString =
      "P" +
      "p"+pp+"i"+pi+"d"+pd
      + "R" +
      "p"+rp+"i"+ri+"d"+rd
      + "Y" +
      "p"+yp+"i"+yi+"d"+yd
    
    print(dataString)
    
    let data = dataString.data(using: .utf8)
    switch currentSocketMode {
    case .UDP:
      socketUdp.send(data!, toHost: host, port: UInt16(port), withTimeout: 2, tag: 0)
    case .TCP:
      socketTcp.write(data!, withTimeout: -1, tag: 0)
    default:
      break
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
        disconnectTcp()
      } else {
        reconnectTcp()
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
    s.maximumValue = 100
    s.addTarget(self,
                action: #selector(changeSpeed),
                for: .valueChanged)
    s.setValue(50, animated: true)
    s.isEnabled = false
    return s
  }()
  func changeSpeed(_ slider: UISlider) {
    let speed = Int(slider.value)
    speedCurrentValueLabel.text = "当前速度: \(speed)"
    signal.changeSpeed(to: speed)
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
    l.text = "100"
    l.font = UIFont.systemFont(ofSize: 10)
    l.textAlignment = .center
    return l
  }()
  let speedCurrentValueLabel: UILabel = {
    let l = UILabel()
    l.text = "当前速度: 50"
    l.font = UIFont.systemFont(ofSize: 10)
    l.textAlignment = .center
    return l
  }()
  let openSwitcher: UISwitch = {
    let s = UISwitch()
    s.isOn = false
    s.addTarget(self,
                action: #selector(switchCassini),
                for: .valueChanged)
    return s
  }()
  func switchCassini(_ switcher: UISwitch) {
    let state = switcher.isOn ? "开" : "关"
    print(state)
    if switcher.isOn {
      speedSlider.isEnabled = true
      leftRotationButton.isEnabled = true
      rightRotationButton.isEnabled = true
      signal.reset()
      startMotionUpdates()
      timer = Timer.scheduledTimer(
        timeInterval: 0.1,
        target: self,
        selector: #selector(send),
        userInfo: nil,
        repeats: true)
    } else {
      speedSlider.setValue(50, animated: true)
      speedCurrentValueLabel.text = "当前速度: 50"
      stopMotionUpdates()
      airplaneImageView.center = view.center
      leftRotationButton.layer.removeAllAnimations()
      rightRotationButton.layer.removeAllAnimations()
      leftRotationButton.isEnabled = false
      rightRotationButton.isEnabled = false
      signal.shutdown()
      DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now()+0.5,
        execute: {
          self.speedSlider.isEnabled = false
          self.timer.invalidate()
      })
    }
  }
  let motionManager = CMMotionManager()
  lazy var directionArea: RoundedView = {
    let v = RoundedView()
    v.frame.size = CGSize(width: 200, height: 200)
    v.backgroundColor = .blue
    v.alpha = 0.7
    v.layer.addSublayer(self.directionLadar)
    return v
  }()
  let directionLadar: RadarLayer = {
    let l = RadarLayer()
    l.backgroundColor = UIColor.red.cgColor
    l.radius = 100
    l.repeatTime = 4.0
    l.position = CGPoint(
      x: 100,
      y: 100)
    return l
  }()
  let plusImageView: UIImageView = {
    let iv = UIImageView()
    iv.frame.size = CGSize(width: 20, height: 20)
    iv.image = UIImage(named: "ios7-plus-empty")
    iv.tintColor = .black
    return iv
  }()
  let airplaneImageView: UIImageView = {
    let iv = UIImageView()
    iv.frame.size = CGSize(width: 30, height: 30)
    iv.image = UIImage(named: "airplane")
    return iv
  }()
  let leftRotationButton: RoundedButton = {
    let b = RoundedButton()
    b.setBackgroundImage(UIImage(named: "ios7-reload-left"), for: .normal)
    b.addTarget(
      self,
      action: #selector(rotateLeft),
      for: .touchUpInside)
    b.isEnabled = false
    return b
  }()
  func rotateLeft(_ button: UIButton) {
    button.isSelected = !button.isSelected
    if rightRotationButton.isSelected {
      rightRotationButton.isSelected = false
      rightRotationButton.layer.removeAllAnimations()
    }
    if button.isSelected {
      button.rotate360Degrees()
      signal.changeRotation(to: .left)
    } else {
      button.layer.removeAllAnimations()
      signal.changeRotation(to: .none)
    }
    
  }
  let rightRotationButton: RoundedButton = {
    let b = RoundedButton()
    b.setBackgroundImage(
      UIImage(named: "ios7-reload-right"),
      for: .normal)
    b.addTarget(
      self,
      action: #selector(rotateRight),
      for: .touchUpInside)
    b.isEnabled = false
    return b
  }()
  func rotateRight(_ button: UIButton) {
    button.isSelected = !button.isSelected
    if leftRotationButton.isSelected {
      leftRotationButton.isSelected = false
      leftRotationButton.layer.removeAllAnimations()
    }
    if button.isSelected {
      button.rotate360Degrees()
      signal.changeRotation(to: .right)
    } else {
      button.layer.removeAllAnimations()
      signal.changeRotation(to: .none)
    }
    
  }
  func startMotionUpdates() {
    guard motionManager.isAccelerometerAvailable else { return }
    motionManager.accelerometerUpdateInterval = TimeInterval(0.01)
    motionManager.showsDeviceMovementDisplay = true
    
    motionManager.startAccelerometerUpdates(
      to: .main,
      withHandler: { (accelerometerData, error) in
        guard let accelerometerData = accelerometerData else { return }
        
        let offsetCenter: double2 =
          [accelerometerData.acceleration.x,
           accelerometerData.acceleration.y]
        self.setAirplaneCenter(with: offsetCenter)
    })
  }
  func stopMotionUpdates() {
    guard motionManager.isAccelerometerAvailable else { return }
    motionManager.stopAccelerometerUpdates()
  }
  func setAirplaneCenter(with offsetCenter: double2) {
    let offsetX = offsetCenter.x
    let offsetY = offsetCenter.y
    
    if abs(offsetX) > abs(offsetY) && offsetX > 0 {
      signal.changeDirection(to: .right)
    }
    else if abs(offsetX) > abs(offsetY) && offsetX < 0 {
      signal.changeDirection(to: .left)
    }
    else if abs(offsetX) < abs(offsetY) && offsetY > 0 {
      signal.changeDirection(to: .ahead)
    }
    else if abs(offsetX) < abs(offsetY) && offsetY < 0 {
      signal.changeDirection(to: .back)
    }
    else {
      signal.changeDirection(to: .none)
    }
    
    print("offsetX: \(offsetX) ## offsetY: \(offsetY)")
    let originCenter = airplaneImageView.center
    let newCenter = CGPoint(
      x: Double(originCenter.x)+offsetX,
      y: Double(originCenter.y)-offsetY)
    if directionArea.contains(point: newCenter) {
      airplaneImageView.center = newCenter
    }
  }

  //MARK: - life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    
    view.addSubview(bottomView)
    view.addSubview(closeButton)
    view.addSubview(configButton)
    view.addSubview(serverLabel)
    view.addSubview(settingButton)
    view.addSubview(tcpUdpSegmentControl)
    
    view.addSubview(speedSlider)
    view.addSubview(openSwitcher)
    view.addSubview(speedMinimumValueLabel)
    view.addSubview(speedMaximunValueLabel)
    view.addSubview(speedCurrentValueLabel)
    view.addSubview(leftRotationButton)
    view.addSubview(rightRotationButton)
    
    view.addSubview(directionArea)
    view.addSubview(plusImageView)
    view.addSubview(airplaneImageView)
    directionArea.center = view.center
    plusImageView.center = view.center
    airplaneImageView.center = view.center
    
    isHeroEnabled = true
    
    host = (UserDefaults.standard.value(forKey: HOST) as? String) ?? "192.168.2.3"
    port = (UserDefaults.standard.value(forKey: PORT) as? Int) ?? 6666
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    bottomView.snp.makeConstraints { (make) in
      make.width.equalToSuperview()
      make.centerX.equalToSuperview()
      make.height.equalTo(LayoutConstant.bottomBarHeight)
      make.bottom.equalToSuperview()
    }
    closeButton.snp.makeConstraints { (make) in
      make.width.equalTo(LayoutConstant.itemWitdh)
      make.height.equalTo(LayoutConstant.itemHeight)
      make.bottom.equalToSuperview().offset(-LayoutConstant.itemBottomPadding)
      make.right.equalToSuperview().offset(-LayoutConstant.itemRightPadding)
    }
    serverLabel.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(20)
      make.width.equalTo(200)
      make.height.equalTo(50)
    }
    settingButton.snp.makeConstraints { (make) in
      make.size.equalTo(closeButton)
      make.left.equalToSuperview().offset(LayoutConstant.itemLeftPadding)
      make.bottom.equalToSuperview().offset(-LayoutConstant.itemBottomPadding)
    }
    configButton.snp.makeConstraints { (make) in
      make.size.equalTo(closeButton)
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().offset(-LayoutConstant.itemBottomPadding)
    }
    tcpUdpSegmentControl.snp.makeConstraints { (make) in
      make.width.equalToSuperview().multipliedBy(0.5)
      make.top.equalTo(serverLabel.snp.bottom).offset(10)
      make.centerX.equalToSuperview()
      make.height.equalTo(25)
    }
    
    speedSlider.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.width.equalToSuperview().multipliedBy(0.8)
      make.height.equalTo(20)
      make.top.equalTo(tcpUdpSegmentControl.snp.bottom).offset(25)
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
    speedCurrentValueLabel.snp.makeConstraints { (make) in
      make.width.equalTo(100)
      make.height.equalTo(11)
      make.centerX.equalTo(speedSlider)
      make.bottom.equalTo(speedSlider.snp.top).offset(-2)
    }
    openSwitcher.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().offset(-60)
    }
    leftRotationButton.snp.makeConstraints { (make) in
      make.size.equalTo(40)
      make.centerY.equalTo(openSwitcher)
      make.left.equalTo(20)
    }
    rightRotationButton.snp.makeConstraints { (make) in
      make.size.equalTo(leftRotationButton)
      make.centerY.equalTo(openSwitcher)
      make.right.equalTo(-20)
    }
    
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopMotionUpdates()
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
