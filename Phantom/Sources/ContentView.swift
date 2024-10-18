import SwiftUI
import GhostingKit

struct ContentView: View {
  @ObserveInjection var inject
  let ghostingKit = GhostingKit(
    adminDomain: "demo.ghost.io",
    apiKey: "22444f78447824223cefc48062"
  )
  
  var body: some View {
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
    .enableInjection()
  }
}

struct ContentViewPreview: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
