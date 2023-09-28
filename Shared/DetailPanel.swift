import Components
import ComposableArchitecture
import Connection
import Features
import SwiftUI

struct DetailPanel: View {
    @EnvironmentObject private var store: StoreOf<AppFeature>
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.state.connection {
            case .online:
                VisionView(connection: env.connection)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)

            case .offline, .connecting:
                VisionOfflineView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
