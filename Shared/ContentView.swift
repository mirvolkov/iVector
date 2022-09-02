import Connection
import GRPC
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ConnectionViewModel = .init(AppState.instance.connection)
    @State var preferences = false

    var body: some View {
        VStack {
            Button {
                if viewModel.isConnected {
                    viewModel.disconnect()
                } else {
                    viewModel.connect()
                }
            } label: {
                if viewModel.isLoading {
                    Text("Connecting...")
                } else if viewModel.isConnected {
                    Text("Disconnect")
                    if let battery = viewModel.battery {
                        Text("\(battery.description)")
                    }
                } else {
                    Text("Connect")
                }
            }.disabled(viewModel.isLoading)

            Spacer().frame(height: 20)

            Button {
                preferences = true
#if os(macOS)
                NSWorkspace.shared.open(.init(string: "ivector://SettingsView")!)
#endif
            } label: {
                Image(systemName: "gear")
                    .resizable()
                    .foregroundColor(.green)
                    .frame(width: 40, height: 40)
            }.buttonStyle(.plain)
        }
#if os(iOS)
        .sheet(isPresented: $preferences) {
            SettingsView()
        }
#endif
#if os(macOS)
.frame(width: 320, height: 480)
#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
