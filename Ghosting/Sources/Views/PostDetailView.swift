import SwiftUI
import GhostingKit

struct PostDetailView: View {
  let post: GhostPost
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        if let featureImage = post.featureImage {
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
          Text(post.title)
            .font(.largeTitle)
            .bold()
          
          HStack {
            if let publishedAt = post.publishedAt {
              Label(publishedAt.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            if let readingTime = post.readingTime {
              Label("\(readingTime) min read", systemImage: "clock")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          
          if let excerpt = post.excerpt {
            Text(excerpt)
              .font(.subheadline)
              .foregroundColor(.secondary)
              .padding(.vertical, 8)
          }
          
          if let html = post.html {
            HTMLView(html: html)
              .frame(minHeight: 200)
          }
          
          if let authors = post.authors, !authors.isEmpty {
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
          
          if let tags = post.tags, !tags.isEmpty {
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
        }
        .padding()
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct HTMLView: UIViewRepresentable {
  let html: String
  
  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.backgroundColor = .clear
    
    if let data = html.data(using: .utf8) {
      let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
      ]
      
      if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
        textView.attributedText = attributedString
      }
    }
    
    return textView
  }
  
  func updateUIView(_ uiView: UITextView, context: Context) {
    if let data = html.data(using: .utf8) {
      let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
      ]
      
      if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
        uiView.attributedText = attributedString
      }
    }
  }
}

#Preview {
  NavigationView {
    PostDetailView(
      post: GhostPost(
        id: "1",
        uuid: "uuid",
        title: "Sample Post",
        slug: "sample-post",
        html: "<p>This is a sample post content with <strong>HTML</strong> formatting.</p>",
        commentId: nil,
        excerpt: "This is a sample excerpt",
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
        url: "https://demo.ghost.io/sample-post",
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
        featureImage: nil,
        featureImageAlt: nil,
        featureImageCaption: nil,
        readingTime: 5,
        tags: [
          GhostTag(id: "1", name: "Swift", slug: "swift"),
          GhostTag(id: "2", name: "iOS", slug: "ios")
        ],
        authors: [
          GhostAuthor(
            id: "1",
            name: "John Doe",
            slug: "john-doe",
            bio: "A passionate developer",
            profileImage: nil
          )
        ]
      )
    )
  }
}