//
//  ViewController.swift
//  CallKitApp
//
//  Created by Максимычев Е.О. on 29/11/2017.
//  Copyright © 2017 Максимычев Е.О. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	// MARK: - Properties
	
	private var callProvider: CallKitProvider? {
		didSet {
			callProvider?.delegate = self
		}
	}
	
	fileprivate var currentController: UIViewController?
	fileprivate var currentCall: Call?

	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		callProvider = CallKitProvider()
	}
	
	// MARK: - Private
	
	fileprivate func showController(with identifier: String) {
		let controller = viewController(with: identifier)
		closeController()
		showController(controller)
	}
	
	fileprivate func closeController() {
		guard let controller = currentController else {
			return
		}
		
		controller.dismiss(animated: true, completion: nil)
	}
	
	private func showController(_ controller: UIViewController) {
		present(controller, animated: true, completion: nil)
		currentController = controller
	}
	
	private func viewController(with identifier: String) -> UIViewController {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: identifier)
	}
	
	// MARK: - Actions
	
	@IBAction func incomingCallButtonTapped(_ sender: Any) {
		let call = Call(uuid: UUID(), handle: "Maximychev Evgeny", videoEnabled: true)
		callProvider?.reportIncomingCall(call)
		currentCall = call
	}
	
	@IBAction func outcomingCallButtonTapped(_ sender: Any) {
		let call = Call(uuid: UUID(), handle: "Maximychev", videoEnabled: true)
		callProvider?.startCall(call)
		currentCall = call
	}
	
	@IBAction func unwindToMain(segue:UIStoryboardSegue) {
		guard let call = currentCall else {
			return
		}
		
		callProvider?.endCall(call)
	}
	
}

// MARK: - CallKitProviderDelegate

extension ViewController: CallKitProviderDelegate {
	
	func callProvider(_ provider: CallKitProvider, perform event: CallProviderEvent) {
		switch event {
		case .startCall:
			showController(with: "OutgoingViewController")
		case .answerCall:
			showController(with: "SpeakingViewController")
		case .endCall:
			closeController()
		case .providerDidReset:
			closeController()
		}
	}
	
	
}
