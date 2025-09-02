import Foundation
import AVFoundation
import UIKit

// MARK: - Audio manager Implementation Cluck Farm

class CluckFarmAudioManager: NSObject, ObservableObject {
    static let shared = CluckFarmAudioManager()
    
    @Published var isMuted: Bool = false
    @Published var volume: Float = 1.0
    @Published var isAudioSessionActive: Bool = false
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var audioFile: AVAudioFile?
    
    private let userDefaults = UserDefaults.standard
    
    override init() {
        super.init()
        setupAudioSession()
        loadAudioSettings()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetooth])
            try audioSession.setActive(true)
            isAudioSessionActive = true
            
            setupAudioEngine()
        } catch {
            print("Failed to setup audio session: \(error)")
            isAudioSessionActive = false
        }
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        
        guard let engine = audioEngine, let player = playerNode else { return }
        
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func loadAudioSettings() {
        isMuted = userDefaults.bool(forKey: "CluckFarmAudioMuted")
        volume = userDefaults.float(forKey: "CluckFarmAudioVolume")
        if volume == 0 { volume = 1.0 }
    }
    
    func saveAudioSettings() {
        userDefaults.set(isMuted, forKey: "CluckFarmAudioMuted")
        userDefaults.set(volume, forKey: "CluckFarmAudioVolume")
    }
    
    func playCluckSound() {
        guard !isMuted, isAudioSessionActive else { return }
        
        // Generate synthetic cluck sound
        generateCluckTone(frequency: 800, duration: 0.3)
    }
    
    func playFarmAmbience() {
        guard !isMuted, isAudioSessionActive else { return }
        
        // Generate farm ambience
        generateAmbientTone(frequency: 200, duration: 2.0)
    }
    
    private func generateCluckTone(frequency: Float, duration: Float) {
        guard let engine = audioEngine, let player = playerNode else { return }
        
        let sampleRate = Float(engine.mainMixerNode.outputFormat(forBus: 0).sampleRate)
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: engine.mainMixerNode.outputFormat(forBus: 0), frameCapacity: frameCount) else { return }
        
        buffer.frameLength = frameCount
        
        let channels = Int(buffer.format.channelCount)
        let frames = Int(buffer.frameLength)
        
        for channel in 0..<channels {
            let channelData = buffer.floatChannelData![channel]
            for frame in 0..<frames {
                let time = Float(frame) / sampleRate
                let amplitude = sin(2.0 * Float.pi * frequency * time) * volume * 0.3
                channelData[frame] = amplitude * exp(-time * 3) // Decay envelope
            }
        }
        
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }
    
    private func generateAmbientTone(frequency: Float, duration: Float) {
        guard let engine = audioEngine, let player = playerNode else { return }
        
        let sampleRate = Float(engine.mainMixerNode.outputFormat(forBus: 0).sampleRate)
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: engine.mainMixerNode.outputFormat(forBus: 0), frameCapacity: frameCount) else { return }
        
        buffer.frameLength = frameCount
        
        let channels = Int(buffer.format.channelCount)
        let frames = Int(buffer.frameLength)
        
        for channel in 0..<channels {
            let channelData = buffer.floatChannelData![channel]
            for frame in 0..<frames {
                let time = Float(frame) / sampleRate
                let amplitude = sin(2.0 * Float.pi * frequency * time) * volume * 0.1
                channelData[frame] = amplitude
            }
        }
        
        player.scheduleBuffer(buffer, at: nil, options: [.loops], completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }
    
    func stopAllSounds() {
        playerNode?.stop()
    }
    
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        audioEngine?.mainMixerNode.outputVolume = volume
        saveAudioSettings()
    }
    
    func toggleMute() {
        isMuted.toggle()
        audioEngine?.mainMixerNode.outputVolume = isMuted ? 0.0 : volume
        saveAudioSettings()
    }
}
