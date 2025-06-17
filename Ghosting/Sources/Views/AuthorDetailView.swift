import SwiftUI
import GhostingKit

struct AuthorDetailView: View {
    let author: GhostAuthor
    let ghostingKit: GhostingKit
    
    @State private var authorPosts: [GhostPost] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Author Profile Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
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
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(author.name)
                                .font(.largeTitle)
                                .bold()
                            
                            if let bio = author.bio {
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let website = author.website {
                                Link(destination: URL(string: website) ?? URL(string: "https://example.com")!) {
                                    HStack {
                                        Image(systemName: "link")
                                        Text("Website")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    if let location = author.location {
                        HStack {
                            Image(systemName: "location")
                            Text(location)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Posts Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Posts by \(author.name)")
                        .font(.headline)
                    
                    if isLoading {
                        ProgressView("Loading posts...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let errorMessage = errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundColor(.orange)
                            Text("Error loading posts")
                                .font(.headline)
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Retry") {
                                loadAuthorPosts()
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                    } else if authorPosts.isEmpty {
                        Text("No posts found")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(authorPosts, id: \.id) { post in
                                NavigationLink(destination: PostDetailView(post: post)) {
                                    PostCardView(post: post)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(author.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadAuthorPosts()
        }
    }
    
    private func loadAuthorPosts() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await ghostingKit.getPosts(
                    limit: 50,
                    filter: "author:\(author.slug)",
                    include: "authors,tags"
                )
                await MainActor.run {
                    authorPosts = response.posts
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

struct PostCardView: View {
    let post: GhostPost
    
    var body: some View {
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
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
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
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    NavigationView {
        AuthorDetailView(
            author: GhostAuthor(
                id: "1",
                name: "John Doe",
                slug: "john-doe",
                bio: "A passionate developer and writer",
                profileImage: nil,
                website: "https://johndoe.com",
                location: "San Francisco, CA"
            ),
            ghostingKit: try! GhostingKit(
                adminDomain: "demo.ghost.io",
                apiKey: "demo-api-key"
            )
        )
    }
}