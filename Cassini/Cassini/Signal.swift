//
//  Signal.swift
//  Cassini
//
//  Created by 周辉 on 2017/5/22.
//  Copyright © 2017年 周辉. All rights reserved.
//

import Foundation

class Signal {
  
  var message: String {
    return "c<"+"s"+currentSpeed+"d"+currentDirection+"r"+currentRotation
  }
  var currentSpeed: String = "050"
  var currentDirection: String = "0"
  var currentRotation: String = "0"
  
  enum Direction {
    case none, ahead, back, left, right
  }
  
  enum Rotation {
    case none, left, right
  }
  
  func reset() {
    currentSpeed = "050"
    currentDirection = "0"
    currentRotation = "0"
  }
  
  func shutdown() {
    currentSpeed = "000"
    currentDirection = "0"
    currentRotation = "0"
  }
  
  func changeSpeed(to speed: Int) {
    let speedString: String
    if speed > 100 {
      speedString = "100"
    } else if speed < 0 {
      speedString = "000"
    } else {
      speedString = String(format: "%03d", speed)
    }
    currentSpeed = speedString
  }
  func changeDirection(to direction: Direction) {
    let directionString: String
    switch direction {
    case .none:
      directionString = "0"
    case .ahead:
      directionString = "1"
    case .back:
      directionString = "2"
    case .left:
      directionString = "3"
    case .right:
      directionString = "4"
    }
    currentDirection = directionString
  }
  func changeRotation(to rotation: Rotation) {
    let rotationString: String
    switch rotation {
    case .none:
      rotationString = "0"
    case .left:
      rotationString = "1"
    case .right:
      rotationString = "2"
    }
    currentRotation = rotationString
  }
}
