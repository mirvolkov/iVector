import SwiftUI

public struct ControlPanelsView: View {
    @State var size: CGFloat = 60
    
    public init() {}

    public var body: some View {
        VStack {
            VStack(spacing: 10) {
                HStack(alignment: .center) {
                    ControlButtonView(viewModel: ControlButtonView.ConnectViewModel())
                        .frame(width: size, height: size)
                    
                    ControlButtonView(viewModel: ControlButtonView.MicViewModel())
                        .frame(width: size, height: size)                    
                    Spacer()
                }.frame(height: size)
                
                
                Spacer()
                    .frame(height: 20)
                
                HStack(alignment: .center) {
                    ControlButtonView(viewModel: ControlButtonView.Button1ViewModel())
                        .frame(width: size, height: size)
                    
                    ControlButtonView(viewModel: ControlButtonView.Button2ViewModel())
                        .frame(width: size, height: size)
                    
                    ControlButtonView(viewModel: ControlButtonView.Button3ViewModel())
                        .frame(width: size, height: size)
                    
                    Spacer()
                        .frame(width: 30)
                    
                    ControlButtonView(viewModel: .init())
                        .frame(width: size, height: size)
                    
                    Spacer()
                }.frame(height: size)
                
                HStack(alignment: .center) {
                    ControlButtonView(viewModel: ControlButtonView.Button4ViewModel())
                        .frame(width: size, height: size)
                    
                    ControlButtonView(viewModel: ControlButtonView.Button5ViewModel())
                        .frame(width: size, height: size)
                    
                    ControlButtonView(viewModel: ControlButtonView.Button6ViewModel())
                        .frame(width: size, height: size)
                    
                    Spacer()
                }.frame(height: size)
                
                HStack(alignment: .center) {
                    ControlButtonView(viewModel: ControlButtonView.Button7ViewModel())
                        .frame(width: size, height: size)
                    
                    ControlButtonView(viewModel: ControlButtonView.Button8ViewModel())
                        .frame(width: size, height: size)
                    
                    ControlButtonView(viewModel: ControlButtonView.Button9ViewModel())
                        .frame(width: size, height: size)
                    
                    Spacer()
                }.frame(height: size)
                
                HStack(alignment: .center) {
                    Spacer()
                        .frame(width: size + 8, height: size)
                    
                    ControlButtonView(viewModel: ControlButtonView.Button0ViewModel())
                        .frame(width: size, height: size)
                    
                    Spacer()
                    
                }.frame(height: size)
                
                Spacer()
            }
        }
        .padding(10)
    }
}

struct ControlPanel_Preview: PreviewProvider {
    static var previews: some View {
        ControlPanelsView()
    }
}
