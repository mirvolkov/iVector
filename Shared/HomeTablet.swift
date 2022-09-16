import Components
import SwiftUI
#if os(iOS)
import UIKit

struct HomeTablet: View {
    @State var preferences = false

    var body: some View {
        NavigationView {
            ControlPanelsView(connection: AppState.instance.connection, settings: AppState.instance.settings)
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

            DetailPanel()
                .navigationTitle(L10n.camera)
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $preferences) {
            SettingsView(model: AppState.instance.settings, isPresented: $preferences)
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
