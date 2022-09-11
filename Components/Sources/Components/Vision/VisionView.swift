import SwiftUI

public actor MyModel: ObservableObject {}

public struct VisionView: View {
    @StateObject var viewModel: VisionViewModel
    
    public init(_ model: ConnectionModel) {
        self._viewModel = StateObject(wrappedValue: VisionViewModel(with: model))
    }
    
    public var body: some View {
        VStack {
            #if os(macOS)
            if let data = viewModel.frame?.data, let image = NSImage(data: data), viewModel.isStreaming {
                ZStack(alignment: .trailing) {
                    Image(nsImage: image)
                        .resizable()
                        .padding(10)
                    menu
                        .padding(.top, 10)
                        .padding(.leading, 10)
                    headControl
                        .frame(width: 80)
                        .padding(.trailing, 10)
                }.overlay {
                    facet
                }.aspectRatio(contentMode: .fit)
            }
            #elseif os(iOS)
            if let data = viewModel.frame?.data, let image = UIImage(data: data), viewModel.isStreaming {
                ZStack(alignment: .trailing) {
                    Image(uiImage: image)
                        .resizable()
                        .padding(10)
                    menu
                        .padding(.top, 10)
                        .padding(.horizontal, 10)
                        .frame(height: 44, alignment: .leading)
                    headControl
                        .frame(width: 80)
                        .padding(.trailing, 10)
                }.overlay {
                    facet
                }.aspectRatio(contentMode: .fit)
            }
            #endif

            Button {
                if !viewModel.isStreaming {
                    viewModel.start()
                } else {
                    viewModel.stop()
                }
            } label: {
                Text("CAM")
            }.disabled(!viewModel.isVectorOnline)
        }.ignoresSafeArea()
    }
    
    var menu: some View {
        EmptyView()
    }
    
    var headControl: some View {
        VStack(alignment: .center) {
            VSliderView(value: $viewModel.headAngle, gradientColors: [.clear, .clear], sliderColor: .white.opacity(0.3))
                .padding(.vertical, 40)
                .padding(.trailing, 20)
            
            Text("\(Int(viewModel.denorm(viewModel.headAngle)))")
                .font(bold(28))
                .foregroundColor(.white.opacity(0.75))
                .padding(.bottom, 40)
                .padding(.trailing, 20)
                .frame(alignment: .center)
        }
    }
    
    var facet: some View {
        Image("facet")
            .resizable(capInsets: .init(), resizingMode: .tile)
            .allowsHitTesting(false)
            .padding(10)
    }
}

struct FacetPreviewProvilder: PreviewProvider {
    @State static var value: UInt = 0
    
    static var previews: some View {
        Group {
            ZStack {
                VisionMenuPanel()
                    .padding(.top, 10)
                    .padding(.leading, 10)
                Image("sample")
                    .resizable()
                    .frame(width: 960, height: 640)
                    .padding(10)
                VSliderView(value: Self.$value, gradientColors: [.clear, .clear], sliderColor: .white)
                    .frame(width: 60)
                    .padding(.vertical, 40)
                    .padding(.trailing, 40)
            }
            .previewDevice("iPad Pro (9.7-inch)")
            .overlay {
                Image("facet")
                    .resizable(capInsets: .init(), resizingMode: .tile)
                    .allowsHitTesting(false)
                    .padding(10)
            }.previewInterfaceOrientation(.portraitUpsideDown)
            ZStack {
                VisionMenuPanel()
                    .padding(.top, 10)
                    .padding(.leading, 10)
                Image("sample")
                    .resizable()
                    .frame(width: 960, height: 640)
                    .padding(10)
                VSliderView(value: Self.$value, gradientColors: [.clear, .clear], sliderColor: .white)
                    .frame(width: 60)
                    .padding(.vertical, 40)
                    .padding(.trailing, 40)
            }
            .previewDevice("iPad Pro (9.7-inch)")
            .overlay {
                Image("facet")
                    .resizable(capInsets: .init(), resizingMode: .tile)
                    .allowsHitTesting(false)
                    .padding(10)
            }.previewInterfaceOrientation(.portraitUpsideDown)
        }
    }
}
