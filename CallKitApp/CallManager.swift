//
//  CallManager.swift
//  CallKitApp
//
//  Created by Максимычев Е.О. on 29/11/2017.
//  Copyright © 2017 Максимычев Е.О. All rights reserved.
//

import Foundation

final class CallManager {
	
	static let shared = CallManager()
	
	private var calls = [Call]()
	
	func callWithUUID(uuid: UUID) -> Call? {
		guard let call = calls.first(where: {$0.uuid == uuid}) else {
			return nil
		}
		
		return call
	}
	
	func add(call: Call) {
		calls.append(call)
	}
	
	func remove(call: Call) {
		guard let index = calls.index(where: { $0 === call }) else { return }
		calls.remove(at: index)
	}
	
	func removeAllCalls() {
		calls.removeAll()
	}
	
}
