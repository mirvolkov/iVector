import Components
import ComposableArchitecture
import Connection
import Features
import SwiftUI

struct DetailPanel: View {
    @StateObject var viewStore: ViewStore<VectorAppState, VectorAppAction> = ViewStore(AppState.store)

    var body: some View {
        WithViewStore(AppState.store) { viewStore in
            switch viewStore.state {
            case .online(let vision):
                VisionView(connection: AppState.env.connection, vision: vision)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .offline:
                VisionOfflineView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
