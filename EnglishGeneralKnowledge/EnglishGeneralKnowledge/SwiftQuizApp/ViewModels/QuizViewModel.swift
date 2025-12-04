import Foundation
import Combine
import UIKit

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
    @Published var showGlobalTranslation: Bool = false
    @Published var readerMode: Bool = false
    @Published private(set) var dailyGoal: Int = 10
    @Published private(set) var goalReached: Bool = false
    @Published private(set) var weakVocabularyDeck: [VocabularyEntry] = []
    @Published private(set) var weeklyMissionProgress: WeeklyMissionProgress = WeeklyMissionProgress()
    @Published var shouldShowOnboarding: Bool = false

    private let service = AIQuizService.shared
    private let historyKey = "quizHistory"
    private let interstitialAdManager = InterstitialAdManager.shared

    init() {
        loadHistory()
        shouldShowOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
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
        // Progress reflects answered/advanced questions, so the final question isn't shown as complete until answered.
        return Double(currentQuestionIndex) / Double(quizQuestions.count)
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
            HapticsManager.success()
        } else {
            incorrectAnswers.append(current)
            HapticsManager.error()
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
        let complete = { [weak self] in
            Task { await self?.finalizeQuiz() }
        }

        if interstitialAdManager.isAdReady, let rootVC = topViewController() {
            interstitialAdManager.present(from: rootVC) {
                complete()
            }
        } else {
            complete()
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

    private func topViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }

    private func finalizeQuiz() async {
        let newResult = QuizResult(
            score: correctCount,
            totalQuestions: quizQuestions.count,
            category: selectedCategory,
            literacyLevel: LiteracyLevel.from(accuracy: totalCount > 0 ? Double(correctCount) / Double(totalCount) : 0)
        )
        quizHistory.insert(newResult, at: 0)
        persistHistory()
        updateWeakVocabulary()
        weeklyMissionProgress = weeklyMissionProgress.updating(with: newResult)
        goalReached = hasMetDailyGoal
        await loadFeedback()
        gameState = .finished
        isShowingAd = false
        HapticsManager.success()
    }

    func retryWeakCategory(_ category: String) {
        guard !isShowingAd else { return }
        selectedCategory = category
        numberOfQuestions = min(5, numberOfQuestions)
        gameState = .setup
        startQuiz()
    }

    var todayAnsweredCount: Int {
        let calendar = Calendar.current
        return quizHistory
            .filter { calendar.isDate($0.date, inSameDayAs: Date()) }
            .reduce(0) { $0 + $1.totalQuestions }
    }

    var dailyProgress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(1, Double(todayAnsweredCount) / Double(dailyGoal))
    }

    var hasMetDailyGoal: Bool {
        todayAnsweredCount >= dailyGoal
    }

    var streakCount: Int {
        let calendar = Calendar.current
        let daysWithQuizzes = Set(quizHistory.map { calendar.startOfDay(for: $0.date) })
        var streak = 0
        var current = calendar.startOfDay(for: Date())

        while daysWithQuizzes.contains(current) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: current) else { break }
            current = previous
        }
        return streak
    }

    private func updateWeakVocabulary() {
        var collection: [VocabularyEntry] = []
        for question in incorrectAnswers {
            for vocab in question.vocabulary where !collection.contains(where: { $0.word == vocab.word }) {
                collection.append(vocab)
            }
        }
        weakVocabularyDeck = collection
    }

    private func persistHistory() {
        if let encoded = try? JSONEncoder().encode(quizHistory) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return }
        if let decoded = try? JSONDecoder().decode([QuizResult].self, from: data) {
            quizHistory = decoded
        }
        recalcWeeklyMission()
        goalReached = hasMetDailyGoal
    }

    private func recalcWeeklyMission() {
        var progress = WeeklyMissionProgress()
        for result in quizHistory {
            progress = progress.updating(with: result)
        }
        weeklyMissionProgress = progress
    }

    func markOnboardingSeen() {
        shouldShowOnboarding = false
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
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
