//
//  Global.swift
//  Cassini
//
//  Created by 周辉 on 2017/5/22.
//  Copyright © 2017年 周辉. All rights reserved.
//

import Foundation
import UIKit

struct Global {
  
  private init() {}
  
  static let ThemeColor = UIColor(red:0.13, green:0.13, blue:0.20, alpha:1.00)
  static let screenWidth: CGFloat = UIScreen.main.bounds.width
  static let screenHeight: CGFloat = UIScreen.main.bounds.height
  static let naviHeight: CGFloat = 64
  static let tabHeight: CGFloat = 49
}

let HOST = "CassiniHost"
let PORT = "CassiniPort"
let MSGLEADING = "c<"
let SPEED = "s"
let DIRECTION = "d"
let ROTATION = "r"

let CassiniJourneyDescription = "Saturn, get ready for your close-up! Today the Cassini spacecraft starts a series of swoops between Saturn and its rings. These cosmic acrobatics are part of Cassini's dramatic \"Grand Finale,\" a set of orbits offering Earthlings an unprecedented look at the second largest planet in our solar system.\n\n" +
  
  "By plunging into this fascinating frontier, Cassini will help scientists learn more about the origins, mass, and age of Saturn's rings, as well as the mysteries of the gas giant's interior. And of course there will be breathtaking additions to Cassini's already stunning photo gallery. Cassini recently revealed some secrets of Saturn's icy moon Enceladus -- including conditions friendly to life!  Who knows what marvels this hardy explorer will uncover in the final chapter of its mission?\n\n" +
  
"Cassini is a joint endeavor of NASA, the European Space Agency (ESA), and the Italian space agency (ASI). The spacecraft began its 2.2 billion–mile journey 20 years ago and has been hanging out with Saturn since 2004. Later this year, Cassini will say goodbye and become part of Saturn when it crashes through the planet’s atmosphere. But first, it has some spectacular sightseeing to do!"
