import SwiftUI
import PhantomKit

struct ContentView: View {
  @ObserveInjection var inject
  let phantomKit = PhantomKit(
    adminDomain: "demo.ghost.io",
    apiKey: "22444f78447824223cefc48062"
  )
  
  var body: some View {
    TabView {
      PostsView(phantomKit: phantomKit)
        .tabItem {
          Label("Posts", systemImage: "doc.text")
        }
      TagsView(phantomKit: phantomKit)
        .tabItem {
          Label("Tags", systemImage: "tag")
        }
      PagesView(phantomKit: phantomKit)
        .tabItem {
          Label("Pages", systemImage: "book")
        }
      AuthorsView(phantomKit: phantomKit)
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
