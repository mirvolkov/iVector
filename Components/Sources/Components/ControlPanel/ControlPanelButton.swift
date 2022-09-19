import SwiftUI

typealias ControlPanelButtonViewModel = CPButtonViewModel
    & CPViewModelBindable
    & CPViewModelClickable

struct ControlPanelButtonView<ViewModel: ControlPanelButtonViewModel>: View {
    @StateObject var viewModel: ViewModel
    @State var isHighligted: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            if let secondaryTitle = viewModel.secondaryTitle {
                Text(secondaryTitle)
                    .font(regular(12))
                    .foregroundColor(viewModel.enabled ? .black : .gray)
            } else {
                Spacer()
            }

            if let image = viewModel.primaryIcon {
                image
                    .resizable()
                    .fixedSize()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(viewModel.enabled ? viewModel.tintColor : .gray)
            }

            if let primaryTitle = viewModel.primaryTitle {
                Text(primaryTitle)
                    .font(regular(18))
                    .foregroundColor(viewModel.enabled ? .black : .gray)
            } else {
                Spacer()
            }
        }
        .background(.background)
        .cornerRadius(3)
        .shadow(color: .gray, radius: isHighligted ? 0 : 2, x: 1, y: 1)
        .onAppear {
            viewModel.bind()
        }
        .onDisappear {
            viewModel.unbind()
        }
        .onTapGesture(perform: {
            viewModel.onClick()
        })
        .onChange(of: viewModel.enabled, perform: { newValue in
            print("enabled: \(newValue)")
        })
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard viewModel.enabled else { return }
                    isHighligted = true
                }
                .onEnded { _ in
                    guard viewModel.enabled else { return }
                    isHighligted = false
                }
        )
    }
}
