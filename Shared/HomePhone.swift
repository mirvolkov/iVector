import Components
import ComposableArchitecture
import SwiftUI
#if os(iOS)
import UIKit

struct HomePhone: View {
    @State private var preferences = false
    @State private var recorder = false
    @EnvironmentObject private var store: StoreOf<VectorFeature>
    @EnvironmentObject private var env: VectorAppEnvironment
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                            toolbar
                            Button {
                                recorder = true
                            } label: {
                                Image(systemName: "gyroscope")
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
            .sheet(isPresented: $recorder) {
//                MotionRecView()
//                    .environmentObject(env)
//                    .environmentObject(store)
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

    @ViewBuilder
    private var toolbar: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            socketButton(online: viewStore.socket == .online) {
                viewStore.send(.socketConnect)
            }
            settingsButton {
                preferences = true
            }
        }
    }
}
#endif
