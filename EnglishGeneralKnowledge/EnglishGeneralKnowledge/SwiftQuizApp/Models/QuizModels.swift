import Foundation

enum GameState {
    case setup, playing, finished, history
}

struct VocabularyEntry: Codable, Hashable {
    let word: String
    let meaning: String
    let partOfSpeech: String
    let example: String

    init(word: String, meaning: String, partOfSpeech: String = "general", example: String = "") {
        self.word = word
        self.meaning = meaning
        self.partOfSpeech = partOfSpeech
        self.example = example
    }

    enum CodingKeys: String, CodingKey {
        case word
        case meaning
        case partOfSpeech
        case example
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        word = try container.decode(String.self, forKey: .word)
        meaning = try container.decode(String.self, forKey: .meaning)
        partOfSpeech = try container.decodeIfPresent(String.self, forKey: .partOfSpeech) ?? "general"
        example = try container.decodeIfPresent(String.self, forKey: .example) ?? ""
    }
}

struct QuizQuestion: Codable, Identifiable, Hashable {
    let id: UUID
    let category: String
    let difficulty: String
    let question: String
    let questionJapanese: String
    let options: [String]
    let optionsJapanese: [String]?
    let answer: String
    let explanation: String
    let explanationJapanese: String
    let vocabulary: [VocabularyEntry]
    let knowledgeInsightRaw: String?
    let englishExpressionRaw: String?

    init(
        id: UUID = UUID(),
        category: String = "Random",
        difficulty: String = "Medium",
        question: String,
        questionJapanese: String,
        options: [String],
        optionsJapanese: [String]? = nil,
        answer: String,
        explanation: String,
        explanationJapanese: String,
        vocabulary: [VocabularyEntry],
        knowledgeInsight: String? = nil,
        englishExpression: String? = nil
    ) {
        self.id = id
        self.category = category
        self.difficulty = difficulty
        self.question = question
        self.questionJapanese = questionJapanese
        self.options = options
        self.optionsJapanese = optionsJapanese
        self.answer = answer
        self.explanation = explanation
        self.explanationJapanese = explanationJapanese
        self.vocabulary = vocabulary
        self.knowledgeInsightRaw = knowledgeInsight
        self.englishExpressionRaw = englishExpression
    }

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case difficulty
        case question
        case questionJapanese
        case options
        case optionsJapanese
        case answer
        case explanation
        case explanationJapanese
        case vocabulary
        case knowledgeInsight
        case englishExpression
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "Random"
        difficulty = try container.decodeIfPresent(String.self, forKey: .difficulty) ?? "Medium"
        question = try container.decode(String.self, forKey: .question)
        questionJapanese = try container.decode(String.self, forKey: .questionJapanese)
        options = try container.decode([String].self, forKey: .options)
        optionsJapanese = try container.decodeIfPresent([String].self, forKey: .optionsJapanese)
        answer = try container.decode(String.self, forKey: .answer)
        explanation = try container.decode(String.self, forKey: .explanation)
        explanationJapanese = try container.decode(String.self, forKey: .explanationJapanese)
        vocabulary = try container.decode([VocabularyEntry].self, forKey: .vocabulary)
        knowledgeInsightRaw = try container.decodeIfPresent(String.self, forKey: .knowledgeInsight)
        englishExpressionRaw = try container.decodeIfPresent(String.self, forKey: .englishExpression)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(category, forKey: .category)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(question, forKey: .question)
        try container.encode(questionJapanese, forKey: .questionJapanese)
        try container.encode(options, forKey: .options)
        try container.encodeIfPresent(optionsJapanese, forKey: .optionsJapanese)
        try container.encode(answer, forKey: .answer)
        try container.encode(explanation, forKey: .explanation)
        try container.encode(explanationJapanese, forKey: .explanationJapanese)
        try container.encode(vocabulary, forKey: .vocabulary)
        try container.encodeIfPresent(knowledgeInsightRaw, forKey: .knowledgeInsight)
        try container.encodeIfPresent(englishExpressionRaw, forKey: .englishExpression)
    }
}

struct SpecificFeedbackItem: Codable, Hashable {
    let question: String
    let adviceEnglish: String
    let adviceJapanese: String
    let keyVocabulary: [VocabularyEntry]
}

struct Feedback: Codable, Hashable {
    let overallFeedbackEnglish: String
    let overallFeedbackJapanese: String
    let specifics: [SpecificFeedbackItem]
}

struct QuizResult: Codable, Identifiable, Hashable {
    let id: UUID
    let score: Int
    let totalQuestions: Int
    let category: String
    let date: Date
    let accuracy: Double
    let literacyLevel: LiteracyLevel

    init(
        id: UUID = UUID(),
        score: Int,
        totalQuestions: Int,
        category: String,
        date: Date = Date(),
        accuracy: Double? = nil,
        literacyLevel: LiteracyLevel? = nil
    ) {
        self.id = id
        self.score = score
        self.totalQuestions = totalQuestions
        self.category = category
        self.date = date
        self.accuracy = accuracy ?? (totalQuestions > 0 ? Double(score) / Double(totalQuestions) : 0)
        self.literacyLevel = literacyLevel ?? LiteracyLevel.from(accuracy: self.accuracy)
    }

    private enum CodingKeys: String, CodingKey {
        case id, score, totalQuestions, category, date, accuracy, literacyLevel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        score = try container.decode(Int.self, forKey: .score)
        totalQuestions = try container.decode(Int.self, forKey: .totalQuestions)
        category = try container.decode(String.self, forKey: .category)
        date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        if let decodedAccuracy = try container.decodeIfPresent(Double.self, forKey: .accuracy) {
            accuracy = decodedAccuracy
        } else {
            accuracy = totalQuestions > 0 ? Double(score) / Double(totalQuestions) : 0
        }
        literacyLevel = try container.decodeIfPresent(LiteracyLevel.self, forKey: .literacyLevel) ?? LiteracyLevel.from(accuracy: accuracy)
    }
}

struct WeeklyMissionProgress: Codable, Hashable {
    var uniqueCategoriesAtTarget: Set<String> = []
    var targetAccuracy: Double = 0.8
    var targetCategoryCount: Int = 3

    var completed: Bool {
        uniqueCategoriesAtTarget.count >= targetCategoryCount
    }

    var progressRatio: Double {
        min(1, Double(uniqueCategoriesAtTarget.count) / Double(targetCategoryCount))
    }

    func updating(with result: QuizResult) -> WeeklyMissionProgress {
        var updated = self
        if result.accuracy >= targetAccuracy {
            updated.uniqueCategoriesAtTarget.insert(result.category)
        }
        return updated
    }
}

enum LiteracyLevel: String, Codable, Hashable {
    case starter
    case explorer
    case insightful
    case scholar

    var title: String {
        switch self {
        case .starter: return "Starter"
        case .explorer: return "Explorer"
        case .insightful: return "Insightful"
        case .scholar: return "Scholar"
        }
    }

    var hint: String {
        switch self {
        case .starter: return "Focus on fundamentals and vocabulary."
        case .explorer: return "Broaden categories and keep practicing."
        case .insightful: return "Great comprehension—try harder sets."
        case .scholar: return "Elite accuracy—challenge yourself further."
        }
    }

    static func from(accuracy: Double) -> LiteracyLevel {
        switch accuracy {
        case 0.85...: return .scholar
        case 0.7..<0.85: return .insightful
        case 0.5..<0.7: return .explorer
        default: return .starter
        }
    }
}
