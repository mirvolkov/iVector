import Components
import ComposableArchitecture
import Connection
import Features
import Programmator
import SwiftUI

struct DetailPanel: View {
    @EnvironmentObject private var store: StoreOf<AppFeature>
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        WithViewStore(store, observe: { $0.connection }) { connectionViewStore in
            WithViewStore(store, observe: { $0.camera }) { visionViewStore in
                switch (connectionViewStore.state, visionViewStore.state) {
                case (_, .online), (_, .connecting):
                    display
                        .overlay(alignment: .trailing) {
                            headControl
                        }.overlay(alignment: .top) {
                            menu
                        }.overlay(alignment: .topLeading) {
                            telemetryView
                        }.overlay(alignment: .center) {
                            AimView()
                        }.overlay {
                            FacetView()
                        }

                default:
                    VisionOfflineView()
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }

    @ViewBuilder
    private var menu: some View {
        WithViewStore(store, observe: { $0.connection }) { viewStore in
            switch viewStore.state {
            case .online(let executor):
                MenuView(with: env.connection, executor: executor)
                    .frame(height: 80)
                    .padding(.top, 80)
            default:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var headControl: some View {
        WithViewStore(store, observe: { $0.connection }) { viewStore in
            switch viewStore.state {
            case .online:
                HeadControlView(with: env.connection)
                    .frame(width: 80)
                    .padding(.trailing, 10)
                    .padding(.top, 80)
            default:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var telemetryView: some View {
        WithViewStore(store, observe: { $0.connection }) { viewStore in
            switch viewStore.state {
            case .online:
                TelemetryView(with: env.connection)
                    .frame(width: 100)
                    .padding(.leading, 20)
                    .padding(.top, 140)
            default:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var display: some View {
        WithViewStore(store, observe: { $0.camera }) { viewStore in
            switch viewStore.state {
            case .online(let visionModel):
                VisionView(vision: visionModel)

            case .connecting, .offline:
                Color.black
            }
        }
    }
}
