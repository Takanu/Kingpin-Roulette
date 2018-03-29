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

Is also a route, and allows players who are in front of it to view its contents and take something from it.
*/
class Vault: Route {
	
	/// Defines a generated card and an item that it represents.
	typealias VaultResult = (item: ItemRepresentible, card: InlineResultArticle)
	
	// STATE
	/// The roles currently available.
	var roles = Inventory()
	
	/// The amount of opals and other valuables currently available
	var valuables = PointManager()
	
	
	// ROUTING
	/// The player currently able to view and modify the vault.
	var currentViewer: Player?
	
	/// The inline key used to view the vault.  This has to be used in conjunction with a PlayerRoute.
	static var inlineKey = MarkupInlineKey(fromCallbackData: "View Vault", text: "View Vault")!
	
	
	// ROUTE CONTENTS + CHECKS
	/// If we need to setup a Message route to listen for a response, this is the closure we should call once a result is received.
	var next: ((ItemRepresentible) -> ())?
	
	/// The cards generated by a new request.  Will be nil if the request was reset.
	var vaultDisplay: [VaultResult]?
	
	
	init() {
		
		super.init(name: "vault_message", action: {P in return true})
		
	}
	
	/**
	Clears all current roles and valuables available, and populates the vault with new ones.
	*/
	func fillVault(roles: Inventory, valuables: PointManager) {
		clear()
		self.roles = roles
		self.valuables = valuables
		self.roles.inlineCardTitle = "$name ($count left)"
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
	func newRequest(newViewer: Player, next: ((ItemRepresentible) -> ())? ) {
		
		// Set the current viewer
		currentViewer = newViewer
		
		var vaultContents: [VaultResult] = []
		
		// If this is just for the kingpin, we just need to get some cards and give them to him with no routing.
		if newViewer.role?.definition == .kingpin {
			vaultContents = generateKingpinVaultView()
			
		}
		
		// If it's for anyone else, we need to generate a set of cards but also open message routing.
		else {
			vaultContents = generateVaultView()
			
		}
		
		// Set the cards to the Vault and player, and enable routing.
		currentViewer!.inlineVaultCards = vaultContents.map { $0.card }
		self.vaultDisplay = vaultContents
		
		// Enable the route for operation.
		self.enabled = true
		
	}
	
	/**
	Handle text requests to find a valid response.
	*/
	override func handle(_ update: Update) -> Bool {
		
		// Validate source
		if currentViewer == nil {
			print("\(#line) \(#function) - Vault route set, but no viewer present.")
			return false
		}
		
		if vaultDisplay == nil {
			print("\(#line) \(#function) - Vault route set, but no options available.")
			return false
		}
		
		if update.id != currentViewer?.id { return false }
		if update.content == "" { return false }
		
		// Validate against current cards
		for option in vaultDisplay! {
			let card = option.card
			
			guard let content = card.content?.base as? InputMessageContent_Text else {
				print("\(#line) \(#function) - Card content downcast failed during Vault handling.")
				return false
			}
			
			// Find entity that matches generated card signature
			if update.content == content.text {
				
				// Remove the item from the valuables or roles list.
				if let item = roles.removeItem(option.item) {
					
					let role = item as! KingpinRole
					currentViewer!.role = role
					
					currentViewer = nil
					next?(item)
				}
				
				// If it's not a role, convert it to an opal and deduct the amount from the valuables.
				if option.item.type == KingpinDefault.opalItemTag {
					
					let opalsStolen = option.item as! OpalUnit
					let opalValue = opalsStolen.unit.value.intValue
					valuables.changeCurrency(opalsStolen.unit.type, change: .int(opalValue * -1))
						
					currentViewer!.points.addCurrency(KingpinDefault.opal, initialAmount: opalsStolen.unit.value)
					currentViewer!.role = KingpinRoles.thief
					
					currentViewer = nil
					next?(opalsStolen)
					
				}
				
				else {
					print("\(#line) \(#function) - Item match found, but couldn't be routed.")
				}
			}
		}
		
		return false
	}
	
	
	/**
	Generates a list of potential selections someone can make while visiting the Vault.
	
	- warning: Do not use this for the Kingpin, as this list includes selections for taking certain quantities of Opals.
	*/
	func generateVaultView() -> [VaultResult] {
		
		// Create an id counter and result dictionary
		var id = 1
		var cardSet: [VaultResult] = []
		
		// Get the list of items available from the inventory.
		guard let roleCards = roles.getInlineCards(forType: KingpinRoles.type) else {
			print("\(#line) \(#function) - Role Cards Couldnt Be Found! D:")
			return []
		}
		
		// Get the item info and link it to the results
		var roleItems = roles.getItemCopies(forType: KingpinRoles.type.name)!
		for (i, card) in roleCards.enumerated() {
			card.tgID = "\(id)"
			id += 1
			cardSet.append((roleItems[i], card))
		}
		
		// Generate a list of choices when taking opals.
		guard let opalCount = valuables[KingpinDefault.opal] else {
			print("\(#line) \(#function) - Opals Couldnt Be Found! D:")
			return []
		}
		
		let opalMax = max(min(5, opalCount.intValue), 0)
		for i in 1...opalMax {
			
			var name = ""
			if i > 1 {
				name = "\(i) Opal"
			} else {
				name = "\(i) Opals"
			}
			
			let opalUnit = OpalUnit(name: name,
															pluralisedName: name,
															type: KingpinDefault.opalItemTag,
															description: name,
															unitValue: .int(i))
			
			let newOpalCard = InlineResultArticle(id: "\(id)",
																						title: "Steal \(i) 💎 Opals (\(opalCount.intValue) left)",
																						description: KingpinRoles.thief.description,
																						contents: "",
																						markup: nil)
			cardSet.append((opalUnit, newOpalCard))
			id += 1
		}
		
		
		// Replace the contents with a series of unique characters to keep the choice a secret.
		let anonymisedCardSet = anonymiser(options: cardSet)
		return anonymisedCardSet
		
	}
	
	/**
	Generates a simpler list of the current vault contents for the kingpin to inspect.
	*/
	func generateKingpinVaultView() -> [VaultResult] {
	
		// Create an id counter and result dictionary
		var id = 1
		var cardSet: [VaultResult] = []
		
		// Get the list of items available from the inventory.
		guard let roleCards = roles.getInlineCards(forType: KingpinRoles.type) else {
			print("\(#line) \(#function) - Role Cards Couldnt Be Found! D:")
			return []
		}
		
		// Get the item info and link it to the results
		var itemInfo = roles.getItemCopies(forType: KingpinRoles.type.name)!
		for (i, card) in roleCards.enumerated() {
			card.tgID = "\(id)"
			id += 1
			cardSet.append((itemInfo[i], card))
		}
		
		// Generate the total number of opals left as a card.
		guard let opalCount = valuables[KingpinDefault.opal] else {
			print("\(#line) \(#function) - Opals Couldnt Be Found! D:")
			return []
		}
		
		var opalItemName = ""
		if opalCount.intValue > 1 {
			opalItemName = "\(opalCount) Opal"
		} else {
			opalItemName = "\(opalCount) Opals"
		}
		
		let opalUnit = OpalUnit(name: opalItemName,
														pluralisedName: opalItemName,
														type: KingpinDefault.opalItemTag,
														description: opalItemName,
														unitValue: .int(opalCount.intValue))
		
		let newOpalCard = InlineResultArticle(id: "\(id)",
																					title: "\(opalCount) 💎 Opals.",
			description: KingpinRoles.thief.description,
			contents: "",
			markup: nil)
		
		// Return the new set.
		cardSet.append((opalUnit, newOpalCard))
		
		return cardSet
		
	}
	
	/**
	Anonymises inline result contents with a unique code.
	*/
	func anonymiser(options: [VaultResult]) -> [VaultResult] {
		
		let glyphs = ["o", "-", "|", "•"]
		var codes: [String] = []
		var results: [VaultResult] = []
		
		for (_, optionSet) in options.enumerated() {
			let optionItem = optionSet.item
			let optionCard = optionSet.card
			
			var newCode = glyphs.randomSelection(length: 16)!.joined()
			
			// Shuffle until we have a unique sequence.
			while codes.contains(newCode) == true {
				newCode = glyphs.randomSelection(length: 16)!.joined()
			}
			
			// Build the card and add the sequence to the list.
			codes.append(newCode)
			let newCard = InlineResultArticle(id: optionCard.tgID,
																					title: optionCard.title,
																					description: optionCard.description ?? "",
																					contents: newCode,
																					markup: nil)
			
			results.append((optionItem, newCard))
		}
		
		return results
	}
	
}
