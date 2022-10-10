import Components
import ComposableArchitecture
import Connection
import Features
import SwiftUI

struct DetailPanel: View {
    let store = AppState.store

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.state {
            case .online(let vision, let executor):
                VisionView(
                    connection: AppState.env.connection,
                    vision: vision,
                    executor: executor
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .offline:
                VisionOfflineView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
