import Foundation

enum GameState {
    case setup, playing, finished, history
}

struct VocabularyEntry: Codable, Hashable {
    let word: String
    let meaning: String
}

struct QuizQuestion: Codable, Identifiable, Hashable {
    let id: UUID
    let category: String
    let difficulty: String
    let question: String
    let questionJapanese: String
    let options: [String]
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

    init(
        id: UUID = UUID(),
        score: Int,
        totalQuestions: Int,
        category: String,
        date: Date = Date()
    ) {
        self.id = id
        self.score = score
        self.totalQuestions = totalQuestions
        self.category = category
        self.date = date
    }
}

struct StockProgress: Equatable {
    let completed: Int
    let total: Int
    let message: String
}
