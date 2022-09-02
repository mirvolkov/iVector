import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel = .init(AppState.instance.settings)
    
    var body: some View {
        VStack {
            TextField("Vector's IP address", text: $viewModel.ip)
            HEXColorInput(hexString: $viewModel.ip)
            Button {
                viewModel.save()
            } label: {
                Image(systemName: "checkmark.circle")
            }
        }
#if os(macOS)
        .padding(10)
.frame(width: 240, height: 240)
#endif
    }
}
