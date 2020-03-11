//
//  AudioRecordViewController.swift
//  AudioComments-Afternoon
//
//  Created by Austin Potts on 3/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecordViewController: UIViewController {


      @IBOutlet var playButton: UIButton!
      @IBOutlet var recordButton: UIButton!
      @IBOutlet var timeElapsedLabel: UILabel!
      @IBOutlet var timeRemainingLabel: UILabel!
      @IBOutlet var timeSlider: UISlider!
      @IBOutlet var audioVisualizer: AudioVisualizer!
      
      
      //MARK: - Audio Player Property
      var audioPlayer: AVAudioPlayer? {
          didSet {
              guard let audioPlayer = audioPlayer else {return}
              audioPlayer.delegate = self
              audioPlayer.isMeteringEnabled = true
          }
      }
      
      var audioRecorder: AVAudioRecorder?
      
      var recordingURL: URL?
      
      var timer: Timer?
      
      private lazy var timeIntervalFormatter: DateComponentsFormatter = {
          // NOTE: DateComponentFormatter is good for minutes/hours/seconds
          // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
          
          let formatting = DateComponentsFormatter()
          formatting.unitsStyle = .positional // 00:00  mm:ss
          formatting.zeroFormattingBehavior = .pad
          formatting.allowedUnits = [.minute, .second]
          return formatting
      }()
      
      
      // MARK: - View Controller Lifecycle
      
      override func viewDidLoad() {
          super.viewDidLoad()
          
          // Use a font that won't jump around as values change
          timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                            weight: .regular)
          timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                     weight: .regular)
          
          loadAudio()
          updateViews()
          try? prepareAudioSession() //TODO: Error Handling
      }
      
      deinit {
          cancelTimer()
      }
      
      func updateViews() {
          
          playButton.isSelected = isPlaying
          recordButton.isSelected = isRecording
          
          let elapsedTime = audioPlayer?.currentTime ?? 0
          let duration = audioPlayer?.duration ?? 0
          
          timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
          
          timeSlider.value = Float(elapsedTime)
          timeSlider.minimumValue = 0
          timeSlider.maximumValue = Float(duration)
          
          
          
          
      }
      
      
      // MARK: - Timer
      
      
      func startTimer() {
          timer?.invalidate()
          
          timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
              guard let self = self else { return }
              
             
              
              self.updateViews()
              
              if let audioRecorder = self.audioRecorder,
                  self.isRecording == true {

                  audioRecorder.updateMeters()
                  self.audioVisualizer.addValue(decibelValue: audioRecorder.averagePower(forChannel: 0))

              }
              
              if let audioPlayer = self.audioPlayer,
                  self.isPlaying == true {
              
                  audioPlayer.updateMeters()
                  self.audioVisualizer.addValue(decibelValue: audioPlayer.averagePower(forChannel: 0))
              }
          }
      }
      
      func cancelTimer() {
          timer?.invalidate()
          timer = nil
      }
      
      
      
      // MARK: - Playback
      
      var isPlaying: Bool {
          // when the audio player is nil that means theres no resource loaded to play
          audioPlayer?.isPlaying ?? false
      }
      
      func loadAudio() {
          
          //TODO: Clean Up for production, good for prototyping, we want to crash to find issues
          let songURL = Bundle.main.url(forResource: "piano copy", withExtension: "mp3")!
          
          audioPlayer = try! AVAudioPlayer(contentsOf: songURL) //Crash if resource cannot be loaded
          //FIXME: Use error Handling if crash
          
      }
      
      // If you don't set active on a device, record won't work or other bad behaviors
      func prepareAudioSession() throws {
          let session = AVAudioSession.sharedInstance()
          try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
          try session.setActive(true, options: []) // can fail if on a phone call, for instance
      }
      
      
      
      
      func play() {
          
          audioPlayer?.play()
          updateViews()
          startTimer()
          
      }
      
      func pause() {
          audioPlayer?.pause()
          updateViews()
          cancelTimer()
      }
      
      
      // MARK: - Recording
      
      var isRecording: Bool {
          return audioRecorder?.isRecording ?? false
      }
      
      func createNewRecordingURL() -> URL {
          let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
          
          let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
          let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
          
  //        print("recording URL: \(file)")
          
          return file
      }
      
      
      func requestPermissionOrStartRecording() {
          switch AVAudioSession.sharedInstance().recordPermission {
          case .undetermined:
              AVAudioSession.sharedInstance().requestRecordPermission { granted in
                  guard granted == true else {
                      print("We need microphone access") // Privacy for micorphone denied
                      return
                  }
                  
                  print("Recording permission has been granted!")
                  // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
              }
          case .denied:
              print("Microphone access has been blocked.")
              
              let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
              
              alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                  UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
              })
              
              alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
              
              present(alertController, animated: true, completion: nil)
          case .granted:
              startRecording()
          @unknown default:
              break
          }
      }
      
      
      func startRecording() {
          
          let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
          
         let recordingURL = createNewRecordingURL()
          audioRecorder = try? AVAudioRecorder(url: recordingURL, format: format)
          audioRecorder?.record()
          self.recordingURL = recordingURL
          
          audioRecorder?.delegate = self
          audioRecorder?.isMeteringEnabled = true
          
          updateViews()
          
      }
      
      func stopRecording() {
          audioRecorder?.stop()
          updateViews()
          
      }
      
      // MARK: - Actions
      
      @IBAction func togglePlayback(_ sender: Any) {
          if isPlaying {
              pause()
          } else {
              play()
          }
          
      }
      
      @IBAction func updateCurrentTime(_ sender: UISlider) {
          
      }
      
      @IBAction func toggleRecording(_ sender: Any) {
          if isRecording {
              stopRecording()
          } else {
              requestPermissionOrStartRecording()
          }
          
      }
  }

  extension AudioRecordViewController: AVAudioPlayerDelegate {
      
      func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
          print("audioPlayerDidFinishPlaying.flag = \(flag)")
         
              cancelTimer()
              updateViews()
        
      }
      
      //Helps us debug audio files
      func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
          if let error = error {
              print("Error decoding audi: \(error)")
          }
          cancelTimer()
          updateViews()
      }
  }

  extension AudioRecordViewController: AVAudioRecorderDelegate {
      func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
          if let error = error {
              print("Error saving to disk\(error)")
          }
          updateViews()
      }
      
      func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
          guard let recordingURL = recordingURL else {return}
          
          audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL) //TODO: Error Handle
          
          updateViews()
          
          
      }
      
  }
