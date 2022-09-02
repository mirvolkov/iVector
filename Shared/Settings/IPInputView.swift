import SwiftUI

struct HEXColorInput: View {
    @Binding var hexString: String
    @State private var input = ""
    @State private var convError: String?
    @State private var previousInput = ""
    @State private var validationError = false
    private static let regex = "([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
    private static let invalidCharacters = CharacterSet(charactersIn: ".0123456789").inverted

    var body: some View {
        TextField("IP", text: $input)
            .onChange(of: input) { newValue in
//                let diff = input.count - previousInput.count
                previousInput = newValue
//                input = String(validateHEX(newValue).prefix(charLength))
            }
            .onSubmit {
//                input = trimSpecial(input)
            }
            .onAppear {
                setInput(hexString)
            }
            .onChange(of: hexString) { setInput($0) }
            .disableAutocorrection(true)
            
    }

    private func setInput(_ value: String) {
        previousInput = value
        input = value
    }

    private func validateHEX(_ source: String) -> String {
        source
            .components(separatedBy: HEXColorInput.invalidCharacters)
            .joined()
    }

    private func isValid(_ hex: String) -> Bool {
        hex.range(of: HEXColorInput.regex, options: .regularExpression) != nil
    }
}
