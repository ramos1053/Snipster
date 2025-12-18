//
//  TagManagementView.swift
//  Snipster
//
//  Created by Alan Ramos on 12/17/25.
//

import SwiftUI

struct TagManagementView: View {
    @EnvironmentObject var tagStore: TagStore
    @EnvironmentObject var viewModel: SnippetViewModel

    @State private var editingTag: Tag?
    @State private var showingAddTag = false
    @State private var tagToDelete: Tag?
    @State private var showingDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if tagStore.tags.isEmpty {
                Text("No tags yet. Create your first tag to get started.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(tagStore.tags) { tag in
                            TagManagementRow(
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
                }
                .frame(maxHeight: 300)
            }

            Button(action: { showingAddTag = true }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add New Tag")
                }
                .font(.caption)
            }
        }
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

struct TagManagementRow: View {
    let tag: Tag
    let snippets: [Snippet]
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Color preview circle
                Circle()
                    .fill(tag.color)
                    .frame(width: 16, height: 16)

                Text(tag.name)
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()

                // Snippet count badge
                Text("\(snippets.count)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(tag.color)
                    .cornerRadius(10)

                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }

            // Disclosure group for snippets using this tag
            if !snippets.isEmpty {
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(snippets) { snippet in
                            HStack {
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text(snippet.title)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.leading, 8)
                        }
                    }
                    .padding(.vertical, 4)
                } label: {
                    Text("Used in \(snippets.count) snippet\(snippets.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Not used in any snippets")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 20)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(tag.color.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    TagManagementView()
        .environmentObject(TagStore(storageManager: FileStorageManager()))
        .environmentObject(SnippetViewModel())
        .padding()
}
