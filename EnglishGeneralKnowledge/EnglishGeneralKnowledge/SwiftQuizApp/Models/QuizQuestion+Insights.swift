import Foundation

extension QuizQuestion {
    var englishExpression: String? {
        if let raw = englishExpressionRaw, !raw.isEmpty {
            return raw
        }
        let otherOptions = options.filter { $0 != answer }
        guard !otherOptions.isEmpty else {
            return "Try turning the explanation into a sentence you can say aloud."
        }

        let otherList = humanReadableList(otherOptions)
        let basePrompt = question.trimmingCharacters(in: .whitespacesAndNewlines)
        return "The other choices—\(otherList)—are decoys, so keep \(answer) in mind whenever you see \"\(basePrompt)\"."
    }

    var knowledgeInsight: String {
        if let insight = knowledgeInsightRaw, !insight.isEmpty {
            return insight
        }
        let trimmed = question.trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .whitespaces)
        return "Remember that \(answer) answers \"\(trimmed)\"—that link helps you retain both the fact and why it matters."
    }
}

private func humanReadableList(_ items: [String]) -> String {
    switch items.count {
    case 0:
        return ""
    case 1:
        return items[0]
    case 2:
        return "\(items[0]) and \(items[1])"
    default:
        let allButLast = items.dropLast().joined(separator: ", ")
        return "\(allButLast), and \(items.last!)"
    }
}
