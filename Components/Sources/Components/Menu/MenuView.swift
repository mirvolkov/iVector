import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: MenuViewModel

    @EnvironmentObject private var errorHandling: ErrorHandlerViewModel
    @State private var loadProgramPopover = false

    var body: some View {
        HStack {
            Text("AI")
                .font(vectorBold(22))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .background {
                    viewModel.isAIRunning ? Color.blue : Color.clear
                }
                .onTapGesture {
                    viewModel.onAITap()
                }

            Text("\(viewModel.prog?.uppercased() ?? "PROG")")
                .font(vectorBold(22))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .background {
                    viewModel.isProgRunning ? Color.blue : Color.clear
                }
                .onTapGesture {
                    if viewModel.isProgRunning {
                        viewModel.onCancelTap()
                    } else {
                        loadProgramPopover = true
                        viewModel.onProgTap()
                    }
                }
        }
        .onAppear {
            viewModel.execError = errorHandling
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
