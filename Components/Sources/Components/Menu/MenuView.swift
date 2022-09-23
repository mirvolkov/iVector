import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        HStack {
            Text("MEM")
                .font(vectorBold(22))
                .foregroundColor(.white)
                .background {
                    Color.blue
                }
            Text("BATT: \(viewModel.batt)")
                .font(vectorBold(22))
                .foregroundColor(.white)
            
            Text("PROG: \(viewModel.prog ?? "")")
                .font(vectorBold(22))
                .foregroundColor(.white)
        }.opacity(0.85)
    }
}
