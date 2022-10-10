import SwiftUI

protocol TextFieldPopoverCallback: ObservableObject {
    func onTextChange(text: String)
}

struct TextFieldPopover<ViewModel: TextFieldPopoverCallback>: View {
    @State private var text: String = ""
    @State var title: String = ""
    @State var placeholder: String = ""
    @State var button: String = ""
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(vectorRegular(24))
                .multilineTextAlignment(.center)
                .frame(height: 90)
            TextField(placeholder, text: $text)
                .font(vectorRegular(18))
                .multilineTextAlignment(.center)
                .autocorrectionDisabled()
#if os(iOS)
                .textInputAutocapitalization(.never)
#endif
            Button(button, role: .destructive, action: {
                viewModel.onTextChange(text: text)
            })
            .buttonStyle(.automatic)
            .disabled(text.isEmpty)
        }.padding(24)
#if os(macOS)
        .frame(width: 320, height: 240)
#endif
    }
}
