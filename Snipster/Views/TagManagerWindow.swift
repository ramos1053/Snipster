//
//  TagManagerWindow.swift
//  Snipster
//
//  Created by Alan Ramos on 12/17/25.
//

import SwiftUI

struct TagManagerWindow: View {
    @EnvironmentObject var tagStore: TagStore
    @EnvironmentObject var viewModel: SnippetViewModel

    @State private var editingTag: Tag?
    @State private var showingAddTag = false
    @State private var tagToDelete: Tag?
    @State private var showingDeleteConfirmation = false
    @State private var searchText = ""

    private func closeWindow() {
        if let window = NSApplication.shared.keyWindow {
            window.close()
        }
    }

    var filteredTags: [Tag] {
        if searchText.isEmpty {
            return tagStore.tags.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
        return tagStore.tags.filter { tag in
            tag.name.lowercased().contains(searchText.lowercased())
        }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Tag Manager")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("Done") {
                    closeWindow()
                }
                .keyboardShortcut(.return)
            }
            .padding()

            Divider()

            // Search and Add
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search tags...", text: $searchText)
                    .textFieldStyle(.plain)

                Spacer()

                Button(action: { showingAddTag = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("New Tag")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            // Tag List
            if filteredTags.isEmpty {
                VStack {
                    Spacer()
                    if searchText.isEmpty {
                        Image(systemName: "tag.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No tags yet")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("Create your first tag to get started")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No tags found")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("Try a different search term")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredTags) { tag in
                            TagManagerRow(
                                tag: tag,
                                snippets: snippetsUsing(tag),
                                onEdit: { editingTag = tag },
                                onDelete: {
                                    tagToDelete = tag
                                    showingDeleteConfirmation = true
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(width: 600, height: 500)
        .sheet(item: $editingTag) { tag in
            TagEditView(tag: tag, onSave: { updatedTag in
                Task {
                    await tagStore.updateTag(updatedTag)
                }
            })
        }
        .sheet(isPresented: $showingAddTag) {
            TagEditView(tag: nil, onSave: { newTag in
                Task {
                    await tagStore.addTag(newTag)
                }
            })
        }
        .alert("Delete Tag", isPresented: $showingDeleteConfirmation, presenting: tagToDelete) { tag in
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await tagStore.deleteTag(tag)
                }
            }
        } message: { tag in
            let count = snippetsUsing(tag).count
            if count > 0 {
                Text("This tag is used by \(count) snippet\(count == 1 ? "" : "s"). Deleting it will remove the tag from all snippets.")
            } else {
                Text("Are you sure you want to delete this tag?")
            }
        }
    }

    private func snippetsUsing(_ tag: Tag) -> [Snippet] {
        viewModel.snippetStore.snippets.filter { $0.tagIDs.contains(tag.id) }
    }
}

struct TagManagerRow: View {
    let tag: Tag
    let snippets: [Snippet]
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Color preview circle
                Circle()
                    .fill(tag.color)
                    .frame(width: 20, height: 20)

                Text(tag.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                // Snippet count badge
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.caption)
                    Text("\(snippets.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(tag.color)
                .cornerRadius(12)

                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.caption)
                }
                .buttonStyle(.bordered)

                Button(action: onDelete) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
                .buttonStyle(.bordered)
            }

            // Snippets using this tag
            if !snippets.isEmpty {
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(snippets) { snippet in
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .font(.caption2)
                                    .foregroundColor(tag.color)
                                Text(snippet.title)
                                    .font(.body)
                                Spacer()
                                Text(snippet.modifiedAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.secondary.opacity(0.05))
                            .cornerRadius(6)
                        }
                    }
                    .padding(.top, 4)
                } label: {
                    HStack {
                        Image(systemName: snippets.isEmpty ? "doc.text" : "doc.on.doc")
                            .foregroundColor(.secondary)
                        Text("Used in \(snippets.count) snippet\(snippets.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading, 28)
            } else {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.secondary)
                    Text("Not used in any snippets")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 28)
            }
        }
        .padding()
        .background(tag.color.opacity(0.08))
        .cornerRadius(12)
    }
}

#Preview {
    TagManagerWindow()
        .environmentObject(TagStore(storageManager: FileStorageManager()))
        .environmentObject(SnippetViewModel())
}
