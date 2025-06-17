import SwiftUI
import GhostingKit

struct AuthorsView: View {
  var ghostingKit: GhostingKit
  @State private var authors: [GhostAuthor] = []
  @State private var isLoading = false
  @State private var error: Error?

  var body: some View {
    NavigationView {
      List(authors, id: \.id) { author in
        NavigationLink(destination: AuthorDetailView(author: author, ghostingKit: ghostingKit)) {
          HStack {
            if let profileImage = author.profileImage {
              AsyncImage(url: URL(string: profileImage)) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
              } placeholder: {
                Circle()
                  .fill(Color.gray.opacity(0.2))
                  .overlay(
                    Image(systemName: "person.fill")
                      .foregroundColor(.gray)
                  )
              }
              .frame(width: 50, height: 50)
              .clipShape(Circle())
            } else {
              Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                  Image(systemName: "person.fill")
                    .foregroundColor(.gray)
                )
            }
            
            VStack(alignment: .leading, spacing: 4) {
              Text(author.name)
                .font(.headline)
              if let bio = author.bio {
                Text(bio)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .lineLimit(2)
              }
            }
            
            Spacer()
          }
          .padding(.vertical, 4)
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
      authors = try await ghostingKit.getAuthors().authors
    } catch {
      self.error = error
    }
  }
}
