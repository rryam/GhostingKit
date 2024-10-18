import SwiftUI
import PhantomKit

struct AuthorsView: View {
  var phantomKit: PhantomKit
  @State private var authors: [GhostAuthor] = []
  @State private var isLoading = false
  @State private var error: Error?

  var body: some View {
    NavigationView {
      List(authors, id: \.id) { author in
        VStack(alignment: .leading, spacing: 8) {
          Text(author.name)
            .font(.headline)
          Text(author.bio ?? "")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
      }
      .navigationTitle("Authors")
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
      await fetchAuthors()
    }
  }

  private func fetchAuthors() async {
    isLoading = true
    defer { isLoading = false }

    do {
      authors = try await phantomKit.getAuthors().authors
    } catch {
      self.error = error
    }
  }
}
