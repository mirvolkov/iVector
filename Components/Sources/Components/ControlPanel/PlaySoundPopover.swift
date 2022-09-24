import SwiftUI

struct PlaySoundPopover: View {
    @ObservedObject var viewModel: ButtonPlayViewModel
    
    var body: some View {
        List(viewModel.sounds, id: \.description) { sound in
            Text(sound.description)
                .font(vectorRegular(18))
                .onTapGesture {
                    viewModel.onSelect(sound)
                }
        }
    }
}
