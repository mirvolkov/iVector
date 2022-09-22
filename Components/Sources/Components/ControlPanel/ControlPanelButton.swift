import SwiftUI

typealias ControlPanelButtonViewModel = CPButtonViewModel
    & CPViewModelBindable
    & CPViewModelClickable

struct ControlPanelButtonView<ViewModel: ControlPanelButtonViewModel>: View {
    @StateObject var viewModel: ViewModel
    @State var isHighligted: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if let secondaryTitle = viewModel.secondaryTitle {
                Text(secondaryTitle)
                    .font(vectorRegular(12))
                    .foregroundColor(viewModel.enabled ? .black : .gray)
            } else {
                Spacer()
                    .frame(height: 14)
            }

            if let image = viewModel.primaryIcon {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .foregroundColor(viewModel.enabled ? viewModel.tintColor : .gray)
            }

            if let primaryTitle = viewModel.primaryTitle {
                Text(primaryTitle)
                    .font(vectorRegular(20))
                    .foregroundColor(viewModel.enabled ? .black : .gray)
            } else {
                Spacer()
                    .frame(height: 14)
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
