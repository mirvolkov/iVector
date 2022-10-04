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

            if let batt = viewModel.batt {
                HStack(alignment: .center) {
                    Text("BATT:")
                        .font(vectorBold(22))

                    batt
                        .resizable()
                        .frame(width: 32, height: 22)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
            }

            Text("PROG: \(viewModel.prog ?? "")")
                .font(vectorBold(22))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .onTapGesture {
                    viewModel.loadProgramPopover = true
                }

            Button {
                viewModel.onCancelTap()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            viewModel.bind()
        }
        .sheet(isPresented: $viewModel.loadProgramPopover, content: {
            MenuLoadProgram(viewModel: viewModel)
        })
        .opacity(0.85)
    }
}
