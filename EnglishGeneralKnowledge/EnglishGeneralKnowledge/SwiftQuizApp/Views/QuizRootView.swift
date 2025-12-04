import SwiftUI

struct QuizRootView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var showCancelConfirmation = false

    var body: some View {
        ZStack {
            backgroundLayer

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if shouldShowHeader {
                        header
                    }
                    if viewModel.gameState == .playing {
                        playingStatusBar
                    } else if viewModel.gameState == .finished {
                        finishedStatusBar
                    }
                    mainContent
                    footerButton
                    bannerPlaceholder
                }
                .padding(.top)
                .padding(.bottom, 16)
                .padding(.horizontal, horizontalPadding)
                .frame(maxWidth: 720, alignment: .center)
                .dynamicTypeSize(.medium ... .accessibility5)
            }
            .alert("クイズを中止しますか？", isPresented: $showCancelConfirmation) {
                Button("中止する", role: .destructive) {
                    viewModel.cancelQuiz()
                }
                Button("続ける", role: .cancel) {}
            } message: {
                Text("現在の進行状況は失われます。")
            }

            if viewModel.isShowingAd {
                adOverlay
            }

            if viewModel.shouldShowOnboarding {
                OnboardingView(
                    onGetStarted: {
                        viewModel.markOnboardingSeen()
                    },
                    onSkip: {
                        viewModel.markOnboardingSeen()
                    }
                )
                .transition(.opacity)
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "050915"), Color(hex: "0c1224")], startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle()
                .fill(Color.cyan.opacity(0.18))
                .blur(radius: 120)
                .frame(width: 320, height: 320)
                .offset(x: -120, y: -280)
            Circle()
                .fill(Color.blue.opacity(0.16))
                .blur(radius: 140)
                .frame(width: 280, height: 280)
                .offset(x: 140, y: 200)
            Circle()
                .fill(Color.purple.opacity(0.18))
                .blur(radius: 170)
                .frame(width: 360, height: 360)
                .offset(x: 40, y: 420)
                .opacity(0.6)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("英語×教養クイズ", systemImage: "lightbulb.fill")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .bold()
                    .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                Spacer()
                if viewModel.isQuizActive {
                    Button(action: { showCancelConfirmation = true }) {
                        Text("中止")
                            .font(.subheadline)
                            .bold()
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            habitCard
        }
        .padding(.horizontal)
    }

    private func highlightChip(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.bold())
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .cornerRadius(14)
    }

    private var horizontalPadding: CGFloat {
        viewModel.gameState == .playing ? 8 : 16
    }

    private var shouldShowHeader: Bool {
        viewModel.gameState == .history
    }

    private var playingStatusBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Label("解答中", systemImage: "waveform.path.ecg")
                    .font(.subheadline.bold())
                    .foregroundColor(.cyan)
                Divider().frame(height: 20).background(Color.white.opacity(0.2))
                Text("Q\(viewModel.currentQuestionIndex + 1)/\(viewModel.quizQuestions.count)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Divider().frame(height: 20).background(Color.white.opacity(0.2))
                Text("正解 \(viewModel.correctCount)/\(viewModel.totalCount)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
                if let question = currentQuestion {
                    Text(question.category)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.75))
                }
                Button {
                    HapticsManager.selection()
                    showCancelConfirmation = true
                } label: {
                    Text("中止")
                        .font(.caption.bold())
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.12))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }

    private var finishedStatusBar: some View {
        HStack(spacing: 12) {
            Label("結果サマリー", systemImage: "checkmark.seal")
                .font(.subheadline.bold())
                .foregroundColor(.green)
            Divider().frame(height: 20).background(Color.white.opacity(0.2))
            Text("正答率 \(viewModel.quizQuestions.count > 0 ? Int(Double(viewModel.correctCount) / Double(viewModel.quizQuestions.count) * 100) : 0)%")
                .font(.caption.bold())
                .foregroundColor(.white)
            Divider().frame(height: 20).background(Color.white.opacity(0.2))
            Text("\(viewModel.correctCount)/\(viewModel.quizQuestions.count) 正解")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.gameState {
        case .setup:
            SetupView(viewModel: viewModel)
        case .playing:
            if let question = currentQuestion {
                QuizCardView(
                    quizData: question,
                    selectedAnswer: viewModel.selectedAnswer,
                    onSelectAnswer: viewModel.selectAnswer,
                    onSkipQuestion: viewModel.nextQuestion,
                    category: viewModel.selectedCategory,
                    globalTranslationEnabled: viewModel.showGlobalTranslation,
                    readerMode: viewModel.readerMode,
                    progress: viewModel.progress,
                    questionNumber: viewModel.currentQuestionIndex + 1,
                    totalQuestions: viewModel.quizQuestions.count
                )
                .id(question.id)
                .frame(maxWidth: .infinity)
            } else {
                ProgressView()
            }
        case .finished:
            ResultsView(
                score: viewModel.correctCount,
                total: viewModel.quizQuestions.count,
                incorrectAnswers: viewModel.incorrectAnswers,
                onPlayAgain: viewModel.playAgain,
                onRetryWeakCategory: viewModel.retryWeakCategory,
                globalTranslationEnabled: viewModel.showGlobalTranslation,
                weeklyMissionProgress: viewModel.weeklyMissionProgress,
                weakVocabularyDeck: viewModel.weakVocabularyDeck
            )
        case .history:
            HistoryView(
                history: viewModel.quizHistory,
                onBack: viewModel.backToSetup,
                onClear: viewModel.clearHistory
            )
        }
    }

    private var currentQuestion: QuizQuestion? {
        guard viewModel.currentQuestionIndex < viewModel.quizQuestions.count else { return nil }
        return viewModel.quizQuestions[viewModel.currentQuestionIndex]
    }

    // Removed quizStatusCard to avoid duplicate progress indicators; playingStatusBar now owns progress UI.

    private var footerButton: some View {
        Group {
            if viewModel.isQuizActive && viewModel.selectedAnswer != nil {
                Button(action: {
                    HapticsManager.mediumTap()
                    viewModel.nextQuestion()
                }) {
                    Text(viewModel.isLastQuestion ? "結果を見る" : "次の問題へ")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.black)
                        .cornerRadius(16)
                        .shadow(color: Color.cyan.opacity(0.35), radius: 16, x: 0, y: 8)
                }
                .padding(.horizontal)
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private var bannerPlaceholder: some View {
        BannerAdView(adUnitID: "ca-app-pub-9982720117568146/6131906499")
            .frame(height: 50)
            .background(Color.white.opacity(0.05))
            .cornerRadius(18)
            .padding(.horizontal)
    }

    private var adOverlay: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Text("結果を読み込み中…")
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .cornerRadius(24)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
        .ignoresSafeArea()
    }

    private var habitCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("学習習慣")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if viewModel.hasMetDailyGoal {
                    Text("🎉 目標達成")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("今日の目標", systemImage: "target")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.85))
                    Spacer()
                    Text(viewModel.hasMetDailyGoal ? "達成" : "\(viewModel.todayAnsweredCount)/\(viewModel.dailyGoal)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(viewModel.hasMetDailyGoal ? .green : .white.opacity(0.85))
                }
                Text(viewModel.hasMetDailyGoal ? "よくできました！明日も1問でOK。" : "あと \(max(0, viewModel.dailyGoal - viewModel.todayAnsweredCount)) 問で達成。")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // Config toggles and options are managed inside SetupView; header is kept minimal to reduce duplication.
}

struct QuizRootView_Previews: PreviewProvider {
    static var previews: some View {
        QuizRootView()
            .preferredColorScheme(.dark)
    }
}

fileprivate extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
