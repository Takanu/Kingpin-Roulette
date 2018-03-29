//
//  PlayerSession.swift
//  App
//
//  Created by Ido Constantine on 29/03/2018.
//

import Foundation
import TrashBoat
import Pelican

/**
Defines a few extra things from the usual UserSession.
*/
class PlayerSession: UserSession {
	
	/// The proxies this player is in control of during a test.
	var testProxies: [Player] = []
	
	/// The proxy this player is in control of during a normal game.
	var proxy: Player?
	
	override func postInit() {

		/// BASIC ROUTE
		// Build the "base" router, used to filter out blank updates.
		let baseClosure = { (update: Update) -> Bool in
			
			if update.from == nil { return false }
			if update.content == "" { return false }
			
			return true
		}
		
		self.baseRoute = RouteManual(name: "base", handler: baseClosure)
		
		
		/// ANTI-FLOOD
		
	}
	
	/**
	Removes the proxy from the player session.  Used in a proxy callback to avoid the need to store the session.
	*/
	func closeProxy() {
		self.proxy = nil
	}
	
}
