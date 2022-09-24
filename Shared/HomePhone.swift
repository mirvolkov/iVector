import Components
import ComposableArchitecture
import SwiftUI
#if os(iOS)
import UIKit

struct HomePhone: View {
    @State private var preferences = false
    private let viewStore: ViewStore<VectorAppState, VectorAppAction> = ViewStore(AppState.store)

    var body: some View {
        TabView {
            NavigationStack {
                ControlPanelsView(
                    connection: AppState.env.connection,
                    settings: .init(),
                    onConnect: {
                        viewStore.send(.connect(.init()))
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
            }.tabItem {
                Label(L10n.control, systemImage: "keyboard.fill")
            }

            NavigationStack {
                DetailPanel()
                    .frame(height: 420)
                    .clipped()
                    .navigationTitle(L10n.camera)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label(L10n.camera, systemImage: "camera.fill")
            }
        }
        .tableStyle(.inset)
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
