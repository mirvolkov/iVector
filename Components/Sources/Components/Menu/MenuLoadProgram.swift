import SwiftUI

struct MenuLoadProgram: View {
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        List(viewModel.programs, id: \.description) { sound in
            Text(sound.description)
                .font(vectorRegular(18))
                .onTapGesture {

                }
        }.frame(width: 320, height: 240)
    }
}
