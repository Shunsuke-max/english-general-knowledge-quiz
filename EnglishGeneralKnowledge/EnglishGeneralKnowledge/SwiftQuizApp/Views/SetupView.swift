import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: QuizViewModel
    @State private var showHero = true
    
    private var labelColor: Color { Color.white.opacity(0.9) }
    
    private let questionOptions = [5, 10, 15]
    private let categoryOptions = ["Random", "History", "Science", "Geography", "Technology", "Pop Culture", "Sports", "Nature & Animals"]
    private let difficultyOptions = ["Easy", "Medium", "Hard", "Random"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("英語×教養クイズ")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                    Text("出題設定を決めてスタート")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                heroBanner
                guidanceCard
                goalReminder
                selectionSummaryCard
                VStack(spacing: 22) {
                    optionSection(
                        icon: "list.number",
                        title: "1. 出題数を選ぶ",
                        subtitle: "目安: 5問 ≈3分 / 10問 ≈6分 / 15問 ≈10分",
                        items: questionOptions.map(String.init),
                        selection: String(viewModel.numberOfQuestions)
                    ) { option in
                        if let value = Int(option) {
                            viewModel.numberOfQuestions = value
                        }
                    }
                    optionSection(
                        icon: "dial.medium",
                        title: "2. 難易度を選ぶ",
                        subtitle: "Easy: かんたん / Medium: ふつう / Hard: むずかしい",
                        items: difficultyOptions,
                        selection: viewModel.selectedDifficulty,
                        action: { viewModel.selectedDifficulty = $0 }
                    )
                    categorySection
                    startButton
                    if viewModel.quizHistory.isEmpty == false {
                        historyButton
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 26)
                        .fill(Color.white.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1.2)
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 32)
        }
        .dynamicTypeSize(.medium ... .accessibility5)
    }
    
    private var heroBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("サクッとクイズを作る")
                        .font(.title2.weight(.heavy))
                        .foregroundColor(.white)
                    Text("設問は英語・解説は日英併記。設定を選んで気軽に挑戦。")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.subheadline)
                }
                Spacer()
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.system(size: 36))
                    .foregroundStyle(.white.opacity(0.9))
            }
            HStack(spacing: 10) {
                featureChip(icon: "wand.and.stars", text: "AI自動生成")
                featureChip(icon: "text.bubble.rtl", text: "日英解説つき")
                featureChip(icon: "stopwatch", text: "短時間で完了")
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [Color.cyan.opacity(0.35), Color.blue.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.white.opacity(0.25), lineWidth: 1.2)
        )
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white.opacity(0.08))
                .blur(radius: 16)
        )
        .cornerRadius(26)
    }

    private var selectionSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("現在の設定")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
                highlightChip(icon: "bolt.fill", title: "出題数", value: "\(viewModel.numberOfQuestions)問")
                highlightChip(icon: "dial.medium", title: "難易度", value: viewModel.selectedDifficulty)
                highlightChip(icon: "globe.americas.fill", title: "カテゴリ", value: viewModel.selectedCategory)
            }
            Divider().background(Color.white.opacity(0.1))
            VStack(spacing: 10) {
                toggleRow(
                    isOn: viewModel.showGlobalTranslation,
                    onToggle: {
                        HapticsManager.selection()
                        viewModel.showGlobalTranslation.toggle()
                    },
                    iconOn: "character.bubble.fill",
                    iconOff: "character.bubble",
                    label: "訳表示",
                    hint: "問題・解説を日英併記で表示"
                )
                toggleRow(
                    isOn: viewModel.readerMode,
                    onToggle: {
                        HapticsManager.selection()
                        viewModel.readerMode.toggle()
                    },
                    iconOn: "textformat.size.larger",
                    iconOff: "textformat.size",
                    label: "読みやすさ",
                    hint: "フォント/行間を広めにして読みやすく"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
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

    private func toggleRow(isOn: Bool, onToggle: @escaping () -> Void, iconOn: String, iconOff: String, label: String, hint: String) -> some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isOn ? iconOn : iconOff)
                    .font(.headline.bold())
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline.bold())
                    Text(hint)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.75))
                }
                Spacer()
                Text(isOn ? "ON" : "OFF")
                    .font(.caption.bold())
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.white.opacity(isOn ? 0.22 : 0.08))
                    .cornerRadius(10)
            }
            .foregroundColor(.white)
            .padding()
            .background(
                LinearGradient(
                    colors: isOn
                        ? [Color.cyan.opacity(0.35), Color.blue.opacity(0.35)]
                        : [Color.white.opacity(0.05), Color.white.opacity(0.05)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .cornerRadius(14)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(label)
    }
    
    private func optionSection(icon: String, title: String, subtitle: String, items: [String], selection: String, action: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(.cyan)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(labelColor)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 12)], alignment: .leading, spacing: 12) {
                ForEach(items, id: \.self) { item in
                    optionButton(item: item, selection: selection, action: action)
                }
            }
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("3. カテゴリを選ぶ")
                .font(.headline)
                .foregroundColor(labelColor)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], alignment: .leading, spacing: 12) {
                ForEach(categoryOptions, id: \.self) { category in
                    Button(action: {
                        HapticsManager.selection()
                        viewModel.selectedCategory = category
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category)
                                    .bold()
                                    .foregroundColor(.white)
                                Text(category == "Random" ? "バランス良く出題" : "\(category) を中心に出題")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                            Image(systemName: viewModel.selectedCategory == category ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(viewModel.selectedCategory == category ? .black : .white.opacity(0.8))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(categoryBackground(isSelected: viewModel.selectedCategory == category))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
    }
    
    private var startButton: some View {
        Button(action: {
            HapticsManager.mediumTap()
            viewModel.startQuiz()
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(viewModel.isLoading ? "問題を作成中…" : "\(viewModel.numberOfQuestions)問で始める")
                    .font(.headline)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundColor(.black)
            .cornerRadius(16)
            .shadow(color: Color.cyan.opacity(0.4), radius: 18, x: 0, y: 10)
            .overlay(
                HStack {
                    Text("👆 設定OKならスタート")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 6),
                alignment: .bottomLeading
            )
        }
        .disabled(viewModel.isLoading)
        .buttonStyle(PressableButtonStyle())
    }

    private var historyButton: some View {
        Button(action: {
            HapticsManager.selection()
            viewModel.viewHistory()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("履歴を見る (\(viewModel.quizHistory.count))")
                        .bold()
                        Text("前回のスコアを見直して弱点カテゴリを復習しましょう。")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.75))
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .disabled(viewModel.isLoading)
        .buttonStyle(PressableButtonStyle())
    }

    private func featureChip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .bold()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.14))
        .cornerRadius(12)
    }

    private var guidanceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("4ステップですぐ開始")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("ここから")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.cyan.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            VStack(alignment: .leading, spacing: 8) {
                guidanceRow(step: "1", text: "出題数を選択 (5/10/15)")
                guidanceRow(step: "2", text: "難易度を選択 (Easy/Medium/Hard)")
                guidanceRow(step: "3", text: "カテゴリ or Random を選択")
                guidanceRow(step: "4", text: "Startで英語の設問を作成")
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func guidanceRow(step: String, text: String) -> some View {
        HStack(spacing: 10) {
            Text(step)
                .font(.caption.bold())
                .frame(width: 22, height: 22)
                .background(Color.cyan.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(6)
            Text(text)
                .foregroundColor(.white.opacity(0.9))
                .font(.subheadline)
        }
    }

    private var goalReminder: some View {
        let remaining = max(0, viewModel.dailyGoal - viewModel.todayAnsweredCount)
        return HStack(alignment: .center, spacing: 12) {
            Image(systemName: viewModel.hasMetDailyGoal ? "checkmark.seal.fill" : "target")
                .foregroundColor(viewModel.hasMetDailyGoal ? .green : .cyan)
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.hasMetDailyGoal ? "今日の目標は達成済み！" : "今日の目標: \(viewModel.dailyGoal)問")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(viewModel.hasMetDailyGoal ? "明日も1問でも答えて連続記録を維持。" : "あと \(remaining) 問で達成。今すぐ始めよう。")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
            }
            Spacer()
            if viewModel.hasMetDailyGoal {
                Text("🎉")
                    .font(.title2)
            } else {
                Text("⏳")
                    .font(.title3)
            }
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
 
    @ViewBuilder
    private func categoryBackground(isSelected: Bool) -> some View {
        if isSelected {
            LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            Color.white.opacity(0.08)
        }
    }

    private func optionButton(item: String, selection: String, action: @escaping (String) -> Void) -> some View {
        let isSelected = selection == item
        return Button(action: {
            HapticsManager.selection()
            action(item)
        }) {
            Text(item)
                .bold()
                .foregroundColor(isSelected ? .black : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.08))
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(optionGradient)
                        }
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.white.opacity(0.7) : Color.white.opacity(0.15), lineWidth: 1.5)
                    }
                )
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var optionGradient: LinearGradient {
        LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    struct SetupView_Previews: PreviewProvider {
        static var previews: some View {
            SetupView(viewModel: QuizViewModel())
                .preferredColorScheme(.dark)
        }
    }
}
