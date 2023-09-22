import Components
import ComposableArchitecture
import Connection
import Features
import SwiftUI

struct DetailPanel: View {
    @EnvironmentObject private var store: StoreOf<VectorFeature>
    @EnvironmentObject private var env: VectorAppEnvironment

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            switch viewStore.state.device {
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
