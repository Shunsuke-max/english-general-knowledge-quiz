import Foundation

final class AIQuizService {
    static let shared = AIQuizService()

    private static let bundledQuestions: [QuizQuestion] = loadBundledQuestions()

    private let apiKey: String?
    private let cacheURL: URL
    private var cache: [String: [QuizQuestion]] = [:]
    private let session = URLSession.shared

    private init() {
        self.apiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let baseURL = caches.first ?? FileManager.default.temporaryDirectory
        self.cacheURL = baseURL.appendingPathComponent("quizQuestionCache.json")
        self.cache = loadCache()
    }

    func generateQuizQuestions(count: Int, category: String, difficulty: String) async throws -> [QuizQuestion] {
        guard count > 0 else { return [] }
        guard let apiKey else {
            return Self.fallbackQuestions(count: count, category: category, difficulty: difficulty)
        }

        if difficulty != "Random" {
            return try await fetchAndCacheQuestions(count: count, category: category, difficulty: difficulty)
        }

        return try await generateRandomDifficultyQuiz(count: count, category: category)
    }

    func generateDetailedFeedback(score: Int, total: Int, incorrectAnswers: [QuizQuestion]) async throws -> Feedback {
        if incorrectAnswers.isEmpty {
            return Feedback(
                overallFeedbackEnglish: "Excellent work! You scored a perfect \(score) out of \(total)!",
                overallFeedbackJapanese: "素晴らしい！\(total)問中\(score)問全問正解です！",
                specifics: []
            )
        }

        let fallbackFeedback = Feedback(
            overallFeedbackEnglish: "Great effort! You scored \(score) out of \(total). Keep practicing!",
            overallFeedbackJapanese: "素晴らしい努力です！\(total)問中\(score)問正解しました。練習を続けましょう！",
            specifics: incorrectAnswers.map { question in
                SpecificFeedbackItem(
                    question: question.question,
                    adviceEnglish: "Review the explanation for this question to reinforce the concept.",
                    adviceJapanese: "この問題の解説を復習して、理解を深めましょう。",
                    keyVocabulary: question.vocabulary
                )
            }
        )

        guard let apiKey else { return fallbackFeedback }

        let prompt = detailedFeedbackPrompt(score: score, total: total, incorrectAnswers: incorrectAnswers)
        do {
            let payload = GeminiRequest(prompt: GeminiPrompt(text: prompt), temperature: 0.7, candidateCount: 1, maxOutputTokens: 600, topP: 0.95, topK: 40)
            let response = try await sendRequest(payload: payload, apiKey: apiKey)
            let sanitized = sanitizeJSON(response)
            if let data = sanitized.data(using: .utf8) {
                let feedback = try JSONDecoder().decode(Feedback.self, from: data)
                return feedback
            }
        } catch {
            print("Feedback API failed: \(error)")
        }

        return fallbackFeedback
    }

    // MARK: - Private Helpers

    private func fetchAndCacheQuestions(count: Int, category: String, difficulty: String) async throws -> [QuizQuestion] {
        let key = cacheKey(category: category, difficulty: difficulty)
        var cached = cache[key] ?? []
        let fromCache = Array(cached.prefix(count))
        cached = Array(cached.dropFirst(fromCache.count))
        cache[key] = cached

        let remaining = count - fromCache.count
        guard remaining > 0 else {
            saveCache()
            return fromCache
        }

        let newQuestions = try await withThrowingTaskGroup(of: QuizQuestion.self) { group in
            for _ in 0..<remaining {
                group.addTask { [self] in
                    try await self.generateQuizQuestion(category: category, difficulty: difficulty)
                }
            }

            var questions: [QuizQuestion] = []
            for try await question in group {
                questions.append(question)
            }
            return questions
        }

        let combined = fromCache + newQuestions
        cache[key, default: []] = cached + newQuestions
        saveCache()
        return combined
    }

    private func generateRandomDifficultyQuiz(count: Int, category: String) async throws -> [QuizQuestion] {
        let levels = ["Easy", "Medium", "Hard"]
        let assignment = (0..<count).map { _ in levels.randomElement() ?? "Medium" }
        let summary = Dictionary(grouping: assignment, by: { $0 }).mapValues { $0.count }

        let sortedEntries = summary.sorted(by: { $0.key < $1.key })
        let questions = try await withThrowingTaskGroup(of: [QuizQuestion].self) { group in
            for entry in sortedEntries {
                let difficultyLevel = entry.key
                let entryCount = entry.value
                group.addTask { [self] in
                    try await self.fetchAndCacheQuestions(count: entryCount, category: category, difficulty: difficultyLevel)
                }
            }

            var batches: [[QuizQuestion]] = []
            for try await batch in group {
                batches.append(batch)
            }
            return batches
        }

        let flattened = questions.flatMap { $0 }
        return flattened.shuffled()
    }

    private func generateQuizQuestion(category: String, difficulty: String) async throws -> QuizQuestion {
        if let apiKey = apiKey {
            let prompt = quizPrompt(category: category, difficulty: difficulty)
            let payload = GeminiRequest(prompt: GeminiPrompt(text: prompt), temperature: 1, candidateCount: 1, maxOutputTokens: 512, topP: 0.92, topK: 40)
            let response = try await sendRequest(payload: payload, apiKey: apiKey)
            let sanitized = sanitizeJSON(response)
            if let data = sanitized.data(using: .utf8) {
                let decoded = try JSONDecoder().decode(QuizQuestion.self, from: data)
                guard decoded.options.contains(decoded.answer) else {
                    throw AIQuizServiceError.invalidAnswerSet
                }
                return QuizQuestion(
                    id: decoded.id,
                    category: category,
                    difficulty: difficulty,
                    question: decoded.question,
                    questionJapanese: decoded.questionJapanese,
                    options: decoded.options,
                    answer: decoded.answer,
                    explanation: decoded.explanation,
                    explanationJapanese: decoded.explanationJapanese,
                    vocabulary: decoded.vocabulary
                )
            }
            throw AIQuizServiceError.parsingFailed
        }
        return Self.fallbackQuestion(category: category, difficulty: difficulty)
    }

    private func sendRequest(payload: GeminiRequest, apiKey: String) async throws -> String {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw AIQuizServiceError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = try JSONEncoder().encode(payload)
        request.httpBody = body

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw AIQuizServiceError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let candidate = decoded.candidates.first else {
            throw AIQuizServiceError.noResponseContent
        }
        return candidate.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func cacheKey(category: String, difficulty: String) -> String {
        "\(category)_\(difficulty)"
    }

    private func loadCache() -> [String: [QuizQuestion]] {
        guard let data = try? Data(contentsOf: cacheURL) else { return [:] }
        return (try? JSONDecoder().decode([String: [QuizQuestion]].self, from: data)) ?? [:]
    }

    private func saveCache() {
        guard let data = try? JSONEncoder().encode(cache) else { return }
        try? data.write(to: cacheURL, options: .atomic)
    }

    private func quizPrompt(category: String, difficulty: String) -> String {
        let topic = category.lowercased() == "random" ? "mixed topics" : category
        return "Generate a unique, \(difficulty)-difficulty general knowledge trivia question about \(topic). Provide the question, 4 multiple-choice options, and the correct answer in English. Also provide a Japanese translation for the question. Include a brief, simple explanation in English for the correct answer (suitable for English learners), and its Japanese translation. Finally, provide a list of 2-3 important vocabulary words from the question or explanation, with their Japanese meanings."
    }

    private func detailedFeedbackPrompt(score: Int, total: Int, incorrectAnswers: [QuizQuestion]) -> String {
        let incorrectSummary = incorrectAnswers.map { question in
            ["question": question.question, "explanation": question.explanation, "vocabulary": question.vocabulary].description
        }
        return "A user scored \(score) out of \(total) on an English general knowledge quiz. Here are the questions they answered incorrectly:\n\(incorrectSummary)\nPlease generate\n1. An overall encouraging feedback message in English and Japanese based on their score.\n2. For each incorrect question, a short advice in English and Japanese that clarifies the explanation and reinforces the vocabulary. Make sure the 'question' field matches the input."
    }

    private func sanitizeJSON(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func fallbackQuestions(count: Int, category: String, difficulty: String) -> [QuizQuestion] {
        let base = filteredQuestions(for: category, difficulty: difficulty)
        guard !base.isEmpty else {
            return Array(repeating: sampleQuestion, count: count)
        }
        var pool = base.shuffled()
        var result: [QuizQuestion] = []
        for _ in 0..<count {
            if pool.isEmpty {
                pool = base.shuffled()
            }
            result.append(pool.removeFirst())
        }
        return result
    }

    private static func fallbackQuestion(category: String, difficulty: String) -> QuizQuestion {
        let base = filteredQuestions(for: category, difficulty: difficulty)
        return base.randomElement() ?? sampleQuestion
    }

    private static func filteredQuestions(for category: String, difficulty: String) -> [QuizQuestion] {
        guard !bundledQuestions.isEmpty else { return [] }
        let categoryPool: [QuizQuestion]
        if category.lowercased() == "random" {
            categoryPool = bundledQuestions
        } else {
            let matches = bundledQuestions.filter { $0.category == category }
            categoryPool = matches.isEmpty ? bundledQuestions : matches
        }

        if difficulty.lowercased() == "random" {
            return categoryPool
        }

        let difficultyPool = categoryPool.filter { $0.difficulty == difficulty }
        return difficultyPool.isEmpty ? categoryPool : difficultyPool
    }

    private static func loadBundledQuestions() -> [QuizQuestion] {
        let bundle = Bundle.main
        let questionFiles = (bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? [])
            .filter { $0.lastPathComponent.hasPrefix("questions_") }

        var allQuestions: [QuizQuestion] = []
        for url in questionFiles {
            if let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([QuizQuestion].self, from: data) {
                allQuestions.append(contentsOf: decoded)
            }
        }

        if !allQuestions.isEmpty {
            return allQuestions
        }

        // Backward compatibility: fall back to single-file questions.json if split files are missing.
        if let url = bundle.url(forResource: "questions", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([QuizQuestion].self, from: data) {
            return decoded
        }

        return []
    }

    private static let sampleQuestion: QuizQuestion = {
        QuizQuestion(
            category: "Science",
            question: "What is the powerhouse of the cell?",
            questionJapanese: "細胞のエネルギー源は何ですか？",
            options: ["Nucleus", "Ribosome", "Chloroplast", "Mitochondrion"],
            answer: "Mitochondrion",
            explanation: "Mitochondria produce most of the cell's ATP, so they are often called the powerhouse of the cell.",
            explanationJapanese: "ミトコンドリアは細胞のATPの大部分を生成し、細胞の発電所と呼ばれます。",
            vocabulary: [
                VocabularyEntry(word: "powerhouse", meaning: "発電所、主な供給源"),
                VocabularyEntry(word: "produce", meaning: "生み出す"),
                VocabularyEntry(word: "ATP", meaning: "アデノシン三リン酸、エネルギー"),
            ]
        )
    }()
}

private struct GeminiRequest: Codable {
    let prompt: GeminiPrompt
    let temperature: Double
    let candidateCount: Int
    let maxOutputTokens: Int
    let topP: Double
    let topK: Int
}

private struct GeminiPrompt: Codable {
    let text: String
}

private struct GeminiResponse: Codable {
    struct Candidate: Codable {
        let content: String
    }
    let candidates: [Candidate]
}

private enum AIQuizServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noResponseContent
    case parsingFailed
    case invalidAnswerSet

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API URL is invalid."
        case .invalidResponse:
            return "The API returned an unexpected response."
        case .noResponseContent:
            return "The AI did not return any content."
        case .parsingFailed:
            return "Failed to understand the AI response."
        case .invalidAnswerSet:
            return "The correct answer was not part of the options."
        }
    }
}

private extension Array {
    func asyncMap<T>(_ transform: @escaping (Element) async throws -> T) async throws -> [T] {
        var results: [T] = []
        results.reserveCapacity(count)
        for element in self {
            results.append(try await transform(element))
        }
        return results
    }
}
