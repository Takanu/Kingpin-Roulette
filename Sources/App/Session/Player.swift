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
	var status: UserProxyStatus
	var flair: FlairManager
	
	// ITEMS
	var inventory = Inventory()
	var points = PointManager()
	
	// INLINE CUSTOMISER
	var playerChoiceList: [InlineResultArticle]
	var playerBrowseList: [UserProxy]
	var itemSelect: [ItemTypeTag : [InlineResultArticle]]
	var inlineResultTransforms: [String : ([InlineResultArticle]) -> ([InlineResultArticle])]
	
	
	// DESCRIPTION
	/// Returns the full name that a player is called in the game with full ID embedding.
	var name: String {
		return "[\(info.firstName)](tg://user?id=\(tag.id)) the \(char?.rawValue ?? "UNNAMED")"
	}
	
	/// Returns the full name of a player without inline embedding.
	var plainName: String {
		return "\(info.firstName) the \(char?.rawValue ?? "UNNAMED")"
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
	
	
	func getInlineCard(id: String) -> InlineResultArticle {
		<#code#>
	}
	
	func isEqualTo(_ other: UserProxy) -> Bool {
		<#code#>
	}
	
	
	
	
}
