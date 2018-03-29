//
//  KingpinSession.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

class GameSession: ChatSession {
	
	// GAME STATE
	/// The players currently participating in the game.
	var players: [Player] = []
	
	/** The "game inventory", containing the currently available roles and valuables.
	Only the player currently at the vault can see what's inside it. */
	var vault = Vault()
	
	// SPECIALS
	/// If yes, test mode has been intiated which allows you to play as all the roles at once.
	private(set) var testMode: Bool = false
	
	override func postInit() {
		
		
	}
	
}
