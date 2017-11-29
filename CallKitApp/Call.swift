//
//  Call.swift
//  CallKitApp
//
//  Created by Максимычев Е.О. on 29/11/2017.
//  Copyright © 2017 Максимычев Е.О. All rights reserved.
//

import Foundation

enum CallState {
	case connecting
	case active
	case held
	case ended
}

enum ConnectedState {
	case pending
	case complete
}

class Call {
	
	let uuid: UUID
	let outgoing: Bool
	let handle: String
	
	var videoEnabled: Bool
	
	var state: CallState = .ended {
		didSet {
			stateChanged?()
		}
	}
	
	var connectedState: ConnectedState = .pending {
		didSet {
			connectedStateChanged?()
		}
	}
	
	var stateChanged: (() -> Void)?
	var connectedStateChanged: (() -> Void)?
	
	init(uuid: UUID, outgoing: Bool = false, handle: String, videoEnabled: Bool) {
		self.uuid = uuid
		self.outgoing = outgoing
		self.handle = handle
		self.videoEnabled = videoEnabled
	}
	
	func start(completion: ((_ success: Bool) -> Void)?) {
		completion?(true)
		
		DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 3) {
			self.state = .connecting
			self.connectedState = .pending
			
			DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 1.5) {
				self.state = .active
				self.connectedState = .complete
			}
		}
	}
	
	func answer() {
		state = .active
	}
	
	func end() {
		state = .ended
	}
	
}
