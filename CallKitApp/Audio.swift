//
//  Audio.swift
//  CallKitApp
//
//  Created by Максимычев Е.О. on 29/11/2017.
//  Copyright © 2017 Максимычев Е.О. All rights reserved.
//

import AVFoundation

func configureAudioSession() {
	print("Configuring audio session")
	let session = AVAudioSession.sharedInstance()
	do {
		try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
		try session.setMode(AVAudioSessionModeVoiceChat)
	} catch (let error) {
		print("Error while configuring audio session: \(error)")
	}
}

func startAudio() {
	print("Starting audio")
}

func stopAudio() {
	print("Stopping audio")
}
