import SwiftUI

struct QuizRootView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var showCancelConfirmation = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0b1120"), Color(hex: "020617")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    mainContent
                    if viewModel.isQuizActive, let question = currentQuestion {
                        Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.quizQuestions.count)")
                            .foregroundColor(.secondary)
                        HStack {
                            Text("Score: \(viewModel.correctCount)/\(viewModel.totalCount)")
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                            ProgressView(value: viewModel.progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
                                .frame(width: 120)
                        }
                    }
                    footerButton
                    bannerPlaceholder
                }
                .padding(.top)
                .padding(.bottom, 40)
                .padding(.horizontal, horizontalPadding)
            }
            .alert("Cancel quiz?", isPresented: $showCancelConfirmation) {
                Button("Stop", role: .destructive) {
                    viewModel.cancelQuiz()
                }
                Button("Keep playing", role: .cancel) {}
            } message: {
                Text("Are you sure you want to stop the current quiz? Progress will be reset.")
            }

            if viewModel.isShowingAd {
                adOverlay
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            HStack {
                Label("General Knowledge Quiz", systemImage: "lightbulb.fill")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                Spacer()
                if viewModel.isQuizActive {
                    Button(action: { showCancelConfirmation = true }) {
                        Text("Cancel")
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
            Text("Test your English knowledge with curated questions.")
                .foregroundColor(.white)
        }
        .padding(.horizontal)
    }

    private var horizontalPadding: CGFloat {
        viewModel.gameState == .playing ? 8 : 16
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
                onPlayAgain: viewModel.playAgain
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

    private var footerButton: some View {
        Group {
            if viewModel.isQuizActive && viewModel.selectedAnswer != nil {
                Button(action: viewModel.nextQuestion) {
                    Text(viewModel.isLastQuestion ? "Finish Quiz" : "Next Question")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan)
                        .foregroundColor(.black)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
            }
        }
    }

    private var bannerPlaceholder: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color.white.opacity(0.05))
            .frame(height: 70)
            .overlay(
                Text("Banner Ad Placeholder")
                    .foregroundColor(.secondary)
            )
            .padding(.horizontal)
    }

    private var adOverlay: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Text("Loading your results...")
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
