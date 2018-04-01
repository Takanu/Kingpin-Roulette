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
	
	static var category = "Player Status"

	static var dead = Flair(withName: "Dead", category: category)
	
	static var winner = Flair(withName: "Winners", category: category)

}
