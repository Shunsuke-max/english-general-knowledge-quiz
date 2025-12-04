import SwiftUI

struct HistoryView: View {
    let history: [QuizResult]
    let onBack: () -> Void
    let onClear: () -> Void

    @State private var showingClearAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("履歴")
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: onBack) {
                    Text("← 戻る")
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            if history.isEmpty {
                Text("まだ履歴がありません。まずは1問解いてみましょう。")
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(history) { result in
                            HistoryRow(result: result)
                        }
                    }
                }
                Button(action: { showingClearAlert = true }) {
                    Text("履歴を削除")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.bottom, 8)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.black.opacity(0.6)))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
        .alert("履歴を削除しますか？", isPresented: $showingClearAlert) {
            Button("削除する", role: .destructive, action: onClear)
            Button("キャンセル", role: .cancel, action: {})
        } message: {
            Text("この操作は取り消せません。")
        }
    }
}

fileprivate struct HistoryRow: View {
    let result: QuizResult

    private var percentage: Int {
        guard result.totalQuestions > 0 else { return 0 }
        return Int((Double(result.score) / Double(result.totalQuestions)) * 100)
    }

    private var scoreColor: Color {
        switch percentage {
        case 0..<50: return .red
        case 50..<75: return .yellow
        default: return .cyan
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: result.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(result.category)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            ProgressView(value: Double(percentage), total: 100)
                .accentColor(scoreColor)
            HStack {
                Text("\(result.score) / \(result.totalQuestions)")
                    .foregroundColor(.white)
                    .font(.subheadline)
                Spacer()
                Text("\(percentage)%")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(
            history: [
                QuizResult(score: 4, totalQuestions: 5, category: "Science", date: Date()),
                QuizResult(score: 2, totalQuestions: 5, category: "History", date: Date().addingTimeInterval(-3600))
            ],
            onBack: {},
            onClear: {}
        )
        .preferredColorScheme(.dark)
    }
}
