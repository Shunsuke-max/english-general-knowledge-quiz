import SwiftUI

struct ResultsView: View {
    let score: Int
    let total: Int
    let incorrectAnswers: [QuizQuestion]
    let onPlayAgain: () -> Void
    let onRetryWeakCategory: ((String) -> Void)?
    let globalTranslationEnabled: Bool
    let weeklyMissionProgress: WeeklyMissionProgress
    let weakVocabularyDeck: [VocabularyEntry]
    @State private var showingVocabReview = false

    init(
        score: Int,
        total: Int,
        incorrectAnswers: [QuizQuestion],
        onPlayAgain: @escaping () -> Void,
        onRetryWeakCategory: ((String) -> Void)? = nil,
        globalTranslationEnabled: Bool,
        weeklyMissionProgress: WeeklyMissionProgress,
        weakVocabularyDeck: [VocabularyEntry]
    ) {
        self.score = score
        self.total = total
        self.incorrectAnswers = incorrectAnswers
        self.onPlayAgain = onPlayAgain
        self.onRetryWeakCategory = onRetryWeakCategory
        self.globalTranslationEnabled = globalTranslationEnabled
        self.weeklyMissionProgress = weeklyMissionProgress
        self.weakVocabularyDeck = weakVocabularyDeck
    }

    private var literacyBadge: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("英語力の目安")
                    .font(.headline)
                Spacer()
                levelChip(for: literacyLevel)
            }
            Text(literacyLevel.hint)
                .font(.caption)
                .foregroundColor(.subtleText)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var percentage: Int {
        guard total > 0 else { return 0 }
        return Int((Double(score) / Double(total)) * 100)
    }

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(score) / Double(total)
    }

    private var performanceLabel: String {
        switch percentage {
        case 100:
            return "パーフェクト！"
        case 80..<100:
            return "いい調子です"
        case 50..<80:
            return "もう少しで安定"
        default:
            return "ここから基礎固め"
        }
    }

    private var performanceHint: String {
        if incorrectAnswers.isEmpty {
            return "全問正解！次は出題数や難易度を上げてみましょう。"
        } else {
            return "間違えた設問の解説と語彙を軽くチェック。"
        }
    }

    private var insightMessage: String {
        if incorrectAnswers.isEmpty {
            return "ミスなし。気分に合わせて問題数を増やすか難易度をHardへ。"
        }
        return "今回は\(incorrectAnswers.count)問ミス。下の解説と語彙で弱点チェック。"
    }

    private var aggregatedVocabulary: [VocabularyEntry] {
        var seen = Set<String>()
        var collection: [VocabularyEntry] = []
        for question in incorrectAnswers {
            for entry in question.vocabulary where !seen.contains(entry.word) {
                seen.insert(entry.word)
                collection.append(entry)
            }
        }
        return collection
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("結果")
                    .font(.title)
                    .bold()

                performanceSummary

                literacyBadge

                learningInsight

                reviewSection

                weeklyMissionCard

                weakVocabularySection

                vocabularyHighlights

                ctaButtons
            }
            .padding()
            .foregroundColor(.white)
        }
        .background(
            LinearGradient(
                colors: [Color.deepNight, Color.deepSpace],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .padding(.horizontal)
        .sheet(isPresented: $showingVocabReview) {
            VocabReviewView(vocabDeck: weakVocabularyDeck)
        }
    }

    private var performanceSummary: some View {
            VStack(spacing: 18) {
                scoreBadge
                Text("正答率 \(percentage)%")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                accuracyMeter
                Text(performanceLabel)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(performanceHint)
                    .foregroundColor(.subtleText)
                    .font(.subheadline)
                HStack(spacing: 12) {
                    statView(title: "正解", value: "\(score)")
                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.3))
                    statView(title: "不正解", value: "\(total - score)")
                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.3))
                    statView(title: "正答率", value: "\(percentage)%")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [Color.white.opacity(0.05), Color.white.opacity(0.01)], startPoint: .top, endPoint: .bottom))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }

    private func statView(title: String, value: String) -> some View {
        VStack {
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }

    private var accuracyMeter: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.15))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: progressColorGradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geometry.size.width * CGFloat(progress)))
            }
        }
        .frame(height: 10)
    }

    private var learningInsight: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("学習メモ", systemImage: "lightbulb")
                .font(.headline)
                .foregroundColor(.cyan)
            Text(insightMessage)
                .foregroundColor(.white)
                .font(.subheadline)
            if let weakest = weakestCategory {
                Text("次は \(weakest) を少し集中して解いてみましょう。")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.cyan)
                    .frame(width: 6, height: 6)
                Text("間違えた問題を復習")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            if incorrectAnswers.isEmpty {
                Text("全問正解でした！もう一度遊ぶか、Hardで再挑戦してみましょう。")
                    .foregroundColor(.subtleText)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(incorrectAnswers) { question in
                        ReviewCard(question: question, globalTranslationEnabled: globalTranslationEnabled)
                            .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 4)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.02)))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var vocabularyHighlights: some View {
        Group {
            if aggregatedVocabulary.isEmpty {
                EmptyView()
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 6, height: 6)
                        Text("覚えておきたい語彙")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    ForEach(aggregatedVocabulary, id: \.word) { entry in
                        HStack {
                            Text(entry.word)
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                            Text(entry.meaning)
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }

    private var weakVocabularySection: some View {
        Group {
            if weakVocabularyDeck.isEmpty {
                EmptyView()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("弱点語彙デッキ")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    Text("タップで発音をチェック。")
                        .font(.caption)
                        .foregroundColor(.subtleText)
                    LazyVStack(spacing: 8) {
                        ForEach(weakVocabularyDeck, id: \.word) { vocab in
                            WeakVocabRow(vocab: vocab)
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }

    private var weeklyMissionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("今週のミッション", systemImage: weeklyMissionProgress.completed ? "checkmark.seal.fill" : "flag.checkered")
                    .foregroundColor(.cyan)
                    .font(.headline)
                Spacer()
                Text("\(Int(weeklyMissionProgress.progressRatio * 100))%")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
            Text("正答率80%以上を \(weeklyMissionProgress.targetCategoryCount) カテゴリで達成しよう。")
                .font(.caption)
                .foregroundColor(.subtleText)
            ProgressView(value: weeklyMissionProgress.progressRatio)
                .progressViewStyle(LinearProgressViewStyle(tint: weeklyMissionProgress.completed ? .green : .cyan))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var ctaButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                HapticsManager.mediumTap()
                onPlayAgain()
            }) {
                Text("もう一度プレイ")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .buttonStyle(PressableButtonStyle())
            if let weakest = weakestCategory, let retry = onRetryWeakCategory {
                Button(action: {
                    HapticsManager.selection()
                    retry(weakest)
                }) {
                    Text("\(weakest) を5問リトライ")
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .buttonStyle(PressableButtonStyle())
            }
            if weakVocabularyDeck.isEmpty == false {
                Button(action: {
                    HapticsManager.mediumTap()
                    showingVocabReview = true
                }) {
                    Text("語彙だけ復習する")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private var weakestCategory: String? {
        guard !incorrectAnswers.isEmpty else { return nil }
        let counts = incorrectAnswers.reduce(into: [String: Int]()) { acc, q in
            acc[q.category, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    private var literacyLevel: LiteracyLevel {
        LiteracyLevel.from(accuracy: Double(percentage) / 100.0)
    }

    private func levelChip(for level: LiteracyLevel) -> some View {
        Text(level.title)
            .font(.caption.bold())
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(levelBackground(level))
            .foregroundColor(.white)
            .cornerRadius(12)
    }

    private func levelBackground(_ level: LiteracyLevel) -> Color {
        switch level {
        case .starter: return Color.red.opacity(0.6)
        case .explorer: return Color.orange.opacity(0.7)
        case .insightful: return Color.blue.opacity(0.6)
        case .scholar: return Color.green.opacity(0.6)
        }
    }

    private var progressColorGradient: [Color] {
        switch percentage {
        case 80...100: return [Color.green, Color.cyan]
        case 50..<80: return [Color.yellow, Color.orange]
        default: return [Color.red.opacity(0.8), Color.orange]
        }
    }

    private var scoreBadge: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.cyan.opacity(0.4), Color.blue.opacity(0.2), Color.clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
            .frame(width: 200, height: 200)
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 14)
            .frame(width: 200, height: 200)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.cyan, Color.blue, Color.purple]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .butt)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 200, height: 200)
                .animation(.easeOut(duration: 0.9), value: progress)
            VStack {
                Text("\(score)")
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundColor(.white)
                Text("/ \(total)")
                    .foregroundColor(.subtleText)
                    .font(.subheadline)
            }
        }
    }

}

private extension Color {
    static let deepNight = Color(red: 11 / 255, green: 17 / 255, blue: 32 / 255)
    static let deepSpace = Color(red: 2 / 255, green: 6 / 255, blue: 23 / 255)
    static let subtleText = Color.white.opacity(0.75)
}

fileprivate struct ReviewCard: View {
    let question: QuizQuestion
    let globalTranslationEnabled: Bool
    @State var showTranslation: Bool = false

    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    categoryBadge
                    difficultyBadge
                    Spacer()
                    translationToggle
                }
                Text("\"\(question.question)\"")
                    .bold()
                    .foregroundColor(.white)
                if showTranslation || globalTranslationEnabled {
                    Text(question.questionJapanese)
                        .foregroundColor(.subtleText)
                        .font(.body)
                }
                Text("正解: \(question.answer)")
                    .foregroundColor(.cyan)
                    .font(.subheadline)
                Text(question.explanation)
                    .foregroundColor(.white)
                    .font(.body)
                if showTranslation || globalTranslationEnabled {
                    Text(question.explanationJapanese)
                        .foregroundColor(.subtleText)
                        .font(.body)
                }
                if let expression = question.englishExpression {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("使える表現 (英語)")
                            .font(.subheadline)
                            .foregroundColor(.cyan)
                        Text(expression)
                            .foregroundColor(.white)
                            .font(.callout)
                        Text(question.knowledgeInsight)
                            .foregroundColor(.subtleText)
                            .font(.caption)
                    }
                    .padding(.top, 4)
                } else {
                    Text(question.knowledgeInsight)
                        .foregroundColor(.subtleText)
                        .font(.caption)
                        .padding(.top, 4)
                }
                if !question.vocabulary.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("語彙の確認")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                        ForEach(question.vocabulary, id: \.word) { vocab in
                            HStack(alignment: .top, spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(vocab.word)
                                        .bold()
                                        .foregroundColor(.white)
                                    Text(vocab.partOfSpeech)
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(vocab.meaning)
                                        .foregroundColor(.white.opacity(0.95))
                                        .font(.caption)
                                    if !vocab.example.isEmpty {
                                        Text(vocab.example)
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.7))
                                            .multilineTextAlignment(.trailing)
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                        }
                    }
                }
            }
        .padding()
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
    }

    private var translationToggle: some View {
        Button(action: { showTranslation.toggle() }) {
            Text(showTranslation || globalTranslationEnabled ? "🇯🇵 非表示" : "🇯🇵 表示")
                .font(.caption)
                .foregroundColor(.cyan)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(showTranslation || globalTranslationEnabled ? "日本語訳を非表示" : "日本語訳を表示")
    }

    private var categoryBadge: some View {
        Text(question.category)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.cyan.opacity(0.15)))
            .overlay(Capsule().stroke(Color.cyan.opacity(0.5), lineWidth: 1))
            .foregroundColor(.cyan)
    }

    private var difficultyBadge: some View {
        Text(question.difficulty)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.white.opacity(0.12)))
            .foregroundColor(.white.opacity(0.9))
    }
}

fileprivate struct WeakVocabRow: View {
    let vocab: VocabularyEntry

    var body: some View {
        Button(action: {
            HapticsManager.selection()
            SpeechService.speak(vocab.word)
        }) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(vocab.word)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(vocab.meaning)
                        .font(.caption)
                        .foregroundColor(.subtleText)
                }
                Spacer()
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.cyan)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("\(vocab.word), \(vocab.meaning)")
        .accessibilityHint("タップで発音を再生します。")
    }
}

fileprivate struct VocabReviewView: View {
    let vocabDeck: [VocabularyEntry]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(vocabDeck, id: \.word) { vocab in
                    WeakVocabRow(vocab: vocab)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .navigationTitle("単語の復習")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [Color.deepNight, Color.deepSpace],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}
