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
  case wrongPlayerCount
  case noKingpinFound
  case noRoles
  case noOpals
  case missingPlayerRoles
  
  case verifyFailed
}
