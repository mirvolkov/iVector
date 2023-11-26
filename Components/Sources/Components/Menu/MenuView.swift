import Features
import Programmator
import SwiftUI

public struct MenuView: View {
    @ObservedObject private var viewModel: ViewModel
    @EnvironmentObject private var errorHandling: ErrorHandlerViewModel
    @State private var loadProgramPopover = false

    public init(with connection: ConnectionModel, executor: ExecutorModel) {
        self._viewModel = .init(initialValue: .init(with: connection, executor: executor))
    }

    public var body: some View {
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
