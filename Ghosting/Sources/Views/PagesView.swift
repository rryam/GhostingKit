import SwiftUI
import GhostingKit

struct PagesView: View {
  var ghostingKit: GhostingKit
  @State private var pages: [GhostContent] = []
  @State private var isLoading = false
  @State private var error: Error?

  var body: some View {
    NavigationView {
      List(pages, id: \.id) { page in
        NavigationLink(destination: PageDetailView(page: page)) {
          HStack(alignment: .top, spacing: 12) {
            if let featureImage = page.featureImage {
              AsyncImage(url: URL(string: featureImage)) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
              } placeholder: {
                Rectangle()
                  .fill(Color.gray.opacity(0.2))
              }
              .frame(width: 60, height: 60)
              .clipped()
              .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
              Text(page.title)
                .font(.headline)
                .lineLimit(2)
              
              if let excerpt = page.excerpt {
                Text(excerpt)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .lineLimit(3)
              }
              
              HStack {
                if let publishedAt = page.publishedAt {
                  Text(publishedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                if page.featured {
                  Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                }
                
                if page.visibility != "public" {
                  Image(systemName: "eye.slash")
                    .foregroundColor(.orange)
                    .font(.caption)
                }
              }
            }
            
            Spacer()
          }
          .padding(.vertical, 4)
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
      pages = try await ghostingKit.getPages().pages
    } catch {
      self.error = error
    }
  }
}
