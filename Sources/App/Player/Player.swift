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
class Player: UserProxy, Hashable, Equatable {
	
	// SESSION DATA
	var tag: SessionTag
	var userInfo: User
	
	// SESSION TYPES
	var baseRoute: Route
	var request: MethodRequest
	
	// CONVENIENCES
	var id: String
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
	
	// HASHABLE
	public var hashValue: Int {
		return id.hashValue ^ firstName.hashValue
	}
	
	
	// DESCRIPTION
	/// Returns the full name that a player is called in the game with full ID embedding.
	var name: String {
		return "[\(firstName)](tg://user?id=\(tag.id)) the \(char.rawValue)"
	}
	
	/// Returns the full name of a player without inline embedding.
	var plainName: String {
		return "\(firstName) the \(char.rawValue)"
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
	
	/** The vault route, that lets a player either view the vault if they are in front of it or view their
	current role (if they have selected one).  */
	var vaultRoute: RouteListen!
	
	/** The player route, that lets a player select another player.  This is reserved for the Kingpin */
	var playerRoute: RouteListen!
	
	/// Allows the player to view a cheat-sheet of all available in-game roles.
	var roleSheetRoute: RouteListen!
	
	/// The cards routed to the player for viewing when they click on the vault inline key.
	var inlineVaultCards: [InlineResultArticle] = []
	
	/// The inline key that should be used when trying to select a player.
	static var inlineKey = MarkupInlineKey(fromInlineQueryCurrent: "Players", text: "Interrogate Player")
	
	// CALLBACK
	fileprivate var session_closeProxy: (() -> ())
	
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
		
		self.vaultRoute = RouteListen(name: "vault_inline",
																	pattern: Vault.inlineKey.data,
																	type: .inlineQuery,
																	action: self.inlineVault)
		
		self.playerRoute = RouteListen(name: "player_inline",
																	 pattern: Player.inlineKey.data,
																	 type: .inlineQuery,
																	 action: self.inlinePlayerChoices)
		
		self.roleSheetRoute = RouteListen(name: "roleroute_inline",
																			pattern: KingpinRoles.inlineKey.data,
																			type: .inlineQuery,
																			action: self.inlineRoles)
		
		self.playerRoute.enabled = false
		
		self.baseRoute.addRoutes(vaultRoute, playerRoute, roleSheetRoute)
		self.baseRoute[["char_inline"]]?.enabled = false
		
		
	}
	
	
	func getInlineCard(id: String) -> InlineResultArticle {
		let title = self.plainName
		let description = "Accuse \(self.plainName)."
		let message = title
		return InlineResultArticle(id: id,
															 title: title,
															 description: description,
															 contents: message,
															 markup: nil)
	}
	
	func isEqualTo(_ other: UserProxy) -> Bool {
		if self.tag != other.tag { return false }
		if self.firstName != other.firstName { return false }
		if self.lastName != other.lastName { return false }
		if self.username != other.username { return false }
		
		return true
	}
	
	/**
	Resets all states relating to the owning session's properties and orders the session to drop the proxy.
	*/
	func close() {
		self.baseRoute.removeRoutes(vaultRoute, playerRoute, roleSheetRoute)
		session_closeProxy()
	}
	
	static func == (lhs: Player, rhs: Player) -> Bool {
		return lhs.isEqualTo(rhs)
	}
	
	/**
	Calculates a grammatically correct list of players as a string message, for use in declaring
	collections of players elegantly.
	*/
	public static func getListTextSUB(_ players: [Player]) -> String {
		
		var string = ""
		
		for (index, player) in players.enumerated() {
			if players.count == 1 {
				string += "\(player.name)"
			}
				
			else if index == players.count - 1 {
				string += "and \(player.name)"
			}
				
			else if index == players.count - 2 {
				string += "\(player.name) "
			}
				
			else {
				string += "\(player.name), "
			}
		}
		
		return string
	}
}
