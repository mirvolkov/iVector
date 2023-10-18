import Components
import ComposableArchitecture
import Connection
import Features
import Programmator
import SwiftUI

struct DetailPanel: View {
    @EnvironmentObject private var store: StoreOf<AppFeature>
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        WithViewStore(store, observe: { $0.camera }) { cameraViewStore in
            WithViewStore(store, observe: { $0.connection }) { connectionViewStore in
                switch (cameraViewStore.state, connectionViewStore.state) {
                case (.online(let vision), .online(let executor)):
                    VisionView(connection: env.connection, vision: vision, executor: executor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)

                default:
                    VisionOfflineView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
