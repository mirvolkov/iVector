import SwiftUI
import Components
import Features

struct ControlPanel: View {
    @StateObject var viewModel = ConnectionViewModel(AppState.instance.connection, settings: AppState.instance.settings)
    
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

            Button {
                viewModel.dock()
            } label: {
                Text("dock")
            }.disabled(!viewModel.isConnected)
            
            Button {
                viewModel.sayTest()
            } label: {
                Text("say")
            }.disabled(!viewModel.isConnected)
            
            Button {
                viewModel.wavTest()
            } label: {
                Text("play WAV")
            }.disabled(!viewModel.isConnected)
        }
    }
}
