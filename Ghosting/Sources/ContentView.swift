import SwiftUI
import GhostingKit

struct ContentView: View {
  @State private var ghostingKit: GhostingKit?
  @State private var errorMessage: String?
  
  var body: some View {
    if let ghostingKit = ghostingKit {
    TabView {
      PostsView(ghostingKit: ghostingKit)
        .tabItem {
          Label("Posts", systemImage: "doc.text")
        }
      TagsView(ghostingKit: ghostingKit)
        .tabItem {
          Label("Tags", systemImage: "tag")
        }
      PagesView(ghostingKit: ghostingKit)
        .tabItem {
          Label("Pages", systemImage: "book")
        }
      AuthorsView(ghostingKit: ghostingKit)
        .tabItem {
          Label("Authors", systemImage: "person.2")
        }
    }
    } else if let errorMessage = errorMessage {
      VStack {
        Image(systemName: "exclamationmark.triangle")
          .font(.largeTitle)
          .foregroundColor(.red)
        Text("Error initializing GhostingKit")
          .font(.headline)
        Text(errorMessage)
          .font(.subheadline)
          .multilineTextAlignment(.center)
          .padding()
      }
      .padding()
    } else {
      ProgressView("Loading...")
        .task {
          do {
            // Try to load from Bundle first, fallback to demo configuration
            let configuration: GhostingKitConfiguration
            do {
              configuration = try GhostingKitConfiguration.fromBundle()
            } catch {
              // Fallback to demo configuration for development
              configuration = GhostingKitConfiguration(
                adminDomain: "demo.ghost.io",
                apiKey: "22444f78447824223cefc48062"
              )
            }
            
            ghostingKit = try await GhostingKit.create(configuration: configuration)
          } catch {
            errorMessage = error.localizedDescription
          }
        }
    }
  }
}

#Preview {
  ContentView()
}
