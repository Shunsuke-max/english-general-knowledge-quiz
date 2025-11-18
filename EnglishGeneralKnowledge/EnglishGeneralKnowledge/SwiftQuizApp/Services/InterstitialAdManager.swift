import Foundation
import UIKit
import GoogleMobileAds

final class InterstitialAdManager: NSObject {
    static let shared = InterstitialAdManager()

    private let adUnitID = "ca-app-pub-9982720117568146/7192996286"
    private var interstitialAd: InterstitialAd?
    private var presentCompletion: (() -> Void)?

    private override init() {
        super.init()
        loadAd()
    }

    var isAdReady: Bool {
        interstitialAd != nil
    }

    func loadAd() {
        guard interstitialAd == nil else { return }
        let request = Request()
        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("InterstitialAdManager failed to load ad:", error.localizedDescription)
                return
            }
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    func present(from viewController: UIViewController, completion: @escaping () -> Void) {
        guard let ad = interstitialAd else {
            completion()
            loadAd()
            return
        }
        presentCompletion = completion
        ad.present(from: viewController)
        interstitialAd = nil
    }
}

extension InterstitialAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        presentCompletion?()
        presentCompletion = nil
        loadAd()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("InterstitialAdManager failed to present ad:", error.localizedDescription)
        presentCompletion?()
        presentCompletion = nil
        loadAd()
    }
}
