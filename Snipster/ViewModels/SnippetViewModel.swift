//
//  SnippetViewModel.swift
//  Snipster
//
//  Created by Alan Ramos on 12/16/25.
//

import SwiftUI
import Combine

@MainActor
class SnippetViewModel: ObservableObject {
    @Published var snippetStore: SnippetStore
    @Published var tagStore: TagStore
    @Published var searchText: String = ""
    @Published var selectedSnippet: Snippet?
    @Published var storageLocation: StorageLocation

    private let storageManager: FileStorageManager
    private var cancellables = Set<AnyCancellable>()

    var filteredSnippets: [Snippet] {
        snippetStore.searchSnippets(query: searchText)
    }

    var hasSnippets: Bool {
        !snippetStore.snippets.isEmpty
    }

    init(storageLocation: StorageLocation = .local) {
        self.storageLocation = storageLocation
        self.storageManager = FileStorageManager(location: storageLocation)
        self.snippetStore = SnippetStore(storageManager: storageManager)
        self.tagStore = TagStore(storageManager: storageManager)

        // Load tags and snippets on init
        Task {
            // Load tags first
            await tagStore.loadTags()

            // Load snippets
            await snippetStore.loadSnippets()

            // Run migration if needed
            let migrationService = TagMigrationService()
            let migratedSnippets = await migrationService.migrateSnippetsToTagIDs(
                snippets: snippetStore.snippets,
                tagStore: tagStore
            )

            // Save if migration occurred
            if migratedSnippets != snippetStore.snippets {
                snippetStore.snippets = migratedSnippets
                await snippetStore.saveSnippets()
                await tagStore.saveTags()
            }

            // Update text expansion monitor with loaded snippets
            TextExpansionMonitor.shared.updateSnippets(snippetStore.snippets)
        }

        // Start text expansion monitoring
        TextExpansionMonitor.shared.startMonitoring()

        // Observe snippet changes to update the monitor
        snippetStore.$snippets
            .sink { [weak self] snippets in
                TextExpansionMonitor.shared.updateSnippets(snippets)
            }
            .store(in: &cancellables)
    }

    func addSnippet(title: String, content: String, tags: [String] = [], tagIDs: [UUID] = [], triggerPrefix: String, triggerSequence: String, isFavorite: Bool = false) {
        let snippet = Snippet(title: title, content: content, tags: tags, tagIDs: tagIDs, triggerPrefix: triggerPrefix, triggerSequence: triggerSequence, isFavorite: isFavorite)
        Task {
            await snippetStore.addSnippet(snippet)
        }
    }

    func updateSnippet(_ snippet: Snippet) {
        Task {
            await snippetStore.updateSnippet(snippet)
        }
    }

    func deleteSnippet(_ snippet: Snippet) {
        Task { @MainActor in
            await snippetStore.deleteSnippet(snippet)
            objectWillChange.send()
        }
    }

    func selectSnippet(_ snippet: Snippet?) {
        selectedSnippet = snippet
    }

    func changeStorageLocation(_ location: StorageLocation) {
        storageLocation = location
        Task {
            await storageManager.updateStorageLocation(location)
            await tagStore.loadTags()
            await snippetStore.loadSnippets()
        }
    }
}
