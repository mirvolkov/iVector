import Foundation

class Settings: ObservableObject {
    @Published var ip: String = .init()

    func setIP(_ ip: String) {
        self.ip = ip
    }
}
