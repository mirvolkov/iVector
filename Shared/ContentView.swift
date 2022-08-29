import SwiftUI
import Connection
import GRPC

class ViewModel: ObservableObject {
    let connection = VectorConnection(with: "192.168.0.105", port: 443)
    var client: ClientConnection!
    var control: ControlRequestStream!
    
//    var control: Connection.
    func start() {
        do {
            control = try connection.control()
            try connection.requestControl(stream: control)
        } catch {
            print(error)
        }
    }
}

//struct ContentView: View {
//    @StateObject var viewModel = VectorConnection()
//    @MainActor @State var isLoading = false
//
//    var body: some View {
//        Button {
//            Task {
//                isLoading = true
//                let connection = try viewModel.open()
//                viewModel.requestControl(with: connection)
////                defer { connection.close() }
////                guard try await viewModel.initSdk(with: connection) else { return }
//                Task {
//                    /***
//                     // We can't read more than one message on a unary stream.
//                     */
//
////                        try viewModel.requestControl(with: connection)
//                    //        Task {
//                    while true {
//                        var controlRequest = Anki_Vector_ExternalInterface_BehaviorControlRequest()
////                        controlRequest.priority = .reserveControl
//                        controlRequest.controlRequest = Anki_Vector_ExternalInterface_ControlRequest()
//                        controlRequest.controlRequest.priority = .default
//                        let _ = viewModel.controlRequestCall.sendMessage(controlRequest)
////                        viewModel.controlRequestCall.response.whenSuccess { result in
////                            print("REQUEST CONTROL STATUS \(result)")
////                        }
//
//                        try await Task.sleep(nanoseconds: 1_000_000_000)
//                    }
//                    //        }
//                }
////                await viewModel.setEyeColor(with: connection)
//                isLoading = false
//            }
//        } label: {
//            if isLoading {
//                Text("Connecting...").disabled(true)
//            } else {
//                Text("Connect")
//            }
//        }
//    }
//}

struct ContentView: View {
    @StateObject var viewModel: ViewModel = .init()
    
    var body: some View {
        Button {
            viewModel.start()
        } label: {
            Text("Connect")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
