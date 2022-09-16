import Features
import SwiftUI

// TODO: refactor it using factor builder patter
public struct ControlPanelsView: View {
    @State var size: CGFloat = 60
    
    private let connection: ConnectionModel
    private let settings: SettingsModel
    
    public init(connection: ConnectionModel, settings: SettingsModel) {
        self.connection = connection
        self.settings = settings
    }

    public var body: some View {
        VStack {
            VStack(spacing: 10) {
                HStack(alignment: .center) {
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.ButtonPowerViewModel(
                        connection: connection,
                        settings: settings
                    ))
                        .frame(width: size, height: size)
                    
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.MicViewModel())
                        .frame(width: size, height: size)
                    Spacer()
                }.frame(height: size)
                
                Spacer()
                    .frame(height: 20)
                
                HStack(alignment: .center) {
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.Button1ViewModel())
                        .frame(width: size, height: size)
                    
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.Button2ViewModel())
                        .frame(width: size, height: size)
                    
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.Button3ViewModel())
                        .frame(width: size, height: size)
                    
                    Spacer()
                        .frame(width: 30)
                    
                    ControlPanelButtonView(viewModel: .init())
                        .frame(width: size, height: size)
                    
                    Spacer()
                }.frame(height: size)
                
                HStack(alignment: .center) {
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.Button4ViewModel())
                        .frame(width: size, height: size)
                    
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.Button5ViewModel())
                        .frame(width: size, height: size)
                    
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.Button6ViewModel())
                        .frame(width: size, height: size)
                    
                    Spacer()
                }.frame(height: size)
                
                HStack(alignment: .center) {
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.Button7ViewModel())
                        .frame(width: size, height: size)
                    
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.Button8ViewModel())
                        .frame(width: size, height: size)
                    
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.Button9ViewModel())
                        .frame(width: size, height: size)
                    
                    Spacer()
                }.frame(height: size)
                
                HStack(alignment: .center) {
                    Spacer()
                        .frame(width: size + 8, height: size)
                    
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.Button0ViewModel())
                        .frame(width: size, height: size)
                    
                    Spacer()
                    
                }.frame(height: size)
                
                Spacer()
                    .frame(height: 20)
                
                HStack(alignment: .center) {
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.ButtonDockViewModel(connection: connection))
                        .frame(width: size, height: size)
                    
                    ControlPanelButtonView(viewModel: ControlPanelButtonView.ButtonLiftViewModel(connection: connection))
                        .frame(width: size, height: size)
                    
                    Spacer()
                    
                }.frame(height: size)
            }
        }
        .padding(10)
    }
}
