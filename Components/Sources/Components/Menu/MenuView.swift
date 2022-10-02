import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: MenuViewModel

    var body: some View {
        HStack {
            Text("MEM")
                .font(vectorBold(22))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .background {
                    Color.blue
                }

            Text("BATT: \(viewModel.batt)")
                .font(vectorBold(22))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .background {
                    Color.black
                }

            Text("PROG: \(viewModel.prog ?? "")")
                .font(vectorBold(22))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .background {
                    Color.black
                }
                .onTapGesture {
                    viewModel.onProgTap()
                }

            Button {
                viewModel.onCancelTap()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .foregroundColor(.white)
            }
        }.opacity(0.85)
    }
}
