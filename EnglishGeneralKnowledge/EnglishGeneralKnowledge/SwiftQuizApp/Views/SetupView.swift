import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: QuizViewModel

    private var labelColor: Color { Color.white.opacity(0.9) }

    private let questionOptions = [5, 10, 15]
    private let categoryOptions = ["Random", "History", "Science", "Geography", "Technology", "Pop Culture", "Sports", "Nature & Animals"]
    private let difficultyOptions = ["Easy", "Medium", "Hard", "Random"]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("06090f").opacity(0.9), Color("0d1a2f")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    optionSection(title: "1. How many questions?", items: questionOptions.map(String.init), selection: String(viewModel.numberOfQuestions)) { option in
                        if let value = Int(option) {
                            viewModel.numberOfQuestions = value
                        }
                    }
                    optionSection(title: "2. Select difficulty", items: difficultyOptions, selection: viewModel.selectedDifficulty) { viewModel.selectedDifficulty = $0 }
                    categorySection
                    startButton
                    stockButton
                    if let progress = viewModel.stockingProgress {
                        stockingView(progress: progress)
                    }
                    if viewModel.quizHistory.isEmpty == false {
                        Button(action: viewModel.viewHistory) {
                            Text("View History (\(viewModel.quizHistory.count))")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.12))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                        .disabled(viewModel.isStocking)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 26)
                        .fill(Color.black.opacity(0.5))
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(LinearGradient(colors: [Color.cyan.opacity(0.5), Color.blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                        )
                )
                .padding(.horizontal)
                .padding(.vertical, 30)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Welcome to the Quiz Challenge!")
                    .font(.title2)
                    .bold()
                    .foregroundColor(labelColor)
                Text("Configure your session and get a fresh set of curated questions.")
                    .foregroundColor(labelColor)
                    .font(.subheadline)
            }
            Spacer()
        }
    }

    private func optionSection(title: String, items: [String], selection: String, action: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(labelColor)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 12)], alignment: .leading, spacing: 12) {
                ForEach(items, id: \.self) { item in
                    Button(action: { action(item) }) {
                        Text(item)
                            .bold()
                            .foregroundColor(selection == item ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selection == item ? Color.cyan : Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("3. Choose a category")
                .font(.headline)
                .foregroundColor(labelColor)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], alignment: .leading, spacing: 12) {
                ForEach(categoryOptions, id: \.self) { category in
                    Button(action: { viewModel.selectedCategory = category }) {
                        Text(category)
                            .bold()
                            .foregroundColor(viewModel.selectedCategory == category ? .black : .white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .frame(maxWidth: .infinity)
                            .background(viewModel.selectedCategory == category ? Color.cyan : Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            }
        }
    }

    private var startButton: some View {
        Button(action: viewModel.startQuiz) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(viewModel.isLoading ? "Generating Quiz..." : "Start Quiz")
                    .font(.headline)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .disabled(viewModel.isLoading || viewModel.isStocking)
    }

    private var stockButton: some View {
        Button(action: viewModel.stockQuestions) {
            Text(viewModel.isStocking ? "Stocking..." : "Stock Up Questions")
                .font(.headline)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .foregroundColor(.white)
                .cornerRadius(16)
        }
        .disabled(viewModel.isStocking || viewModel.isLoading)
    }

    private func stockingView(progress: StockProgress) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(progress.message)
                .font(.caption)
                .foregroundColor(labelColor.opacity(0.8))
            ProgressView(value: Double(progress.completed), total: Double(max(progress.total, 1)))
                .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
            Text("\(progress.completed) / \(progress.total)")
                .font(.caption2.monospaced())
                .foregroundColor(labelColor.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.top, 4)
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView(viewModel: QuizViewModel())
            .preferredColorScheme(.dark)
    }
}
