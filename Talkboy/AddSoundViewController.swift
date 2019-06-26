//
//  AddSoundViewController.swift
//  Talkboy
//
//  Created by Nahid on 25/6/19.
//  Copyright © 2019 Nahid. All rights reserved.
//

import UIKit
import AVFoundation

class AddSoundViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    var audioRecorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playButton.isEnabled = false
        addButton.isEnabled = false
        
        // Session
        micSetup()
    }
    
    func micSetup() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        
        // URL for saving
        if let basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let filepatharray = [basePath, "dasound.m4a"]
            if let audioURL = NSURL.fileURL(withPathComponents: filepatharray) {
                var settings : [String:Any] = [:]
                settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
                settings[AVSampleRateKey] = 44_100.0
                settings[AVNumberOfChannelsKey] = 2
                
                audioRecorder = try? AVAudioRecorder(url: audioURL, settings: settings)
                audioRecorder?.prepareToRecord()
            }
        }
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        if let player = audioPlayer {
            if player.isPlaying {
                stopPlaying()
            } else {
                startPlaying()
            }
        } else {
            startPlaying()
        }
    }
    
    func startPlaying() {
        if let audioURL = audioRecorder?.url {
            audioPlayer = try? AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            playButton.setTitle("Stop", for: .normal)
            recordButton.isEnabled = false
            addButton.isEnabled = false
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        enableAddAndRecord()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        enableAddAndRecord()
    }
    
    func enableAddAndRecord() {
        playButton.setTitle("Play", for: .normal)
        recordButton.isEnabled = true
        addButton.isEnabled = true
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        if let recorder = audioRecorder {
            if recorder.isRecording {
                // Stop recording
                recorder.stop()
                recordButton.setTitle("Record", for: .normal)
                playButton.isEnabled = true
                addButton.isEnabled = true
            } else {
                // Start recording
                recorder.record()
                recordButton.setTitle("Stop", for: .normal)
                playButton.isEnabled = false
                addButton.isEnabled = false
            }
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        if let context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext) {
            let soundToBeSaved = Sound(context: context)
            soundToBeSaved.name = nameTextField.text
            
            if let audioURL = audioRecorder?.url {
                soundToBeSaved.soundData = try? Data(contentsOf: audioURL)
                try? context.save()
                navigationController?.popViewController(animated: true)
            }
        }
    }
}
