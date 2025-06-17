import SwiftUI
import GhostingKit

struct PageDetailView: View {
    let page: GhostPage
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let featureImage = page.featureImage {
                    AsyncImage(url: URL(string: featureImage)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                ProgressView()
                            )
                    }
                    .frame(maxHeight: 300)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(page.title)
                        .font(.largeTitle)
                        .bold()
                    
                    HStack {
                        if let publishedAt = page.publishedAt {
                            Label(publishedAt.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let readingTime = page.readingTime {
                            Label("\(readingTime) min read", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    if let excerpt = page.excerpt {
                        Text(excerpt)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                    
                    if let html = page.html {
                        HTMLView(html: html)
                            .frame(minHeight: 200)
                    }
                    
                    if let authors = page.authors, !authors.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Authors")
                                .font(.headline)
                            
                            ForEach(authors, id: \.id) { author in
                                HStack {
                                    if let profileImage = author.profileImage {
                                        AsyncImage(url: URL(string: profileImage)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Circle()
                                                .fill(Color.gray.opacity(0.2))
                                        }
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(author.name)
                                            .font(.subheadline)
                                            .bold()
                                        if let bio = author.bio {
                                            Text(bio)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    if let tags = page.tags, !tags.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(tags, id: \.id) { tag in
                                        Text(tag.name)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    
                    // Page-specific information
                    if page.visibility != "public" {
                        HStack {
                            Image(systemName: "eye.slash")
                            Text("Visibility: \(page.visibility.capitalized)")
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.top)
                    }
                    
                    if page.featured {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Featured Page")
                        }
                        .font(.caption)
                        .foregroundColor(.yellow)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        PageDetailView(
            page: GhostPage(
                slug: "about",
                id: "1",
                uuid: "uuid",
                title: "About Us",
                html: "<p>This is the about page with <strong>HTML</strong> content.</p>",
                commentId: nil,
                featureImage: nil,
                featureImageAlt: nil,
                featureImageCaption: nil,
                featured: false,
                visibility: "public",
                createdAt: Date(),
                updatedAt: Date(),
                publishedAt: Date(),
                customExcerpt: nil,
                codeinjectionHead: nil,
                codeinjectionFoot: nil,
                customTemplate: nil,
                canonicalUrl: nil,
                url: "https://demo.ghost.io/about",
                excerpt: "Learn more about our company and mission",
                readingTime: 2,
                access: true,
                ogImage: nil,
                ogTitle: nil,
                ogDescription: nil,
                twitterImage: nil,
                twitterTitle: nil,
                twitterDescription: nil,
                metaTitle: nil,
                metaDescription: nil,
                emailSubject: nil,
                tags: [
                    GhostTag(id: "1", name: "About", slug: "about")
                ],
                authors: [
                    GhostAuthor(
                        id: "1",
                        name: "Team",
                        slug: "team",
                        bio: "Our amazing team",
                        profileImage: nil
                    )
                ]
            )
        )
    }
}