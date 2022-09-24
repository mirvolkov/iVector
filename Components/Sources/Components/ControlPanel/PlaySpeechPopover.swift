import SwiftUI

struct PlaySpeechPopover: View {
    @State private var text: String = ""
    @ObservedObject var viewModel: ButtonTTSViewModel

    var body: some View {
        VStack(spacing: 22) {
            Text(L10n.typeInMessageToSay)
                .font(vectorRegular(32))
            TextField(L10n.say, text: $text)
                .font(vectorRegular(18))
            Button(L10n.say, role: .destructive, action: {
                viewModel.say(text)
            })
            .disabled(text.isEmpty)
        }.padding(44)
    }
}
