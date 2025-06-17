import SwiftUI
import GhostingKit

struct TagDetailView: View {
    let tag: GhostTag
    let ghostingKit: GhostingKit
    
    @State private var tagPosts: [GhostPost] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Tag Header Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(tag.name)
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        if let count = tag.count {
                            Text("\(count.posts ?? 0) posts")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    
                    if let description = tag.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    if let accentColor = tag.accentColor {
                        HStack {
                            Circle()
                                .fill(Color(hex: accentColor) ?? .blue)
                                .frame(width: 12, height: 12)
                            Text("Tag Color")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Posts Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Posts tagged with \"\(tag.name)\"")
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
                                loadTagPosts()
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                    } else if tagPosts.isEmpty {
                        Text("No posts found with this tag")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(tagPosts, id: \.id) { post in
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
        .navigationTitle(tag.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadTagPosts()
        }
    }
    
    private func loadTagPosts() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await ghostingKit.getPosts(
                    limit: 50,
                    filter: "tag:\(tag.slug)",
                    include: "authors,tags"
                )
                await MainActor.run {
                    tagPosts = response.posts
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

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    NavigationView {
        TagDetailView(
            tag: GhostTag(
                id: "1",
                name: "Swift",
                slug: "swift",
                description: "Posts about Swift programming language",
                accentColor: "#007AFF",
                count: GhostTag.Count(posts: 42)
            ),
            ghostingKit: try! GhostingKit(
                adminDomain: "demo.ghost.io",
                apiKey: "demo-api-key"
            )
        )
    }
}