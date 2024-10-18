import SwiftUI
import GhostingKit

struct TagsView: View {
  var ghostingKit: GhostingKit
  @State private var tags: [GhostTag] = []
  @State private var isLoading = false
  @State private var error: Error?

  var body: some View {
    NavigationView {
      List(tags, id: \.id) { tag in
        HStack {
          Text(tag.name)
          Spacer()
          Text("\(tag.count)")
            .foregroundColor(.secondary)
        }
      }
      .navigationTitle("Tags")
      .overlay(Group {
        if isLoading {
          ProgressView()
        }
      })
      .alert(isPresented: Binding<Bool>(
        get: { error != nil },
        set: { _ in error = nil }
      )) {
        Alert(title: Text("Error"), message: Text(error?.localizedDescription ?? "Unknown error"))
      }
    }
    .task {
      await fetchTags()
    }
  }

  private func fetchTags() async {
    isLoading = true
    defer { isLoading = false }

    do {
      tags = try await ghostingKit.getTags().tags
    } catch {
      self.error = error
    }
  }
}
