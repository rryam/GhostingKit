import SwiftUI
import PhantomKit

struct PostsView: View {
  var phantomKit: PhantomKit
  @State private var posts: [GhostContent] = []
  @State private var isLoading = false
  @State private var error: Error?

  var body: some View {
    NavigationView {
      List(posts, id: \.id) { post in
        VStack(alignment: .leading, spacing: 8) {
          Text(post.title)
            .font(.headline)
          Text(post.excerpt ?? "")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
      }
      .navigationTitle("Posts")
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
      await fetchPosts()
    }
  }

  private func fetchPosts() async {
    isLoading = true
    defer { isLoading = false }

    do {
      posts = try await phantomKit.getPosts().posts
    } catch {
      self.error = error
    }
  }
}
