import Foundation
import AVFoundation

enum SpeechService {
    static let synthesizer = AVSpeechSynthesizer()

    static func speak(_ text: String, language: String = "en-US") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.48
        synthesizer.speak(utterance)
    }
}
