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
        VStack(spacing: 22) {
            Text(title)
                .font(vectorRegular(32))
            TextField(placeholder, text: $text)
                .font(vectorRegular(18))
                .multilineTextAlignment(.center)
                .autocorrectionDisabled()
            Button(button, role: .destructive, action: {
                viewModel.onTextChange(text: text)
            })
            .disabled(text.isEmpty)
        }.padding(44)
    }
}
