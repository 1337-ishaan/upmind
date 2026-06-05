import SwiftUI

struct RootView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Upmind")
                .font(.largeTitle)
                .bold()
            Text("Foundation ready. Engine next.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    RootView()
}
