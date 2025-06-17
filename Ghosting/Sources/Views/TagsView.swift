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
        NavigationLink(destination: TagDetailView(tag: tag, ghostingKit: ghostingKit)) {
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text(tag.name)
                .font(.headline)
              
              if let description = tag.description {
                Text(description)
                  .font(.caption)
                  .foregroundColor(.secondary)
                  .lineLimit(2)
              }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
              if let count = tag.count?.posts {
                Text("\(count) posts")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              
              if let accentColor = tag.accentColor {
                Circle()
                  .fill(Color(hex: accentColor) ?? .blue)
                  .frame(width: 12, height: 12)
              }
            }
          }
          .padding(.vertical, 4)
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
