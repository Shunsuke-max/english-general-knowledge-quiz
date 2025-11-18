import Foundation
import Combine

@MainActor
final class QuizViewModel: ObservableObject {
    @Published var gameState: GameState = .setup
    @Published var quizQuestions: [QuizQuestion] = []
    @Published var incorrectAnswers: [QuizQuestion] = []
    @Published var quizHistory: [QuizResult] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswer: String? = nil
    @Published var isLoading: Bool = false
    @Published var isShowingAd: Bool = false
    @Published var errorMessage: String? = nil
    @Published var numberOfQuestions: Int = 5
    @Published var selectedCategory: String = "Random"
    @Published var selectedDifficulty: String = "Medium"
    @Published var feedback: Feedback? = nil
    @Published var isFeedbackLoading: Bool = false
    @Published private(set) var correctCount: Int = 0
    @Published private(set) var totalCount: Int = 0

    private let service = AIQuizService.shared
    private let historyKey = "quizHistory"

    init() {
        loadHistory()
    }

    deinit {
    }

    var isQuizActive: Bool {
        gameState == .playing
    }

    var isLastQuestion: Bool {
        currentQuestionIndex >= quizQuestions.count - 1 && !quizQuestions.isEmpty
    }

    var progress: Double {
        guard !quizQuestions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(quizQuestions.count)
    }

    func startQuiz() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        selectedAnswer = nil
        incorrectAnswers = []
        correctCount = 0
        totalCount = 0
        currentQuestionIndex = 0
        feedback = nil

        Task {
            do {
                let questions = try await service.generateQuizQuestions(
                    count: numberOfQuestions,
                    category: selectedCategory,
                    difficulty: selectedDifficulty
                )
                quizQuestions = questions
                gameState = .playing
            } catch {
                errorMessage = error.localizedDescription
                gameState = .setup
            }
            isLoading = false
        }
    }

    func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil,
              currentQuestionIndex < quizQuestions.count else { return }
        selectedAnswer = answer
        let current = quizQuestions[currentQuestionIndex]
        let isCorrect = answer == current.answer
            if isCorrect {
                correctCount += 1
            } else {
                incorrectAnswers.append(current)
            }
            totalCount += 1
    }

    func nextQuestion() {
        guard !isShowingAd else { return }

        selectedAnswer = nil
        if currentQuestionIndex < quizQuestions.count - 1 {
            currentQuestionIndex += 1
        } else {
            finishQuiz()
        }
    }

    func finishQuiz() {
        guard !isShowingAd else { return }
        isShowingAd = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            let newResult = QuizResult(
                score: correctCount,
                totalQuestions: quizQuestions.count,
                category: selectedCategory
            )
            quizHistory.insert(newResult, at: 0)
            persistHistory()
            await loadFeedback()
            gameState = .finished
            isShowingAd = false
        }
    }

    private var replayAdCounter = 0

    func playAgain() {
        guard !isShowingAd else { return }
        replayAdCounter += 1
        let shouldShowReplayAd = replayAdCounter % 2 == 0

        if shouldShowReplayAd {
            isShowingAd = true
            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                isShowingAd = false
                resetQuiz()
            }
        } else {
            resetQuiz()
        }
    }

    func cancelQuiz() {
        guard gameState == .playing else { return }
        resetQuiz()
    }

    private func resetQuiz() {
        gameState = .setup
        quizQuestions = []
        incorrectAnswers = []
        currentQuestionIndex = 0
        correctCount = 0
        totalCount = 0
        selectedAnswer = nil
        feedback = nil
        errorMessage = nil
    }

    func viewHistory() {
        gameState = .history
    }

    func backToSetup() {
        gameState = .setup
    }

    func clearHistory() {
        quizHistory.removeAll()
        persistHistory()
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return }
        if let decoded = try? JSONDecoder().decode([QuizResult].self, from: data) {
            quizHistory = decoded
        }
    }

    private func persistHistory() {
        if let encoded = try? JSONEncoder().encode(quizHistory) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }

    private func loadFeedback() async {
        guard quizQuestions.count == totalCount else {
            isFeedbackLoading = false
            return
        }
        isFeedbackLoading = true
        feedback = nil
        do {
            let received = try await service.generateDetailedFeedback(
                score: correctCount,
                total: totalCount,
                incorrectAnswers: incorrectAnswers
            )
            feedback = received
        } catch {
            feedback = nil
        }
        isFeedbackLoading = false
    }

}
