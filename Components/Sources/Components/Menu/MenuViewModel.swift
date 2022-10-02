import SwiftUI
import Connection
import Features

final class MenuViewModel: ObservableObject {
    @Published var memory: Bool = false
    @Published var batt: String = ""
    @Published var prog: String? = nil
    
    private let connection: ConnectionModel
    
    init(with connection: ConnectionModel) {
        self.connection = connection
    }
    
    func bind() {
        
    }
    
    func onProgTap() {
        
    }

    func onCancelTap() {
        
    }
}
