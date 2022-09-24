import Features
import SwiftUI

public struct ControlPanelsView: View {
    @State var size: CGFloat = 60
    @State var space: CGFloat = 8
    @State var tts: String = ""
    @StateObject var viewModel: ControlPanelViewModel
    
    public var onConnect: () -> Void
    public var onDisconnect: () -> Void
    public init(
        connection: ConnectionModel,
        settings: SettingsModel,
        onConnect: @escaping () -> Void,
        onDisconnect: @escaping () -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: .init(connection, settings))
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
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
        .alert(L10n.say, isPresented: $viewModel.ttsAlert, actions: {
            TextField(L10n.say, text: $tts)
            Button(L10n.cancel, role: .cancel, action: {})
            Button(L10n.say, role: .destructive, action: {
                viewModel.tts.say(tts)
                tts = String()
            })
        }, message: {
            Text(L10n.typeInMessageToSay)
        })
        .onAppear {
            viewModel.powerBtn.onConnect = onConnect
            viewModel.powerBtn.onDisconnect = onDisconnect
        }
        .padding(10)
    }
    
    private var header: some View {
        HStack(alignment: .center, spacing: space) {
            ControlPanelButtonView(viewModel: viewModel.powerBtn)
                .frame(width: size, height: size)
            
            ControlPanelButtonView(viewModel: viewModel.tts)
                .frame(width: size, height: size)
            
            ControlPanelButtonView(viewModel: viewModel.stt)
                .frame(width: size, height: size)
            Spacer()
        }.frame(height: size)
    }
    
    private var digitalPanel1: some View {
        HStack(alignment: .center, spacing: space) {
            build(viewModel.btn1)
            build(viewModel.btn2)
            build(viewModel.btn3)
            Spacer()
                .frame(width: 30)
            Spacer()
        }.frame(height: size)
    }
    
    private var digitalPanel2: some View {
        HStack(alignment: .center, spacing: space) {
            build(viewModel.btn4)
            build(viewModel.btn5)
            build(viewModel.btn6)
            Spacer()
        }.frame(height: size)
    }
    
    private var digitalPanel3: some View {
        HStack(alignment: .center, spacing: space) {
            build(viewModel.btn7)
            build(viewModel.btn8)
            build(viewModel.btn9)
            Spacer()
        }.frame(height: size)
    }
    
    private var digitalPanel4: some View {
        HStack(alignment: .center, spacing: space) {
            Spacer()
                .frame(width: size, height: size)
            build(viewModel.btn0)
            Spacer()
            
        }.frame(height: size)
    }
    
    private var behaviorPanel: some View {
        HStack(alignment: .center, spacing: space) {
            build(viewModel.dockBtn)
            build(viewModel.lift)
            Spacer()
            
        }.frame(height: size)
    }
    
    private func build<ViewModel: ControlPanelButtonViewModel>(_ viewModel: ViewModel) -> some View {
        ControlPanelButtonView(viewModel: viewModel)
            .frame(width: size, height: size)
    }
}
