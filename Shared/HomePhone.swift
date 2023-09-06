import Components
import ComposableArchitecture
import SwiftUI
#if os(iOS)
import UIKit

struct HomePhone: View {
    @State private var preferences = false
    @EnvironmentObject private var store: VectorStore
    @EnvironmentObject private var env: VectorAppEnvironment
    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        WithViewStore(store) { viewStore in
            TabView {
                NavigationStack {
                    ControlPanelsView(
                        connection: env.connection,
                        settings: env.settings,
                        assembler: env.assembler,
                        onConnect: {
                            viewStore.send(.connect(env.settings))
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
                    ZStack {
                        DetailPanel()
                            .frame(height: horizontalSizeClass == .compact && verticalSizeClass == .regular ? 320 : nil)
                            .clipped()
                            .navigationTitle(L10n.camera)
                            .navigationBarTitleDisplayMode(.inline)
                            .edgesIgnoringSafeArea(horizontalSizeClass == .compact && verticalSizeClass == .regular ? .all : .horizontal)
                    }
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
}
#endif
