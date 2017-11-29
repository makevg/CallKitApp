//
//  CallKitProvider.swift
//  CallKitApp
//
//  Created by Максимычев Е.О. on 29/11/2017.
//  Copyright © 2017 Максимычев Е.О. All rights reserved.
//

import CallKit

enum CallProviderEvent {
	case startCall
	case answerCall
	case endCall
	case providerDidReset
}

protocol CallKitProviderDelegate: class {
	func callProvider(_ provider: CallKitProvider, perform event: CallProviderEvent)
}

final class CallKitProvider: NSObject {
	
	fileprivate let provider: CXProvider
	fileprivate let callController = CXCallController()
	fileprivate let callManager = CallManager.shared
	
	static var providerConfiguration: CXProviderConfiguration {
		let providerConfiguration = CXProviderConfiguration(localizedName: "CallKitApp")
		
		providerConfiguration.supportsVideo = true
		providerConfiguration.maximumCallsPerCallGroup = 1
		providerConfiguration.supportedHandleTypes = [.generic]
		
		return providerConfiguration
	}
	
	weak var delegate: CallKitProviderDelegate?
	
	// MARK: - Init
	
	override init() {
		provider = CXProvider(configuration: CallKitProvider.providerConfiguration)
		super.init()
		provider.setDelegate(self, queue: nil)
	}
	
	// MARK: - Public
	
	func reportIncomingCall(_ call: Call) {
		let update = CXCallUpdate()
		update.remoteHandle = CXHandle(type: .generic, value: call.handle)
		update.hasVideo = call.videoEnabled
		
		provider.reportNewIncomingCall(with: call.uuid, update: update) { error in
			if error == nil {
				self.callManager.add(call: call)
			}
		}
	}
	
	func startCall(_ call: Call) {
		let handle = CXHandle(type: .generic, value: call.handle)
		let startCallAction = CXStartCallAction(call: call.uuid, handle: handle)
		startCallAction.isVideo = call.videoEnabled
		let transaction = CXTransaction(action: startCallAction)
		
		requestTransaction(transaction) { error in
			if error == nil {
				self.callManager.add(call: call)
			}
		}
	}
	
	func endCall(_ call: Call) {
		let endCallAction = CXEndCallAction(call: call.uuid)
		let transaction = CXTransaction(action: endCallAction)
		
		requestTransaction(transaction)
	}
	
	// MARK: - Private
	
	private func requestTransaction(_ transaction: CXTransaction, _ completion: ((Error?) -> Void)? = nil) {
		callController.request(transaction) { error in
			if let error = error {
				print("Error requesting CallKit transaction: \(error)")
			}
			
			completion?(error)
		}
	}
	
}

// MARK: - CXProviderDelegate

extension CallKitProvider: CXProviderDelegate {
	
	func providerDidReset(_ provider: CXProvider) {
		delegate?.callProvider(self, perform: .providerDidReset)
	}
	
	func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
		guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
			action.fail()
			return
		}
		
		delegate?.callProvider(self, perform: .startCall)
		action.fulfill()
	}
	
	func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
		guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
			action.fail()
			return
		}
		
		delegate?.callProvider(self, perform: .answerCall)
		action.fulfill()
	}
	
	func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
		guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
			action.fail()
			return
		}
		
		delegate?.callProvider(self, perform: .endCall)
		callManager.remove(call: call)
		action.fulfill()
	}
	
}
