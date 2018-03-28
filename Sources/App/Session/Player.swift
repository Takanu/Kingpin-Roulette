//
//  KingpinPlayer.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

/**
Defines a player of Kingpin Roulette.
*/
class Player: UserProxy {
	
	// SESSION DATA
	var tag: SessionTag
	var userInfo: User
	
	// SESSION TYPES
	var baseRoute: Route
	var request: SessionRequest
	
	// CONVENIENCES
	var id: Int
	var firstName: String
	var lastName: String?
	var username: String?
	
	// STATUS
	var status: UserProxyStatus = .playing
	var flair = FlairManager()
	
	// ITEMS
	var inventory = Inventory()
	var points = PointManager()
	
	// INLINE CUSTOMISER
	var playerChoiceList: [InlineResultArticle] = []
	var playerBrowseList: [UserProxy] = []
	var itemSelect: [ItemTypeTag : [InlineResultArticle]] = [:]
	var inlineResultTransforms: [String : ([InlineResultArticle]) -> ([InlineResultArticle])] = [:]
	
	
	// DESCRIPTION
	/// Returns the full name that a player is called in the game with full ID embedding.
	var name: String {
		return "[\(firstName)](tg://user?id=\(tag.id)) the \(char?.rawValue ?? "UNNAMED")"
	}
	
	/// Returns the full name of a player without inline embedding.
	var plainName: String {
		return "\(firstName) the \(char?.rawValue ?? "UNNAMED")"
	}
	
	/// Returns the user as a secret inline symbol, used for group or stealth mentions.
	var mention: String {
		return "[●](tg://user?id=\(tag.id))"
	}
	
	// GAME STATE
	/// Their selected character.
	var char: PlayerCharacter?
	
	/// The role the player is.
	var role: KingpinRole?
	
	/** The vault route, that lets a player either view the vault if they are in front of it or view their
	current role (if they have selected one).  */
	var vaultRoute: RouteListen
	
	
	init(session: UserSession) {
		self.tag = session.tag
		self.userInfo = session.info
		
		self.baseRoute = session.baseRoute
		self.request = session.requests
		self.id = session.tag.id
		self.firstName = session.info.firstName
		self.lastName = session.info.lastName
		self.username = session.info.username
	}
	
	
	func getInlineCard(id: String) -> InlineResultArticle {
		let title = self.plainName
		let description = "Accuse \(name)."
		let message = title
		return InlineResultArticle(id: id, title: title, description: description, contents: message, markup: nil)
	}
	
	func isEqualTo(_ other: UserProxy) -> Bool {
		<#code#>
	}
	
	
	
	
}
