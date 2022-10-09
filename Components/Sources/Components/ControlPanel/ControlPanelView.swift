import Features
import Programmator
import SwiftUI

public struct ControlPanelsView: View {
    @State var size: CGFloat = 60
    @State var space: CGFloat = 8
    @State var divider: CGFloat = 10

    @StateObject var viewModel: ControlPanelViewModel

    public var onConnect: () -> Void
    public var onDisconnect: () -> Void

    public init(
        connection: ConnectionModel,
        settings: SettingsModel,
        assembler: AssemblerModel,
        onConnect: @escaping () -> Void,
        onDisconnect: @escaping () -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: .init(connection, settings, assembler))
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
                Spacer()
                    .frame(height: divider)
                pcPanel
            }
            Spacer()
        }
        .popover(isPresented: $viewModel.playPopover, content: {
            PickListPopover(
                viewModel: viewModel.play
            )
        })
        .popover(isPresented: $viewModel.ttsAlert, content: {
            TextFieldPopover(
                title: L10n.typeInMessageToSay,
                placeholder: L10n.say,
                button: L10n.say,
                viewModel: viewModel.tts
            )
        })
        .popover(isPresented: $viewModel.showSavePopover, content: {
            TextFieldPopover(
                title: L10n.save,
                placeholder: L10n.nameTheProgram,
                button: L10n.save,
                viewModel: viewModel.save
            )
        })
        .onAppear {
            viewModel.powerBtn.onConnect = onConnect
            viewModel.powerBtn.onDisconnect = onDisconnect
            viewModel.bind()
        }
        .errorAlert(
            error: $viewModel.saveError
        )
        .padding(10)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: space) {
            build(viewModel.powerBtn)
            build(viewModel.tts)
            build(viewModel.play)
            Spacer()
                .frame(width: divider)
            build(viewModel.save)
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
            build(viewModel.pause)
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

    private var pcPanel: some View {
        VStack(alignment: .center) {
            if let command = viewModel.command {
                Text(command)
                    .font(vectorBold(24.0))
                    .frame(alignment: .center)
            }
        }
    }

    private func build<ViewModel: ControlPanelButtonViewModel>(_ viewModel: ViewModel) -> some View where ViewModel.Tag == CPViewModelTag {
        ControlPanelButtonView(viewModel: viewModel)
            .frame(width: size, height: size)
            .simultaneousGesture(
                TapGesture().onEnded { _ in
                    if let tag = viewModel.tag {
                        self.viewModel.onTag(tag)
                    }
                }
            )
    }
}
