import Components
import ComposableArchitecture
import Connection
import Features
import SwiftUI

struct DetailPanel: View {
    @EnvironmentObject private var store: VectorStore
    @EnvironmentObject private var env: VectorAppEnvironment

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.state {
            case .online(let vision, let executor):
                VisionView(
                    connection: env.connection,
                    vision: vision,
                    executor: executor
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)

            case .offline:
                VisionOfflineView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
