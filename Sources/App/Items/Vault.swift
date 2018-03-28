//
//  Vault.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

/**
Contains the valuables that are primed for theivin' and the currently available roles.
*/
class Vault {
	
	// STATE
	/// The roles currently available.
	var roles = Inventory()
	
	/// The amount of opals and other valuables currently available
	var valuables = PointManager()
	
	// ROUTING
	/// The player currently able to view and modify the vault.
	var currentViewer: Player?
	
	/// The inline key used to view the vault.  This has to be used in conjunction with a PlayerRoute.
	var inlineKey = MarkupInlineKey(fromCallbackData: "View Vault", text: "View Vault")
	
	init() { }
	
	/**
	Clears all current roles and valuables available, and populates the vault with new ones.
	*/
	func fillVault(roles: Inventory, valuables: PointManager) {
		clear()
		self.roles = roles
		self.valuables = valuables
	}
	
	/**
	Clears the vault of all roles and valuables.
	*/
	func clear() {
		self.roles.clearAll()
		//self.valuables
	}
	
	/**
	Defines a new player as the viewer of the vault, setting up their routes to be able to see the vault.
	*/
	func newRequest(viewer: Player) {
		
		
	}
	
	/**
	Generates a list of potential selections someone can make while visiting the Vault.
	
	- warning: Do not use this for the Kingpin, as this list includes selections for taking certain quantities of Opals.
	*/
	func generateVaultView() {
		
	}
	
	/**
	Generates a list of the current vault contents for the kingpin to inspect.
	*/
	func generateKingpinVaultView() {
		
	}
	
}
