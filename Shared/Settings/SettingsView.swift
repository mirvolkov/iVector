import SwiftUI

struct SettingsView: View {
    private let invalidCharacters = CharacterSet(charactersIn: ".0123456789").inverted
    @StateObject var viewModel: SettingsViewModel = .init(AppState.instance.settings)
    @State var ip: String = ""
    @State var certPath: String = ""
    @State var guid: String = ""
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section("Connection") {
                    TextField("IP", text: $ip)
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
                    
                    TextField("Certificate", text: $certPath)
                        .disabled(true)
                    
                    TextField("GUID", text: $guid)
                        .disabled(true)
                }
                
                Section("Vector") {
                    ColorPicker("Eye color", selection: $viewModel.eyeColor)
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
            .padding(10)
#if os(iOS)
                .navigationBarTitle("Settings")
                .toolbar {
                    Button {
                        viewModel.save()
                        isPresented = false
                    } label: {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.isValid)
                }
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
        SettingsView(isPresented: .constant(true))
    }
}
