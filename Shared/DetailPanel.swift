import Components
import ComposableArchitecture
import Connection
import Features
import SwiftUI

struct DetailPanel: View {
    @EnvironmentObject private var store: StoreOf<AppFeature>
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        WithViewStore(store, observe: { $0.camera }) { viewStore in
            switch viewStore.state {
            case .online(let vision):
                VisionView(connection: env.connection, vision: vision)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)

            case .offline, .connecting:
                VisionOfflineView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
