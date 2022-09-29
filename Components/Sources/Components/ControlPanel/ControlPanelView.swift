import Features
import SwiftUI

public struct ControlPanelsView: View {
    #if os(macOS)
    @State var size: CGFloat = 50
    #else
    @State var size: CGFloat = 70
    #endif
    
    @State var space: CGFloat = 8
    @State var divider: CGFloat = 10

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
            VStack(spacing: divider) {
                header
                Spacer()
                    .frame(height: divider)
                digitalPanel1
                digitalPanel2
                digitalPanel3
                digitalPanel4
                Spacer()
                    .frame(height: divider)
                behaviorPanel
            }
            Spacer()
        }
        .popover(isPresented: $viewModel.playPopover, content: {
            PlaySoundPopover(viewModel: viewModel.play)
        })
        .popover(isPresented: $viewModel.ttsAlert, content: {
            PlaySpeechPopover(viewModel: viewModel.tts)
        })
        .onAppear {
            viewModel.powerBtn.onConnect = onConnect
            viewModel.powerBtn.onDisconnect = onDisconnect
        }
        .padding(10)
    }
    
    private var header: some View {
        HStack(alignment: .center, spacing: space) {
            build(viewModel.powerBtn)
            build(viewModel.tts)
            build(viewModel.play)
            Spacer()
                .frame(width: divider)
            placeholder
            Spacer()
        }.frame(height: size)
    }
    
    private var digitalPanel1: some View {
        HStack(alignment: .center, spacing: space) {
            build(viewModel.btn1)
            build(viewModel.btn2)
            build(viewModel.btn3)
            Spacer()
                .frame(width: divider)
            build(viewModel.esc)
            Spacer()
        }.frame(height: size)
    }
    
    private var digitalPanel2: some View {
        HStack(alignment: .center, spacing: space) {
            build(viewModel.btn4)
            build(viewModel.btn5)
            build(viewModel.btn6)
            Spacer()
                .frame(width: divider)
            build(viewModel.enter)
            Spacer()
        }.frame(height: size)
    }
    
    private var digitalPanel3: some View {
        HStack(alignment: .center, spacing: space) {
            build(viewModel.btn7)
            build(viewModel.btn8)
            build(viewModel.btn9)
            Spacer()
                .frame(width: divider)
            placeholder
            Spacer()
        }.frame(height: size)
    }
    
    private var digitalPanel4: some View {
        HStack(alignment: .center, spacing: space) {
            placeholder
            build(viewModel.btn0)
            placeholder
            Spacer()
                .frame(width: divider)
            placeholder
            Spacer()
            
        }.frame(height: size)
    }
    
    private var behaviorPanel: some View {
        HStack(alignment: .center, spacing: space) {
            build(viewModel.dockBtn)
            build(viewModel.lift)
            placeholder
            Spacer()
                .frame(width: divider)
            placeholder
            Spacer()
            
        }.frame(height: size)
    }
    
    private var placeholder: some View {
        Spacer()
            .frame(width: size, height: size)
    }
    
    private func build<ViewModel: ControlPanelButtonViewModel>(_ viewModel: ViewModel) -> some View {
        ControlPanelButtonView(viewModel: viewModel)
            .frame(width: size, height: size)
    }
}
