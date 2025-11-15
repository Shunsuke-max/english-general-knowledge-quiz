//
//  EnglishGeneralKnowledgeApp.swift
//  EnglishGeneralKnowledge
//
//  Created by あさいしゅんすけ on 2025/11/14.
//

import SwiftUI
import SwiftData

@main
struct EnglishGeneralKnowledgeApp: App {
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
