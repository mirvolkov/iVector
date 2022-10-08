import SwiftUI

extension View {
    func errorAlert<T: LocalizedError>(error: Binding<T?>, buttonTitle: String = L10n.ok) -> some View {
        return alert(isPresented: .constant(error.wrappedValue != nil), error: error.wrappedValue) {
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        }
    }
}
