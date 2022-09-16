import SwiftUI

struct ControlButtonView: View {
    @StateObject var viewModel: ControlButtonViewModel
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

extension ControlButtonView {
    class ControlButtonViewModel: ObservableObject {
        @Published var enabled: Bool = true
        @Published var primaryIcon: Image?
        @Published var primaryTitle: String?
        @Published var secondaryTitle: String?
        @Published var tintColor: Color = .green
    }
}
