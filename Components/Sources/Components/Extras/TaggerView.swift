import Connection
import Features
import SwiftUI

public struct TaggerView: View {
    public class ViewModel: ObservableObject {
        let socket: SocketConnection
        
        init(socket: SocketConnection) {
            self.socket = socket
        }
        
        func insert(tag: String) throws {
            Task {
                try await socket.send(message: tag, with: "tag")
            }
        }
    }

    private let viewModel: ViewModel
    
    public init(connection: ConnectionModel) {
        self.viewModel = .init(socket: connection.socket)
    }
    
    public var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 20) {
                Button {
                    try? viewModel.insert(tag: "Col")
                } label: {
                    Text("C").frame(width: 120, height: 120, alignment: .center)
                }.buttonStyle(.bordered)
                
                Button {
                    try? viewModel.insert(tag: "Axel")
                } label: {
                    Text("A").frame(width: 120, height: 120, alignment: .center)
                }.buttonStyle(.bordered)
            }
            
            HStack(alignment: .center, spacing: 20) {
                Button {
                    try? viewModel.insert(tag: "Move")
                } label: {
                    Text("M").frame(width: 120, height: 120, alignment: .center)
                }.buttonStyle(.bordered)
                
                Button {
                    try? viewModel.insert(tag: "Stay")
                } label: {
                    Text("S").frame(width: 120, height: 120, alignment: .center)
                }.buttonStyle(.bordered)
            }
        }
    }
}
