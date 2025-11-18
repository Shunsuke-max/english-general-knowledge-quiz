import SwiftUI
import GoogleMobileAds

/// AdMobバナー広告をSwiftUIで表示するためのビュー
struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = getRootViewController()
        banner.load(GADRequest())
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return rootViewController
    }
}

/// バナー広告をアプリに簡単に追加するためのView Modifier
struct BannerAdModifier: ViewModifier {
    let adUnitID: String
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            
            BannerAdView(adUnitID: adUnitID)
                .frame(height: 50)
                .background(Color(.systemBackground))
        }
    }
}

extension View {
    /// バナー広告を画面下部に追加
    /// - Parameter adUnitID: AdMob広告ユニットID
    func withBannerAd(adUnitID: String) -> some View {
        modifier(BannerAdModifier(adUnitID: adUnitID))
    }
}
