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
	
	/// The route used to select a character.
	var characterRoute: RouteListen!
	
	override func postInit() {

		/// ROUTING
		self.characterRoute = RouteListen(name: "char_inline",
																			pattern: PlayerCharacter.inlineKey.data,
																			type: .inlineQuery,
																			action: self.inlineCharacter)
		
		// Build the "base" router, used to filter out blank updates.
		let baseClosure = { (update: Update) -> Bool in
			
			if update.from == nil { return false }
			if update.content == "" { return false }
			
			return true
		}
		
		self.baseRoute = RouteManual(name: "base", handler: baseClosure, routes: characterRoute)
		
		
		// My filter system isn't very good and I don't understand how I should limit content.  Not right now...
		
		/// FILTER
//		// Add a filter to restrict commands to one per time window.
//		let inlineFilter = UpdateFilterCondition(type: .inlineQuery, timeRange: 3.sec) { condition in
//
//			let queries = condition.records.filter( {
//				if $0.type != .inlineQuery { return false }
//				if $0.content == "" { return false }
//				return true
//			})
//
//			if queries.count > 2 { return false }
//			return true
//		}
//
//		self.filter.addCondition(inlineFilter)
		
		/// ANTI-FLOOD
		
	}
	
	/**
	Removes the proxy from the player session.  Used in a proxy callback to avoid the need to store the session.
	
	- warning: In this current version it will also close the game.
	*/
	func closeProxy() {
		self.proxy = nil
		self.baseRoute[["char_inline"]]?.enabled = true
		self.close()
	}
	
}
