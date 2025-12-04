import SwiftUI
import SwiftData
import GoogleMobileAds
import AppTrackingTransparency
import Combine

@main
struct EnglishGeneralKnowledgeApp: App {
    @StateObject private var adManager = AdManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let storeURL = Self.makePersistentStoreURL()
        let modelConfiguration = ModelConfiguration(
            nil,
            schema: schema,
            url: storeURL,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    adManager.requestTrackingPermission()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private static func makePersistentStoreURL() -> URL {
        let fileManager = FileManager.default
        guard let applicationSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Failed to resolve application support directory.")
        }

        let bundleID = Bundle.main.bundleIdentifier ?? "EnglishGeneralKnowledge"
        let modelDirectory = applicationSupportURL.appendingPathComponent(bundleID, isDirectory: true)

        do {
            try fileManager.createDirectory(at: modelDirectory, withIntermediateDirectories: true)
        } catch {
            fatalError("Failed to pre-create SwiftData directory: \(error)")
        }

        return modelDirectory.appendingPathComponent("default.store")
    }
}

@MainActor
final class AdManager: ObservableObject {
    @Published private var hasRequestedPermission = false

    func requestTrackingPermission() {
        guard !hasRequestedPermission else { return }
        hasRequestedPermission = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        MobileAds.shared.start { _ in }
                    }
                }
            } else {
                MobileAds.shared.start { _ in }
            }
        }
    }
}
