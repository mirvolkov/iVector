import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    @State private var loadProgramPopover = false

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
                batt
                    .resizable()
                    .frame(width: 32, height: 22)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
            }

            Text("\(viewModel.prog.uppercased())")
                .font(vectorBold(22))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .onTapGesture {
                    loadProgramPopover = true
                    viewModel.onProgTap()
                }

            if viewModel.isRunning {
                Button {
                    viewModel.onCancelTap()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            viewModel.bind()
        }
        .popover(isPresented: $loadProgramPopover, content: {
            PickListPopover(viewModel: viewModel) {
                loadProgramPopover = false
            }
        })
        .opacity(0.85)
    }
}
