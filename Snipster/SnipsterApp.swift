//
//  SnipsterApp.swift
//  Snipster
//
//  Created by Alan Ramos on 12/16/25.
//

import SwiftUI

@main
struct SnipsterApp: App {
    @StateObject private var viewModel = SnippetViewModel()

    var body: some Scene {
        MenuBarExtra("Snipster", systemImage: "doc.on.clipboard") {
            MenuBarPopoverView()
                .environmentObject(viewModel)
                .environmentObject(viewModel.tagStore)
        }
        .menuBarExtraStyle(.window)
    }
}
