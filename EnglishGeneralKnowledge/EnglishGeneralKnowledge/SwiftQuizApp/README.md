# English General Knowledge Quiz (SwiftUI)

This folder contains a SwiftUI translation of the React quiz experience. It mirrors the same screens (setup, quiz card with translations, results review, history) and introduces a lightweight AI service layer that can work with either your own Gemini API key or bundled fallback content.

## Getting started
1. Create a new SwiftUI iOS project targeting iOS 17 or later and copy the files from this folder into the project so they compile into the main target.
2. In `Info.plist`, add a new **String** entry called `GEMINI_API_KEY` with your Google Generative Language API key.
3. Build & run on a simulator or device and enjoy the quiz flow.

If you do not provide an API key, the app will continue to work by returning static fallback questions for both the quiz and the feedback sections. The `AIQuizService` caches generated questions inside the app sandbox for reuse, ensuring smooth performance without additional UI controls.
