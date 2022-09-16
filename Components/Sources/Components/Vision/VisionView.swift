import Features
import SwiftUI

public struct VisionView: View {
    @StateObject var viewModel: ViewModel
    
    public init(_ model: ConnectionModel) {
        self._viewModel = StateObject(wrappedValue: ViewModel(with: model))
    }
    
    public var body: some View {
        VStack {
            #if os(macOS)
            if let data = viewModel.frame?.data, let image = NSImage(data: data), viewModel.isStreaming {
                ZStack(alignment: .trailing) {
                    Image(nsImage: image)
                        .resizable()
                    headControl
                        .frame(width: 80)
                        .padding(.trailing, 10)
                }
            } else {
                offline
            }
            #elseif os(iOS)
            if let data = viewModel.frame?.data, let image = UIImage(data: data), viewModel.isStreaming {
                ZStack(alignment: .trailing) {
                    Image(uiImage: image)
                        .resizable()
                    headControl
                        .frame(width: 80)
                        .padding(.trailing, 10)
                }
            } else {
                offline
            }
            #endif
        }
        .overlay {
            facet
        }
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
            .scaledToFill()
    }
    
    var offline: some View {
        ZStack(alignment: .center) {
            LottieView(name: "offline")
//                .scaleEffect(x: 1, y: 0.4620, anchor: .center)
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
            Text(L10n.offline)
                .font(bold(64))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
