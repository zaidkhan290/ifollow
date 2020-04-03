//
//  AudioRecorderSingleton.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 03/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import Foundation
import AVFoundation

class AudioRecorderSingleton: NSObject, AVAudioRecorderDelegate{
    
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    private static var sharedInstance: AudioRecorderSingleton?
    typealias completionBlock = (_ audioData: Data?) -> Void
    
    class var sharedManager : AudioRecorderSingleton {
        guard let sharedInstance = self.sharedInstance else {
            let sharedInstance = AudioRecorderSingleton()
            self.sharedInstance = sharedInstance
            return sharedInstance
        }
        return sharedInstance
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch {
            finishRecording(success: false, completion: nil)
        }
    }
    
    func cancelRecording(){
        if audioRecorder != nil{
            audioRecorder.stop()
            audioRecorder.deleteRecording()
            audioRecorder = nil
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool, completion: (completionBlock)? = nil) {
        audioRecorder.stop()
        print(audioRecorder.url)
        let data = try! Data(contentsOf: audioRecorder.url)
        audioRecorder = nil
        
        if success {
            completion!(data)
        } else {
            completion!(nil)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false, completion: nil)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
    }
    
    class func destroySingleton(){
        sharedInstance = nil
    }
}
