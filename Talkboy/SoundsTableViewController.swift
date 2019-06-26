//
//  SoundsTableViewController.swift
//  Talkboy
//
//  Created by Nahid on 25/6/19.
//  Copyright © 2019 Nahid. All rights reserved.
//

import UIKit
import AVFoundation

class SoundsTableViewController: UITableViewController {
    
    var sounds : [Sound] = []
    var audioPlayer : AVAudioPlayer?
    
    override func viewWillAppear(_ animated: Bool) {
        getSounds()
    }
    
    func getSounds() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let tempSounds = try? context.fetch(Sound.fetchRequest()) as? [Sound] {
                sounds = tempSounds
                tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sounds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        // Configure the cell...
        let soundToBeDisplayed = sounds[indexPath.row]
        cell.textLabel?.text = soundToBeDisplayed.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let soundToBePlayed = sounds[indexPath.row]
        if let audioData = soundToBePlayed.soundData {
            audioPlayer = try? AVAudioPlayer(data: audioData)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let soundToBeDeleted = sounds[indexPath.row]
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                context.delete(soundToBeDeleted)
            }
            getSounds()
        }
    }
}
