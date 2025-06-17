import SwiftUI
import GhostingKit

struct PostsView: View {
  var ghostingKit: GhostingKit
  @State private var posts: [GhostContent] = []
  @State private var isLoading = false
  @State private var error: Error?

  var body: some View {
    NavigationView {
      List(posts, id: \.id) { post in
        NavigationLink(destination: PostDetailView(post: post)) {
          HStack(alignment: .top, spacing: 12) {
            if let featureImage = post.featureImage {
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
              Text(post.title)
                .font(.headline)
                .lineLimit(2)
              
              if let excerpt = post.excerpt {
                Text(excerpt)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .lineLimit(3)
              }
              
              HStack {
                if let publishedAt = post.publishedAt {
                  Text(publishedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                if let readingTime = post.readingTime {
                  Text("• \(readingTime) min read")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                if post.featured {
                  Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                }
              }
            }
            
            Spacer()
          }
          .padding(.vertical, 4)
        }
      }
      .navigationTitle("Posts")
      .overlay(Group {
        if isLoading {
          ProgressView()
        } else {
            EmptyView()
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
      posts = try await ghostingKit.getPosts().posts
    } catch {
      self.error = error
    }
  }
}
