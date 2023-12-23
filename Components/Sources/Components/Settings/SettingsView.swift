import Features
import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel: ViewModel
    @State private var certPath: String = ".cert"
    @State private var guid: String = ""
    @Binding private var isPresented: Bool
    @State private var showCertPicker = false

    public init(model: SettingsModel, isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: .init(model))
    }

    public var body: some View {
        NavigationView {
            TabView {
                vectorTab
                    .tabItem {
                        Text(L10n.vectorConnection)
                    }

                websocketTab
                    .tabItem {
                        Text(L10n.websocketConnection)
                    }

                cameraTab
                    .tabItem {
                        Text(L10n.camera)
                    }
            }.onAppear {
                viewModel.validate()
            }
#if os(iOS)
            .navigationBarTitle(L10n.settings)
            .toolbar {
                Button {
                    viewModel.save()
                    isPresented = false
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.isValid)
            }
            .sheet(isPresented: $showCertPicker) {
                DocumentPicker(filePath: $viewModel.certPath)
            }
#elseif os(macOS)
            .toolbar {
                Button {
                    viewModel.save()
                    isPresented = false
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.isValid)
            }
            .frame(maxWidth: .infinity)
            .onChange(of: showCertPicker) { _, newShow in
                if newShow {
                    openDocPicker { url in
                        viewModel.certPath = url
                    }
                }
                do {
                    showCertPicker = false
                }
            }
            .padding(10)
#endif
        }
#if os(macOS)
        .frame(width: 320)
        .frame(minHeight: 320)
#endif
    }

    @ViewBuilder
    private var vectorTab: some View {
        Form {
            Section(L10n.vectorConnection) {
                TextField(L10n.ipAddress, text: $viewModel.vectorIP) {
                    viewModel.validate()
                }
                .disableAutocorrection(true)

                Button {
                    showCertPicker = true
                } label: {
                    TextField(
                        L10n.certificate,
                        text: $certPath
                    )
                    .textFieldStyle(.plain)
                    .disabled(true)
                }
                .buttonStyle(.borderless)

                TextField(L10n.guid, text: $guid)
                    .disabled(true)
            }

            Section(L10n.vector) {
                ColorPicker(L10n.eyeColor, selection: $viewModel.eyeColor)

                Picker(L10n.locale, selection: $viewModel.locale) {
                    ForEach(Locale.preferredLanguages, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                .id(UUID())
            }
        }
        .onChange(of: viewModel.certPath) { _, newValue in
            self.certPath = newValue?.lastPathComponent ?? ".cert"
        }
    }

    @ViewBuilder
    private var websocketTab: some View {
        Form {
            Section(L10n.websocketConnection) {
                TextField(L10n.ipAddress, text: $viewModel.vectorIP) {
                    viewModel.validate()
                }
                .disableAutocorrection(true)
            }
        }
    }

    @ViewBuilder
    private var cameraTab: some View {
        Form {
            Section(L10n.camera) {
                Picker(L10n.device, selection: $viewModel.cameraID) {
                    ForEach(viewModel.cameras, id: \.self) {
                        Text($0.name).tag($0.id)
                    }
                }
                .disabled(false)
                .id(UUID())
                .pickerStyle(.radioGroup)

                Spacer()
                    .frame(height: 20)

                Picker(L10n.rotation, selection: $viewModel.rotID) {
                    Text("0").tag(0)
                    Text("90").tag(90)
                    Text("180").tag(180)
                    Text("270").tag(270)
                }
                .disabled(false)
                .id(UUID())
                .pickerStyle(.menu)
            }
        }
    }
}

struct SettingsPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(model: .init(), isPresented: .constant(true))
    }
}
