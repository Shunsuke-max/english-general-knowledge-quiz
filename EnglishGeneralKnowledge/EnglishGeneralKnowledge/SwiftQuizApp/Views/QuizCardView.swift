import SwiftUI

struct QuizCardView: View {
    let quizData: QuizQuestion
    let selectedAnswer: String?
    let onSelectAnswer: (String) -> Void
    let onSkipQuestion: () -> Void
    let category: String
    let globalTranslationEnabled: Bool
    let readerMode: Bool
    let progress: Double
    let questionNumber: Int
    let totalQuestions: Int

    @State private var showQuestionTranslation = false
    @State private var showExplanationTranslation = false
    @State private var showDetails = false
    @State private var randomizedOptions: [(en: String, jp: String?)] = []

    private var isRevealed: Bool { selectedAnswer != nil }
    private var shouldShowQuestionTranslation: Bool { showQuestionTranslation }
    private var shouldShowExplanationTranslation: Bool { showExplanationTranslation }
    private var questionFont: Font { readerMode ? .system(size: 26, weight: .heavy, design: .rounded) : .title2.weight(.bold) }
    private var bodyFont: Font { readerMode ? .body.weight(.medium) : .body }
    private var lineSpacing: CGFloat { readerMode ? 6 : 3 }
    private var effectiveOptionsJapanese: [String]? {
        guard let jps = quizData.optionsJapanese else { return nil }
        // If JP options are identical to EN, avoid double-rendering the same string.
        let hasMeaningfulDiff = zip(quizData.options, jps).contains { $0.0 != $0.1 }
        return hasMeaningfulDiff ? jps : nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    categoryBadge
                    difficultyBadge
                    Spacer()
                }
                Text(quizData.question)
                    .font(questionFont)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .minimumScaleFactor(readerMode ? 0.9 : 0.85)
                    .lineSpacing(lineSpacing)
                    .frame(minHeight: 140, alignment: .topLeading)
            }
            translationToggle(isVisible: shouldShowQuestionTranslation, action: { showQuestionTranslation.toggle() }, label: "問題の訳")
            if shouldShowQuestionTranslation {
                Text(quizData.questionJapanese)
                    .foregroundColor(.secondary)
                    .font(bodyFont)
                    .lineSpacing(lineSpacing)
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
        .frame(minHeight: 540)
        .background(
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.03), Color.white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 12)
                Circle()
                    .fill(Color.cyan.opacity(0.18))
                    .blur(radius: 90)
                    .frame(width: 180, height: 180)
                    .offset(x: 20, y: -30)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.16), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
        .onAppear(perform: resetTranslations)
        .onChange(of: questionNumber) { _ in
            randomizedOptions = shuffledOptions()
            resetTranslations()
        }
        .onChange(of: globalTranslationEnabled) { _ in
            resetTranslations()
        }
        .dynamicTypeSize(.medium ... .accessibility5)
    }

    private var optionsGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(buttonOptions.enumerated()), id: \.offset) { _, option in
                Button(action: {
                    HapticsManager.selection()
                    onSelectAnswer(option.en)
                }) {
                    VStack(spacing: 4) {
                        HStack {
                            if let icon = optionIcon(option: option.en) {
                                Image(systemName: icon)
                                    .font(.caption.weight(.bold))
                            }
                            Text(option.en)
                                .font(.body.bold())
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .foregroundColor(buttonTextColor(option: option.en))
                        if shouldShowQuestionTranslation, let jp = option.jp {
                            Text(jp)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(buttonBackground(option: option.en))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(buttonBorder(option: option.en), lineWidth: 1)
                    )
                    .cornerRadius(14)
                    .shadow(color: shadowColor(option: option.en), radius: 8, x: 0, y: 6)
                    .scaleEffect(scaleEffect(option: option.en))
                }
                .disabled(isRevealed)
                .accessibilityLabel(accessibilityLabel(for: option.en))
                .accessibilityHint(isRevealed ? "回答結果を表示中" : "選択肢を選んで回答します。")
            }
        }
    }

    private var buttonOptions: [(en: String, jp: String?)] {
        randomizedOptions.isEmpty ? zippedOptions() : randomizedOptions
    }

    private func buttonBackground(option: String) -> Color {
        guard isRevealed else { return Color.white.opacity(0.1) }
        if option == quizData.answer {
            return Color.green.opacity(0.85)
        }
        if option == selectedAnswer {
            return Color.red.opacity(0.8)
        }
        return Color.white.opacity(0.06)
    }

    private func buttonBorder(option: String) -> Color {
        guard isRevealed else { return Color.white.opacity(0.18) }
        if option == quizData.answer {
            return Color.green.opacity(0.9)
        }
        if option == selectedAnswer {
            return Color.red.opacity(0.9)
        }
        return Color.white.opacity(0.12)
    }

    private func shadowColor(option: String) -> Color {
        guard isRevealed else { return Color.black.opacity(0.28) }
        if option == quizData.answer {
            return Color.green.opacity(0.4)
        }
        if option == selectedAnswer {
            return Color.red.opacity(0.35)
        }
        return Color.black.opacity(0.25)
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

    private func optionIcon(option: String) -> String? {
        guard isRevealed else { return nil }
        if option == quizData.answer {
            return "checkmark.circle.fill"
        }
        if option == selectedAnswer {
            return "xmark.circle.fill"
        }
        return "circle"
    }

    private var skipButton: some View {
        Button(action: {
            HapticsManager.selection()
            onSkipQuestion()
        }) {
            Text("スキップ")
                .font(.footnote)
                .bold()
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var revealSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !showDetails {
                Button(action: {
                    HapticsManager.mediumTap()
                    withAnimation { showDetails = true }
                }) {
                    Text("解説を見る")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.black)
                        .cornerRadius(16)
                        .shadow(color: Color.cyan.opacity(0.35), radius: 14, x: 0, y: 8)
                }
                .buttonStyle(PressableButtonStyle())
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("解説")
                            .font(.headline)
                            .foregroundColor(.yellow)
                        Spacer()
                        translationToggle(isVisible: showExplanationTranslation, action: { showExplanationTranslation.toggle() }, label: "解説の訳")
                    }
                    Text(quizData.explanation)
                        .foregroundColor(.white)
                        .font(bodyFont)
                        .lineSpacing(lineSpacing)
                    if shouldShowExplanationTranslation {
                        Text(quizData.explanationJapanese)
                            .foregroundColor(.secondary)
                            .font(bodyFont)
                            .lineSpacing(lineSpacing)
                    }
                    if !quizData.vocabulary.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("語彙")
                                .font(.headline)
                                .foregroundColor(.yellow)
                            ForEach(quizData.vocabulary, id: \.word) { vocab in
                                VocabularyCardView(vocab: vocab)
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

    private var categoryBadge: some View {
        Text(category)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.cyan.opacity(0.15))
                    .overlay(Capsule().stroke(Color.cyan.opacity(0.5), lineWidth: 1))
            )
            .foregroundColor(.cyan)
    }

    private var difficultyBadge: some View {
        Text(quizData.difficulty)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.12))
            )
            .foregroundColor(.white.opacity(0.9))
    }

    private func translationToggle(isVisible: Bool, action: @escaping () -> Void, label: String) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "character.bubble")
                    .font(.caption.weight(.bold))
                Text(isVisible ? "🇯🇵 \(label)を隠す" : "🇯🇵 \(label)を見る")
            }
            .font(.caption.weight(.semibold))
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(isVisible ? "\(label)の日本語訳を非表示" : "\(label)の日本語訳を表示")
        .accessibilityHint("日本語訳の表示を切り替えます。")
    }

    private var englishExpressionBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("使える表現 (英語)")
                .font(.subheadline)
                .foregroundColor(.cyan)
            Text(quizData.englishExpression ?? "ハイライトされた語彙で短い英文を作ってみましょう。")
                .font(readerMode ? .body.weight(.medium) : .callout)
                .foregroundColor(.white)
                .lineSpacing(lineSpacing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var knowledgeInsightBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ポイントメモ")
                .font(.subheadline)
                .foregroundColor(.cyan)
            Text(quizData.knowledgeInsight)
                .font(readerMode ? .body.weight(.medium) : .callout)
                .foregroundColor(.white)
                .lineSpacing(lineSpacing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func zippedOptions() -> [(en: String, jp: String?)] {
        if let jps = effectiveOptionsJapanese {
            return zip(quizData.options, jps).map { ($0.0, $0.1) }
        }
        return quizData.options.map { ($0, nil) }
    }

    private func shuffledOptions() -> [(en: String, jp: String?)] {
        return zippedOptions().shuffled()
    }

    private func resetTranslations() {
        showQuestionTranslation = globalTranslationEnabled
        showExplanationTranslation = globalTranslationEnabled
    }

    private func accessibilityLabel(for option: String) -> String {
        if isRevealed {
            if option == quizData.answer {
                return "\(option), correct answer"
            } else if option == selectedAnswer {
                return "\(option), your choice, incorrect"
            } else {
                return "\(option), not selected"
            }
        } else {
            return option
        }
    }
}

private struct VocabularyCardView: View {
    let vocab: VocabularyEntry
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(vocab.word)
                        .bold()
                        .foregroundColor(.white)
                    Text(vocab.partOfSpeech)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Button(action: {
                    HapticsManager.selection()
                    SpeechService.speak(vocab.word)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.cyan)
                }
                .buttonStyle(PlainButtonStyle())
            }
            Text(vocab.meaning)
                .foregroundColor(.white.opacity(0.95))
                .font(.subheadline)
            if isExpanded && !vocab.example.isEmpty {
                Text(vocab.example)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
        .onTapGesture {
            HapticsManager.selection()
            withAnimation(.easeInOut) {
                isExpanded.toggle()
            }
        }
        .accessibilityLabel("\(vocab.word), \(vocab.meaning)")
        .accessibilityHint("タップで例文を表示。スピーカーボタンで発音します。")
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
                        optionsJapanese: ["地球の公転", "太陽の自転", "地球の自転", "月の公転"],
                        answer: "Earth rotation",
                        explanation: "The Earth rotates on its axis, making the Sun appear to move across the sky and creating day and night.",
                        explanationJapanese: "地球が自転しているので、太陽が空を移動して見え、昼と夜が生じます。",
                        vocabulary: [VocabularyEntry(word: "rotate", meaning: "回転する"), VocabularyEntry(word: "axis", meaning: "軸")]
                    ),
                selectedAnswer: nil,
                onSelectAnswer: { _ in },
                onSkipQuestion: {},
                category: "Science",
                globalTranslationEnabled: false,
                readerMode: false,
                progress: 0.45,
                questionNumber: 2,
                totalQuestions: 5
            )
        .preferredColorScheme(.dark)
        .padding()
    }
}
