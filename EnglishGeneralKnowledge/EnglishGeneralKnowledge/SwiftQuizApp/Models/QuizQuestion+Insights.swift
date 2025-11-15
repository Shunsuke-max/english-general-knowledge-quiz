import Foundation

extension QuizQuestion {
    var englishExpression: String? {
        if let raw = englishExpressionRaw, !raw.isEmpty {
            return raw
        }
        let sentences = explanation.components(separatedBy: ".")
        let trimmed = sentences.first?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let snippet = trimmed, !snippet.isEmpty else { return nil }
        let baseReason = snippet.lowercased().hasSuffix("?") ? String(snippet.dropLast()) : snippet
        return "\(baseReason.lowercased())."
    }

    var knowledgeInsight: String {
        if let insight = knowledgeInsightRaw, !insight.isEmpty {
            return insight
        }
        let trimmed = question.trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .whitespaces)
        return "Remember that \(answer) answers \"\(trimmed)\"—that link helps you retain both the fact and why it matters."
    }
}
