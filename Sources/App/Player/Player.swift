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
	var status = UserProxyStatus.idle
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
		return "[\(firstName)](tg://user?id=\(tag.id)) the \(char.rawValue ?? "UNNAMED")"
	}
	
	/// Returns the full name of a player without inline embedding.
	var plainName: String {
		return "\(firstName) the \(char.rawValue ?? "UNNAMED")"
	}
	
	/// Returns the user as a secret inline symbol, used for group or stealth mentions.
	var mention: String {
		return "[●](tg://user?id=\(tag.id))"
	}
	
	// GAME STATE
	/// Their selected character.
	var char: PlayerCharacter
	
	/// The role the player is.
	var role: KingpinRole?
	
	/// The route used to select a character.
	var characterRoute: RouteListen!
	
	/** The vault route, that lets a player either view the vault if they are in front of it or view their
	current role (if they have selected one).  */
	var vaultRoute: RouteListen!
	
	/// The cards routed to the player for viewing when they click on the vault inline key.
	var inlineVaultCards: [InlineResultArticle] = []
	
	
	// CALLBACK
	var session_closeProxy: (() -> ())
	
	init(session: PlayerSession, userInfo: User, character: PlayerCharacter) {
		self.tag = session.tag
		self.userInfo = userInfo
		
		self.baseRoute = session.baseRoute
		self.request = session.requests
		self.id = session.tag.id
		self.firstName = userInfo.firstName
		self.lastName = userInfo.lastName
		self.username = userInfo.username
		
		self.char = character
		self.session_closeProxy = session.closeProxy
		
		self.characterRoute = RouteListen(name: "char_inline",
																			pattern: PlayerCharacter.inlineKey.data,
																			type: .inlineQuery,
																			action: self.inlineCharacter)
		
		self.vaultRoute = RouteListen(name: "vault_inline",
																	pattern: Vault.inlineKey.data,
																	type: .inlineQuery,
																	action: self.inlineVault)
		
		
	}
	
	
	func getInlineCard(id: String) -> InlineResultArticle {
		let title = self.plainName
		let description = "Accuse \(name)."
		let message = title
		return InlineResultArticle(id: id, title: title, description: description, contents: message, markup: nil)
	}
	
	func isEqualTo(_ other: UserProxy) -> Bool {
		if self.tag != other.tag { return false }
		if self.firstName != other.firstName { return false }
		if self.lastName != other.lastName { return false }
		if self.username != other.username { return false }
		
		return true
	}
	
	
	
	
}
