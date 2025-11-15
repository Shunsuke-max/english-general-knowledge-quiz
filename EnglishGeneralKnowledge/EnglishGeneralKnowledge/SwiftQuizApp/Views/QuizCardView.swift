import SwiftUI

struct QuizCardView: View {
    let quizData: QuizQuestion
    let selectedAnswer: String?
    let onSelectAnswer: (String) -> Void
    let onSkipQuestion: () -> Void
    let category: String
    let progress: Double
    let questionNumber: Int
    let totalQuestions: Int

    @State private var showQuestionTranslation = false
    @State private var showExplanationTranslation = false
    @State private var showDetails = false
    @State private var randomizedOptions: [String] = []

    private var isRevealed: Bool { selectedAnswer != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                progressIndicator
                VStack(alignment: .leading, spacing: 6) {
                    Text(category)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.cyan)
                    Text(quizData.question)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .minimumScaleFactor(0.85)
                        .frame(minHeight: 140, alignment: .topLeading)
                }
                Spacer()
            }
            translationToggle(isVisible: showQuestionTranslation, action: { showQuestionTranslation.toggle() }, label: "Translation")
            if showQuestionTranslation {
                Text(quizData.questionJapanese)
                    .foregroundColor(.secondary)
                    .font(.body)
            }
            optionsGrid
            if !isRevealed {
                skipButton
            }
            if isRevealed {
                revealSection
            }
        }
        .padding()
        .frame(minHeight: 520)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.black.opacity(0.6)))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            randomizedOptions = quizData.options.shuffled()
        }
        .onChange(of: questionNumber) { _ in
            randomizedOptions = quizData.options.shuffled()
        }
    }

    private var optionsGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(buttonOptions, id: \.self) { option in
                Button(action: { onSelectAnswer(option) }) {
                    Text(option)
                        .font(.body)
                        .bold()
                        .foregroundColor(buttonTextColor(option: option))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(buttonBackground(option: option))
                        .cornerRadius(12)
                        .scaleEffect(scaleEffect(option: option))
                }
                .disabled(isRevealed)
            }
        }
    }

    private var buttonOptions: [String] {
        randomizedOptions.isEmpty ? quizData.options : randomizedOptions
    }

    private func buttonBackground(option: String) -> Color {
        guard isRevealed else { return Color.white.opacity(0.1) }
        if option == quizData.answer {
            return Color.green.opacity(0.85)
        }
        if option == selectedAnswer {
            return Color.red.opacity(0.8)
        }
        return Color.white.opacity(0.05)
    }

    private func buttonTextColor(option: String) -> Color {
        guard isRevealed else { return .white }
        if option == quizData.answer {
            return .white
        }
        if option == selectedAnswer {
            return .white
        }
        return Color.white.opacity(0.7)
    }

    private func scaleEffect(option: String) -> CGFloat {
        guard isRevealed else { return 1 }
        if option == quizData.answer {
            return 1.02
        }
        if option == selectedAnswer {
            return 0.98
        }
        return 1
    }

    private var skipButton: some View {
        Button(action: onSkipQuestion) {
            Text("Skip Question")
                .font(.footnote)
                .bold()
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
        }
    }

    private var revealSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !showDetails {
                Button(action: { withAnimation { showDetails = true } }) {
                    Text("Show Explanation")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan)
                        .foregroundColor(.black)
                        .cornerRadius(16)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Explanation")
                            .font(.headline)
                            .foregroundColor(.yellow)
                        Spacer()
                        translationToggle(isVisible: showExplanationTranslation, action: { showExplanationTranslation.toggle() }, label: "Translation")
                    }
                    Text(quizData.explanation)
                        .foregroundColor(.white)
                    if showExplanationTranslation {
                        Text(quizData.explanationJapanese)
                            .foregroundColor(.secondary)
                    }
                    if !quizData.vocabulary.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Vocabulary")
                                .font(.headline)
                                .foregroundColor(.yellow)
                            ForEach(quizData.vocabulary, id: \.word) { vocab in
                                HStack {
                                    Text(vocab.word)
                                        .bold()
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(vocab.meaning)
                                        .foregroundColor(.white.opacity(0.95))
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                    englishExpressionBlock
                    knowledgeInsightBlock
                }
                .padding()
                .background(Color.white.opacity(0.03))
                .cornerRadius(16)
            }
        }
    }

    private var progressIndicator: some View {
        let clamped = min(max(progress, 0), 1)
        return ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: CGFloat(clamped))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.cyan, Color.blue]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text("\(questionNumber)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .bold()
                Text("of \(totalQuestions)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 58, height: 58)
    }

    private func translationToggle(isVisible: Bool, action: @escaping () -> Void, label: String) -> some View {
        Button(action: action) {
            Text(isVisible ? "Hide \(label)" : "Show \(label)")
                .font(.caption)
                .foregroundColor(.cyan)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var englishExpressionBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("English Expression")
                .font(.subheadline)
                .foregroundColor(.cyan)
            Text(quizData.englishExpression ?? "Try using the highlighted vocabulary in a sentence.")
                .font(.callout)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var knowledgeInsightBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Knowledge Insight")
                .font(.subheadline)
                .foregroundColor(.cyan)
            Text(quizData.knowledgeInsight)
                .font(.callout)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct QuizCardView_Previews: PreviewProvider {
    static var previews: some View {
                QuizCardView(
                    quizData: QuizQuestion(
                        category: "Science",
                        difficulty: "Medium",
                        question: "What causes day and night?",
                        questionJapanese: "昼と夜ができる原因は何ですか？",
                        options: ["Earth orbit", "Sun rotation", "Earth rotation", "Moon orbit"],
                        answer: "Earth rotation",
                        explanation: "The Earth rotates on its axis, making the Sun appear to move across the sky and creating day and night.",
                        explanationJapanese: "地球が自転しているので、太陽が空を移動して見え、昼と夜が生じます。",
                        vocabulary: [VocabularyEntry(word: "rotate", meaning: "回転する"), VocabularyEntry(word: "axis", meaning: "軸")]
                    ),
                selectedAnswer: nil,
                onSelectAnswer: { _ in },
                onSkipQuestion: {},
                category: "Science",
                progress: 0.45,
                questionNumber: 2,
                totalQuestions: 5
            )
        .preferredColorScheme(.dark)
        .padding()
    }
}
