import Components
import ComposableArchitecture
import SwiftUI
#if os(iOS)
import UIKit

struct HomeTablet: View {
    @State private var preferences = false
  
    var body: some View {
        NavigationSplitView {
            WithViewStore(AppState.store) { viewStore in
                ControlPanelsView(
                    connection: AppState.env.connection,
                    settings: AppState.env.settings,
                    assembler: AppState.env.assembler,
                    onConnect: {
                        viewStore.send(.connect(AppState.env.settings))
                    }, onDisconnect: {
                        viewStore.send(.disconnect)
                    })
                    .frame(width: 320)
                    .navigationTitle(L10n.controlPanel)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        Button {
                            preferences = true
                        } label: {
                            Image(systemName: "gear")
                                .foregroundColor(.init(UIColor.link))
                        }.buttonStyle(.plain)
                    }
            }
        } detail: {
            DetailPanel()
                .navigationTitle(L10n.camera)
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $preferences) {
            SettingsView(model: .init(), isPresented: $preferences)
        }
        .onAppear {
            if #available(iOS 15.0, *) {
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.backgroundColor = .systemBackground
                navigationBarAppearance.titleTextAttributes = [.font: FontFamily.RobotoMono.regular.font(size: 16) as CTFont]
                UINavigationBar.appearance().standardAppearance = navigationBarAppearance
                UINavigationBar.appearance().compactAppearance = navigationBarAppearance
                UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            }
        }
        .ignoresSafeArea()
    }
}
#endif
