import Features
import Observation
import Programmator
import SwiftUI
import Vision

extension VisionFeature.VisionObservation {
    var inverted: CGRect {
        let bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        return rect.applying(bottomToTopTransform)
    }
}

public struct VisionView: View {
    @StateObject private var viewModel: ViewModel
    private let context = CIContext()

    public init(vision: VisionModel) {
        self._viewModel = .init(wrappedValue: ViewModel(with: vision))
    }

    public var body: some View {
        VStack {
            viewport()
        }
        .onAppear {
            viewModel.bind()
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    @ViewBuilder
    private func viewport() -> some View {
#if os(macOS)
        if let data = viewModel.frame?.image, viewModel.isStreaming {
            display(with: Image(nsImage: NSImage(ciImage: data)))
        } else {
            Color.black
        }
#elseif os(iOS)
        if let data = viewModel.frame?.image, viewModel.isStreaming,
           let cgimg = context.createCGImage(data, from: data.extent)
        {
            display(with: Image(uiImage: UIImage(cgImage: cgimg)))
        } else {
            Color.black
        }
#endif
    }

    private func display(with image: Image) -> some View {
        ZStack {
            image
                .resizable()
        }
        .overlay {
            GeometryReader { geometry in
                ForEach(viewModel.objects) { object in
                    bbox(for: object, geometry: geometry)
                }
            }
        }
    }

    @ViewBuilder
    private func bbox(for object: VisionFeature.VisionObservation, geometry: GeometryProxy) -> some View {
        Rectangle()
            .stroke(Color.green.opacity(0.5), lineWidth: 2)
            .frame(width: object.inverted.width * geometry.size.width, height: object.inverted.height * geometry.size.height)
            .position(x: object.inverted.midX * geometry.size.width, y: object.inverted.midY * geometry.size.height)

        HStack {
            Text(object.label)
                .foregroundStyle(Color.white)
            Spacer()
            Text("\(object.confidence)")
                .foregroundStyle(Color.white)
        }
        .frame(width: object.rect.width * geometry.size.width, height: 24)
        .background(Color.green.opacity(0.5))
        .padding(.leading, object.inverted.minX * geometry.size.width)
        .padding(.top, object.inverted.minY * geometry.size.height)
    }
}

public struct AimView: View {
    public init() {}
    public var body: some View {
        Image(packageResource: "aim", ofType: "png")
            .resizable()
            .opacity(0.2)
            .frame(width: 100, height: 100)
    }
}

public struct FacetView: View {
    public init() {}
    public var body: some View {
        Image("facet")
            .resizable(capInsets: .init(), resizingMode: .tile)
            .allowsHitTesting(false)
            .scaledToFill()
    }
}

public struct HeadControlView: View {
    @StateObject private var viewModel: ViewModel

    public init(with connection: ConnectionModel) {
        self._viewModel = .init(wrappedValue: .init(with: connection))
    }

    public var body: some View {
        VStack(alignment: .center) {
            VSliderView(value: $viewModel.headAngle, gradientColors: [.white.opacity(0.3), .white.opacity(0.3)], sliderColor: .white.opacity(0.3))
                .padding(.vertical, 40)
                .padding(.trailing, 20)

            Text("\(Int(viewModel.normToDegree(viewModel.headAngle)))")
                .font(vectorBold(28))
                .foregroundColor(.white.opacity(0.75))
                .padding(.bottom, 40)
                .padding(.trailing, 20)
                .frame(alignment: .center)
        }.onAppear {
            viewModel.bind()
        }
    }
}

public struct TelemetryView: View {
    @StateObject private var viewModel: ViewModel

    public init(with connection: ConnectionModel) {
        self._viewModel = .init(wrappedValue: .init(with: connection))
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.stt ?? "---")
                .font(vectorBold(12))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 100, alignment: .leading)
            Text(viewModel.motionLabel ?? "---")
                .font(vectorBold(12))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 100, alignment: .leading)
            Text(viewModel.battery ?? "---")
                .font(vectorBold(12))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 100, alignment: .leading)
            Text(viewModel.heading?.formatted() ?? "---")
                .font(vectorBold(12))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 100, alignment: .leading)
            Text(viewModel.sonars?.map { $0.description }.joined(separator: " ") ?? "---")
                .font(vectorBold(12))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 100, alignment: .leading)
            Text(viewModel.observations.joined(separator: "|"))
                .font(vectorBold(12))
                .foregroundColor(.white.opacity(0.75))
                .frame(width: 100, alignment: .leading)
        }
    }
}
