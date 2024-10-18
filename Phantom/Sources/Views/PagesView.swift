import SwiftUI
import PhantomKit

struct PagesView: View {
  var phantomKit: PhantomKit
  @State private var pages: [GhostContent] = []
  @State private var isLoading = false
  @State private var error: Error?

  var body: some View {
    NavigationView {
      List(pages, id: \.id) { page in
        VStack(alignment: .leading, spacing: 8) {
          Text(page.title)
            .font(.headline)
          Text(page.excerpt ?? "")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
      }
      .navigationTitle("Pages")
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
      await fetchPages()
    }
  }

  private func fetchPages() async {
    isLoading = true
    defer { isLoading = false }

    do {
      pages = try await phantomKit.getPages().pages
    } catch {
      self.error = error
    }
  }
}
