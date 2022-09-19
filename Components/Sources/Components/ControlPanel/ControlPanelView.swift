import Features
import SwiftUI

public struct ControlPanelsView: View {
    @State var size: CGFloat = 60
    @State var space: CGFloat = 8
    
    private let connection: ConnectionModel
    private let settings: SettingsModel
    
    public init(connection: ConnectionModel, settings: SettingsModel) {
        self.connection = connection
        self.settings = settings
    }

    public var body: some View {
        VStack {
            VStack(spacing: 10) {
                header
                Spacer()
                    .frame(height: 20)
                digitalPanel1
                digitalPanel2
                digitalPanel3
                digitalPanel4
                Spacer()
                    .frame(height: 20)
                behaviorPanel
            }
        }
        .padding(10)
    }
    
    private var header: some View {
        HStack(alignment: .center, spacing: space) {
            ControlPanelButtonView<ButtonPowerViewModel>(viewModel: .init(
                connection: connection,
                settings: settings
            ))
            .frame(width: size, height: size)
            
            ControlPanelButtonView<ButtonDockViewModel>(viewModel: .init(connection: connection))
                .frame(width: size, height: size)
            Spacer()
        }.frame(height: size)
    }
    
    private var digitalPanel1: some View {
        HStack(alignment: .center, spacing: space) {
            ControlPanelButtonView<Button1ViewModel>(viewModel: .init())
                .frame(width: size, height: size)
            
            ControlPanelButtonView<Button2ViewModel>(viewModel: .init())
                .frame(width: size, height: size)
            
            ControlPanelButtonView<Button3ViewModel>(viewModel: .init())
                .frame(width: size, height: size)
            
            Spacer()
                .frame(width: 30)
            
//                    ControlPanelButtonView(viewModel: .init())
//                        .frame(width: size, height: size)
            
            Spacer()
        }.frame(height: size)
    }
    
    private var digitalPanel2: some View {
        HStack(alignment: .center, spacing: space) {
            ControlPanelButtonView<Button4ViewModel>(viewModel: .init())
                .frame(width: size, height: size)
            
            ControlPanelButtonView<Button5ViewModel>(viewModel: .init())
                .frame(width: size, height: size)
            
            ControlPanelButtonView<Button6ViewModel>(viewModel: .init())
                .frame(width: size, height: size)
            
            Spacer()
        }.frame(height: size)
    }
    
    private var digitalPanel3: some View {
        HStack(alignment: .center, spacing: space) {
            ControlPanelButtonView<Button7ViewModel>(viewModel: .init())
                .frame(width: size, height: size)
            
            ControlPanelButtonView<Button8ViewModel>(viewModel: .init())
                .frame(width: size, height: size)
            
            ControlPanelButtonView<Button9ViewModel>(viewModel: .init())
                .frame(width: size, height: size)
            
            Spacer()
        }.frame(height: size)
    }
    
    private var digitalPanel4: some View {
        HStack(alignment: .center, spacing: space) {
            Spacer()
                .frame(width: size, height: size)
            
            ControlPanelButtonView<Button0ViewModel>(viewModel: .init())
                .frame(width: size, height: size)
            
            Spacer()
            
        }.frame(height: size)
    }
    
    private var behaviorPanel: some View {
        HStack(alignment: .center, spacing: space) {
            ControlPanelButtonView<ButtonDockViewModel>(viewModel: .init(connection: connection))
                .frame(width: size, height: size)
            
            ControlPanelButtonView<ButtonLiftViewModel>(viewModel: .init(connection: connection))
                .frame(width: size, height: size)
            
            Spacer()
            
        }.frame(height: size)
    }
}
