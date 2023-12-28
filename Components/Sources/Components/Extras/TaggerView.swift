import Connection
import Features
import SwiftUI
import Connection
import SocketIO

public struct TaggerView: View {
    public class ViewModel: ObservableObject {
        public struct Tag: AppHub.SocketMessage {
            let tag: String
            let date: Date = .init()
        }

        let socket: AppHub
        
        init(socket: AppHub) {
            self.socket = socket
        }
        
        func insert(tag: String) throws {
            socket.send(Tag(tag: tag), with: "tag")
        }
    }

    private let viewModel: ViewModel
    
    public init(connection: ConnectionModel) {
        self.viewModel = .init(socket: connection.hub)
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
