import SwiftUI

struct ErrorHandler: ViewModifier {
    @StateObject var errorHandling = ErrorHandlerViewModel()

    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandling)
            .background(
                EmptyView()
                    .alert(item: $errorHandling.error) { currentAlert in
                        Alert(
                            title: Text(L10n.error),
                            message: Text(currentAlert.message),
                            dismissButton: .default(Text(L10n.ok)) {
                                currentAlert.dismissAction?()
                            }
                        )
                    }
            )
    }
}

public extension View {
    func withErrorHandler() -> some View {
        modifier(ErrorHandler())
    }
}
