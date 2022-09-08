import Connection
import GRPC
import SwiftUI
import Components

struct ContentView: View {
    @StateObject var viewModel: ConnectionViewModel = .init(AppState.instance.connection, settings: AppState.instance.settings)
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
            } label: {
                Image(systemName: "gear")
                    .resizable()
                    .foregroundColor(.green)
                    .frame(width: 40, height: 40)
            }.buttonStyle(.plain)
            
            Spacer().frame(height: 20)
            
            VisionView()
            
            HStack {
                Button {
                    viewModel.dock()
                } label: {
                    Text("go dock")
                }.disabled(!viewModel.isConnected)
                
                Button {
                    viewModel.undock()
                } label: {
                    Text("go undock")
                }.disabled(!viewModel.isConnected)
            }
        }
        .sheet(isPresented: $preferences) {
            SettingsView(isPresented: $preferences)
        }
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
