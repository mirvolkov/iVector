import Features
import Observation
import Programmator
import SwiftUI

public struct VisionView: View {
    @StateObject var camViewModel: ViewModel
    @StateObject var menuViewModel: MenuViewModel
    @StateObject var telemetryViewModel: TelemetryViewModel

    private let context = CIContext()

    public init(connection: ConnectionModel, vision: VisionModel, executor: ExecutorModel) {
        self._camViewModel = .init(wrappedValue: ViewModel(with: connection, vision: vision))
        self._menuViewModel = .init(wrappedValue: MenuViewModel(with: connection, executor: executor))
        self._telemetryViewModel = .init(wrappedValue: .init(with: connection))
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
        ZStack {
            image
                .resizable()
        }.overlay(alignment: .trailing) {
            headControl
                .frame(width: 80)
                .padding(.trailing, 10)
                .padding(.top, 80)
        }.overlay(alignment: .top) {
            menu
                .frame(height: 80)
                .padding(.top, 80)
        }.overlay(alignment: .topLeading) {
            telemetry
                .frame(width: 100)
                .padding(.leading, 20)
                .padding(.top, 140)
        }.overlay(alignment: .center) {
            aim
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

    private var aim: some View {
        Image(packageResource: "aim", ofType: "png")
            .resizable()
            .opacity(0.2)
            .frame(width: 100, height: 100)
    }

    private var telemetry: some View {
        VStack(alignment: .leading) {
            Text(telemetryViewModel.stt ?? "---")
                .font(vectorBold(12))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 100, alignment: .leading)
            Text(telemetryViewModel.motionLabel ?? "---")
                .font(vectorBold(12))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 100, alignment: .leading)
            Text(telemetryViewModel.battery ?? "---")
                .font(vectorBold(12))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 100, alignment: .leading)
            Text(telemetryViewModel.heading?.description ?? "---")
                .font(vectorBold(12))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 100, alignment: .leading)
            Text(telemetryViewModel.sonars?.map { $0.description }.joined(separator: " ") ?? "---")
                .font(vectorBold(12))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 100, alignment: .leading)
            Text(telemetryViewModel.observations.joined(separator: "|"))
                .font(vectorBold(12))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 100, alignment: .leading)
        }
    }

    private var facet: some View {
        Image("facet")
            .resizable(capInsets: .init(), resizingMode: .tile)
            .allowsHitTesting(false)
            .scaledToFill()
    }
}
