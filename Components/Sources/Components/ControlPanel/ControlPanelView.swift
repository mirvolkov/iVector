import Features
import Programmator
import SwiftUI

public struct ControlPanelsView: View {
    @State var size: CGFloat = 60
    @State var space: CGFloat = 8
    @State var divider: CGFloat = 4

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
        VStack(spacing: 0) {
            Grid(horizontalSpacing: 0, verticalSpacing: space) {
                header
                Spacer()
                    .gridCellUnsizedAxes(.vertical)
                    .frame(minHeight: divider)
                digitalPanel1
                digitalPanel2
                digitalPanel3
                digitalPanel4
                Spacer()
                    .gridCellUnsizedAxes(.vertical)
                    .frame(minHeight: divider)
                behaviorPanel
                behaviorPanel1
                pcPanel
            }
            .gridColumnAlignment(.leading)
            Spacer()
        }
        .padding(space)
        .popover(isPresented: $viewModel.playPopover, content: {
            PickListPopover(
                viewModel: viewModel.play
            )
        })
        .popover(isPresented: $viewModel.showPrograms, content: {
            PickListPopover(
                viewModel: viewModel.exec
            )
        })
        .popover(isPresented: $viewModel.showVisionObjects, content: {
            PickListPopover(
                viewModel: viewModel.btn7
            )
        })
        .popover(isPresented: $viewModel.showTextRequest, content: {
            TextFieldPopover(
                title: L10n.typeInMessageToListen,
                placeholder: L10n.listen,
                button: L10n.listen,
                viewModel: viewModel.btn9
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
            viewModel.tagInitial()
        }
        .errorAlert(
            error: $viewModel.saveError
        )
    }

    private var header: some View {
        GridRow {
            build(viewModel.powerBtn)
            build(viewModel.tts)
            build(viewModel.play)
            Spacer()
                .gridCellUnsizedAxes(.horizontal)
            build(viewModel.save)
        }
    }

    private var digitalPanel1: some View {
        GridRow {
            build(viewModel.btn1)
            build(viewModel.btn2)
            build(viewModel.btn3)
            Spacer()
                .gridCellUnsizedAxes(.horizontal)
            build(viewModel.esc)
        }
    }

    private var digitalPanel2: some View {
        GridRow {
            build(viewModel.btn4)
            build(viewModel.btn5)
            build(viewModel.btn6)
            Spacer()
                .gridCellUnsizedAxes(.horizontal)
            build(viewModel.enter)
        }
    }

    private var digitalPanel3: some View {
        GridRow {
            build(viewModel.btn7)
            build(viewModel.btn8)
            build(viewModel.btn9)
            Spacer()
                .gridCellUnsizedAxes(.horizontal)
            placeholder
        }
    }

    private var digitalPanel4: some View {
        GridRow {
            placeholder
            build(viewModel.btn0)
            build(viewModel.pause)
            Spacer()
                .gridCellUnsizedAxes(.horizontal)
            placeholder
        }
    }

    private var behaviorPanel: some View {
        GridRow {
            build(viewModel.dockBtn)
            build(viewModel.lift)
            build(viewModel.exec)
            Spacer()
                .gridCellUnsizedAxes(.horizontal)
            placeholder
        }
    }

    private var behaviorPanel1: some View {
        GridRow {
            build(viewModel.undockBtn)
            build(viewModel.down)
            placeholder
            Spacer()
                .gridCellUnsizedAxes(.horizontal)
            placeholder
        }
    }

    private var placeholder: some View {
        Spacer()
            .gridCellUnsizedAxes(.horizontal)
            .frame(width: size, height: size)
    }

    private var pcPanel: some View {
        HStack {
            Text(viewModel.command ?? "")
                .font(vectorBold(24.0))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
            Spacer()
        }
    }

    private func build<ViewModel: ControlPanelButtonViewModel>(_ viewModel: ViewModel) -> some View where ViewModel.Tag == CPViewModelTag {
        ControlPanelButtonView(viewModel: viewModel)
            .compositingGroup()
            .frame(width: size, height: size)
            .simultaneousGesture(
                TapGesture().onEnded { _ in
                    if let tag = viewModel.tag, viewModel.enabled {
                        self.viewModel.onTag(tag)
                    }
                }
            )
    }
}
