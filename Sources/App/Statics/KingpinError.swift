//
//  KingpinError.swift
//  App
//
//  Created by Ido Constantine on 20/04/2018.
//

import Foundation
import TrashBoat
import Pelican

enum KingpinError: String, Error {
  
  // Basic verification
  case wrongPlayerCount
  case noKingpinFound
  case noRoles
  case noOpals
  case missingPlayerRoles
  case verifyFailed
  
  // Game mode selection
  case noGameModeSelected
  case gameModeNotFound
  
  // Vault Errors
  case cardContentDowncastFailed
  case noCards
  
  // Vault Watch errors
  case vaultFoundIncorrectItem
  case watcherRemovedNonRoleItem
  
  // Interrogate Errors
  case noPlayerSelectionTargets
  case noPlayerReceived
  case kingpinPickedThemselves
}
