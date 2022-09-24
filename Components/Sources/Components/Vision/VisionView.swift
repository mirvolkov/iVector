import Features
import SwiftUI

public struct VisionView: View {
    @StateObject var camViewModel: ViewModel
    @StateObject var menuViewModel: MenuViewModel
    
    public init(connection: ConnectionModel, vision: VisionModel) {
        self._camViewModel = StateObject(wrappedValue: ViewModel(with: connection, vision: vision))
        self._menuViewModel = StateObject(wrappedValue: MenuViewModel(with: connection))
    }
    
    public var body: some View {
        VStack {
            #if os(macOS)
            if let data = camViewModel.frame?.data, let image = NSImage(data: data), camViewModel.isStreaming {
                ZStack(alignment: .trailing) {
                    Image(nsImage: image)
                        .resizable()
                    headControl
                        .frame(width: 80)
                        .padding(.trailing, 10)
                }.overlay(alignment: .top) {
                    menu
                        .frame(height: 80)
                        .padding(.top, 10)
                }
            }
            #elseif os(iOS)
            if let data = camViewModel.frame?.data, let image = UIImage(data: data), camViewModel.isStreaming {
                ZStack(alignment: .trailing) {
                    Image(uiImage: image)
                        .resizable()
                    headControl
                        .frame(width: 80)
                        .padding(.trailing, 10)
                }.overlay(alignment: .top) {
                    menu
                        .frame(height: 80)
                        .padding(.top, 10)
                }
            }
            #endif
        }
        .overlay {
            facet
        }
        .clipped()
    }
    
    var menu: some View {
        MenuView(viewModel: menuViewModel)
    }
    
    var headControl: some View {
        VStack(alignment: .center) {
            VSliderView(value: $camViewModel.headAngle, gradientColors: [.clear, .clear], sliderColor: .white.opacity(0.3))
                .padding(.vertical, 40)
                .padding(.trailing, 20)
            
            Text("\(Int(camViewModel.denorm(camViewModel.headAngle)))")
                .font(vectorBold(28))
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
}

public struct VisionOfflineView: View {
    public init() {}

    public var body: some View {
        ZStack(alignment: .center) {
            LottieView(name: "offline")
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
            Text(L10n.offline)
                .font(vectorBold(64))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.clipped()
    }
}
