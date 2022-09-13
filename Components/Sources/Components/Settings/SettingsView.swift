import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel: ViewModel
    
    private let invalidCharacters = CharacterSet(charactersIn: ".0123456789").inverted
    @State private var ip: String = ""
    @State private var certPath: String = ""
    @State private var guid: String = ""
    @Binding private var isPresented: Bool
    
    public init(model: SettingsModel, isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: .init(model))
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(L10n.connection) {
                    TextField(L10n.ipAddress, text: $ip)
                        .onChange(of: ip) { newValue in
                            ip = trimInvalidCharacters(newValue)
                            viewModel.ip = ip
                            viewModel.validate()
                        }
                        .onSubmit {
                            viewModel.ip = ip
                        }
                        .onAppear {
                            ip = viewModel.ip
                        }
                        .disableAutocorrection(true)
                    
                    TextField(L10n.certificate, text: $certPath)
                        .disabled(true)
                    
                    TextField(L10n.guid, text: $guid)
                        .disabled(true)
                }
                
                Section(L10n.vector) {
                    ColorPicker(L10n.eyeColor, selection: $viewModel.eyeColor)
                    
                    Picker(L10n.locale, selection: $viewModel.locale) {
                        ForEach(Locale.preferredLanguages, id: \.self) {
                            let locale = Locale(identifier: $0)
                            Text(locale.identifier)
                        }
                    }
                }
                
#if os(macOS)
                Section {
                    HStack {
                        Spacer()

                        Button {
                            viewModel.save()
                            isPresented = false
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.green)
                        }
                        .buttonStyle(.plain)
                        .disabled(!viewModel.isValid)
                        
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                        .disabled(!viewModel.isValid)
                    }
                }
#endif
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
#elseif os(macOS)
            .padding(10)
#endif
        }
    }
    
    private func trimInvalidCharacters(_ source: String) -> String {
        source
            .components(separatedBy: invalidCharacters)
            .joined()
    }
}

struct SettingsPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(model: .init(), isPresented: .constant(true))
    }
}
