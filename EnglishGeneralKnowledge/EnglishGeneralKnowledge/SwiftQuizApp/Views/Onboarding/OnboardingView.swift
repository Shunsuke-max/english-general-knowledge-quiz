import SwiftUI

struct OnboardingView: View {
    var onGetStarted: () -> Void
    var onSkip: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "英語と教養を同時にアップ",
            message: "5〜15問のクイックランで英語×教養を磨く。日英の解説と語彙つき。",
            icon: "sparkles",
            accent: Color.cyan,
            bullets: [
                "カテゴリ・難易度を選んで即開始",
                "問題と解説はJP/EN併記",
                "語彙カードで覚える単語が明確"
            ]
        ),
        OnboardingPage(
            title: "日英ヒント＋読みやすさモード",
            message: "JP/EN切替とリーダーモードで理解しやすく、長文も快適に読めます。",
            icon: "text.book.closed.fill",
            accent: Color.blue,
            bullets: [
                "JP/ENトグルで全体を瞬時に切替",
                "リーダーモードでフォント/行間拡大"

            ]
        ),
        OnboardingPage(
            title: "続けやすい仕組み",
            message: "日次目標・連続日数・弱点復習で習慣化をサポートします。",
            icon: "target",
            accent: Color.green,
            bullets: [
                "日次目標と連続日数を可視化",
                "弱点カテゴリ5問リトライ",
                "Vocab Reviewモードで単語だけ復習"
            ]
        )
    ]

    var body: some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 24) {
                stepProgress
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingCard(page: page, index: index, currentPage: $currentPage)
                            .padding(.horizontal, 24)
                            .tag(index)
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                pageIndicator
                VStack(spacing: 12) {
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            onGetStarted()
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "次へ" : "はじめる")
                            .font(.headline)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.black)
                            .cornerRadius(16)
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.96, pressedOpacity: 0.9))
                    Button(action: onSkip) {
                        Text("あとで")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white.opacity(0.85))
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(14)
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.98, pressedOpacity: 0.8))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
        }
    }

    private var stepProgress: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ステップ \(currentPage + 1) / \(pages.count)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            ProgressView(value: Double(currentPage + 1), total: Double(pages.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
                .frame(maxWidth: 320)
        }
        .padding(.top, 24)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: index == currentPage ? [Color.cyan, Color.blue] : [Color.white.opacity(0.3), Color.white.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
}

private struct OnboardingCard: View {
    let page: OnboardingPage
    let index: Int
    @Binding var currentPage: Int

    private var iconStack: some View {
        ZStack {
            Image(systemName: "hexagon.fill")
                .font(.system(size: 82))
                .foregroundColor(page.accent.opacity(0.25))
                .rotationEffect(.degrees(currentPage == index ? 8 : 0))
                .animation(.easeInOut(duration: 0.5), value: currentPage)
            Image(systemName: "circle.fill")
                .font(.system(size: 72))
                .foregroundColor(page.accent.opacity(0.32))
            Image(systemName: page.icon)
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: page.accent.opacity(0.6), radius: 10, x: 0, y: 6)
        }
    }

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(page.accent.opacity(0.18))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(Double(currentPage == index ? 4 : 0)))
                    .animation(.easeInOut(duration: 0.4), value: currentPage)
                Circle()
                    .stroke(page.accent.opacity(0.35), lineWidth: 6)
                    .frame(width: 150, height: 150)
                    .shadow(color: page.accent.opacity(0.4), radius: 18, x: 0, y: 8)
                iconStack
            }
            Text(page.title)
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text(page.message)
                .font(.body)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
            if page.bullets.isEmpty == false {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(page.bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.cyan)
                                .font(.caption)
                            Text(bullet)
                                .foregroundColor(.white.opacity(0.85))
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: 520)
        .background(Color.white.opacity(0.04))
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let icon: String
    let accent: Color
    let bullets: [String]
}

private struct AnimatedBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "050915"), Color(hex: "0c1224")], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            Circle()
                .fill(Color.cyan.opacity(0.18))
                .frame(width: 320, height: 320)
                .offset(x: animate ? -140 : -100, y: animate ? -240 : -280)
                .blur(radius: 120)
            Circle()
                .fill(Color.blue.opacity(0.16))
                .frame(width: 280, height: 280)
                .offset(x: animate ? 160 : 120, y: animate ? 220 : 200)
                .blur(radius: 140)
            Circle()
                .fill(Color.purple.opacity(0.18))
                .frame(width: 360, height: 360)
                .offset(x: animate ? 60 : 30, y: animate ? 430 : 410)
                .blur(radius: 170)
                .opacity(0.6)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
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
