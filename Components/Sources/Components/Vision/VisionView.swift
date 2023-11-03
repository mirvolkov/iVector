import Features
import Programmator
import SwiftUI

public struct VisionView: View {
    @StateObject var camViewModel: ViewModel
    @StateObject var menuViewModel: MenuViewModel
    private let context = CIContext()

    public init(connection: ConnectionModel, vision: VisionModel, executor: ExecutorModel) {
        self._camViewModel = StateObject(wrappedValue: ViewModel(with: connection, vision: vision))
        self._menuViewModel = StateObject(wrappedValue: MenuViewModel(with: connection, executor: executor))
    }

    public var body: some View {
        VStack {
#if os(macOS)
            if let data = camViewModel.frame?.image, camViewModel.isStreaming {
                display(with: Image(nsImage: NSImage(ciImage: data)))
            }
#elseif os(iOS)
            if let data = camViewModel.frame?.image, camViewModel.isStreaming,
               let cgimg = context.createCGImage(data, from: data.extent)
            {
                display(with: Image(uiImage: UIImage(cgImage: cgimg)))
            }
#endif
        }
        .onAppear {
            menuViewModel.bind()
            camViewModel.bind()
            camViewModel.start()
        }
        .onDisappear {
            camViewModel.stop()
        }
        .overlay {
            facet
        }
        .clipped()
    }

    private func display(with image: Image) -> some View {
        ZStack(alignment: .trailing) {
            image
                .resizable()
            headControl
                .frame(width: 80)
                .padding(.trailing, 10)
                .padding(.top, 80)
            telemetry
                .frame(width: 150)
                .padding(.leading, 10)
                .padding(.top, 80)
        }.overlay(alignment: .top) {
            menu
                .frame(height: 80)
                .padding(.top, 80)
        }
    }

    private var menu: some View {
        MenuView(viewModel: menuViewModel)
    }

    private var headControl: some View { 
        VStack(alignment: .center) {
            VSliderView(value: $camViewModel.headAngle, gradientColors: [.white.opacity(0.3), .white.opacity(0.3)], sliderColor: .white.opacity(0.3))
                .padding(.vertical, 40)
                .padding(.trailing, 20)
            
            Text("\(Int(camViewModel.normToDegree(camViewModel.headAngle)))")
                .font(vectorBold(28))
                .foregroundColor(.white.opacity(0.75))
                .padding(.bottom, 40)
                .padding(.trailing, 20)
                .frame(alignment: .center)
        }
    }

    private var telemetry: some View {
        EmptyView()
    }

    private var facet: some View {
        Image("facet")
            .resizable(capInsets: .init(), resizingMode: .tile)
            .allowsHitTesting(false)
            .scaledToFill()
    }
}
