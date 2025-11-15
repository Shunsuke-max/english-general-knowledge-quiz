import SwiftUI

struct ResultsView: View {
    let score: Int
    let total: Int
    let incorrectAnswers: [QuizQuestion]
    let onPlayAgain: () -> Void

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
            return "Outstanding streak"
        case 80..<100:
            return "Great performance"
        case 50..<80:
            return "Keep building momentum"
        default:
            return "Start with a steady pace"
        }
    }

    private var performanceHint: String {
        if incorrectAnswers.isEmpty {
            return "You nailed every question!"
        } else {
            return "Review these prompts to reinforce the concepts."
        }
    }

    private var insightMessage: String {
        if incorrectAnswers.isEmpty {
            return "No numbers missed this round—feel free to move on or challenge yourself with more questions."
        }
        return "You missed \(incorrectAnswers.count) question\(incorrectAnswers.count > 1 ? "s" : ""). Focus on their vocabulary and explanation below."
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
                Text("Quiz Complete!")
                    .font(.title)
                    .bold()

                performanceSummary

                learningInsight

                reviewSection

                vocabularyHighlights

                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
            .padding()
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
    }

    private var performanceSummary: some View {
            VStack(spacing: 18) {
                scoreBadge
                Text("\(percentage)% Accuracy")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                accuracyMeter
                Text(performanceLabel)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(performanceHint)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                HStack(spacing: 12) {
                    statView(title: "Correct", value: "\(score)")
                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.3))
                    statView(title: "Incorrect", value: "\(total - score)")
                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.3))
                    statView(title: "Accuracy", value: "\(percentage)%")
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
                            colors: [Color.cyan, Color.blue],
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
            Label("Learning Insight", systemImage: "lightbulb")
                .font(.headline)
                .foregroundColor(.cyan)
            Text(insightMessage)
                .foregroundColor(.white)
                .font(.subheadline)
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
                Text("Review what you missed")
                    .font(.headline)
            }
            if incorrectAnswers.isEmpty {
                Text("All answers were correct! Feel free to take another round or try a harder difficulty.")
                    .foregroundColor(.secondary)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(incorrectAnswers) { question in
                        ReviewCard(question: question)
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
                        Text("Vocabulary to revisit")
                            .font(.headline)
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
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 200, height: 200)
                .animation(.easeOut(duration: 0.9), value: progress)
            VStack {
                Text("\(score)")
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundColor(.white)
                Text("/ \(total)")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
    }

}

private extension Color {
    static let deepNight = Color(red: 11 / 255, green: 17 / 255, blue: 32 / 255)
    static let deepSpace = Color(red: 2 / 255, green: 6 / 255, blue: 23 / 255)
}

fileprivate struct ReviewCard: View {
    let question: QuizQuestion

    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("\"\(question.question)\"")
                    .bold()
                    .foregroundColor(.white)
                Text("Correct answer: \(question.answer)")
                    .foregroundColor(.cyan)
                    .font(.subheadline)
                Text(question.explanation)
                    .foregroundColor(.white)
                    .font(.body)
                if let expression = question.englishExpression {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("English Expression")
                            .font(.subheadline)
                            .foregroundColor(.cyan)
                        Text(expression)
                            .foregroundColor(.white)
                            .font(.callout)
                        Text(question.knowledgeInsight)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.top, 4)
                } else {
                    Text(question.knowledgeInsight)
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .padding(.top, 4)
                }
                if !question.vocabulary.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vocabulary boost:")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                    ForEach(question.vocabulary, id: \.word) { vocab in
                        HStack {
                            Text(vocab.word)
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                            Text(vocab.meaning)
                                .foregroundColor(.white.opacity(0.95))
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(
            score: 3,
            total: 5,
            incorrectAnswers: [
                QuizQuestion(
                    category: "Science",
                    difficulty: "Medium",
                    question: "Why is the sky blue?",
                    questionJapanese: "空が青く見える理由は何ですか？",
                    options: ["Reflective ocean", "Rayleigh scattering", "Blue planets", "Atmospheric ozone"],
                    answer: "Rayleigh scattering",
                    explanation: "Shorter wavelengths scatter more in the atmosphere, giving the sky a blue hue.",
                    explanationJapanese: "大気中では波長の短い光ほど散乱しやすく、空が青く見えます。",
                    vocabulary: [VocabularyEntry(word: "scatter", meaning: "散乱する")]
                )
            ],
            onPlayAgain: {}
        )
        .preferredColorScheme(.dark)
    }
}
