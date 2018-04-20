//
//  KingpinFlair.swift
//  App
//
//  Created by Ido Constantine on 31/03/2018.
//

import Foundation
import TrashBoat
import Pelican

/**
Used to codify the few player states required for the game to operate.
*/
struct KingpinFlair {
	
	static var statusCategory = "Player Status"
  static var presentCategory = "Received Present"

	static var dead = Flair(withName: "Dead", category: statusCategory)
	
	static var winner = Flair(withName: "Winners", category: statusCategory)
  
  static var accident = Flair(withName: "Accidental Death", category: statusCategory)

  static var giftReceived = Flair(withName: "Got a Present", category: presentCategory)
}
