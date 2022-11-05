import SwiftUI

class ErrorHandlerViewModel: ObservableObject {
    struct ErrorAlert: Identifiable {
        var id = UUID()
        var message: String
        var dismissAction: (() -> Void)?
    }
    
    @Published var error: ErrorAlert?
    
    func handle(error: Error) {
        self.error = ErrorAlert(message: error.localizedDescription)
    }
    
    func handle(error: ErrorAlert) {
        self.error = error
    }
}
