import SwiftUI

struct ReadingTimeView: View {
  let minutes: Int
  
  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "clock")
        .imageScale(.small)
      Text("\(minutes) min read")
        .font(.caption)
    }
    .foregroundColor(.secondary)
  }
}

// End of file. No additional code.
