import SwiftUI

struct VisionView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    #endif
    @StateObject var viewModel = VisionViewModel(with: AppState.instance.connection)

    var body: some View {
        VStack {
            #if os(macOS)
            if let data = viewModel.frame?.data, let image = NSImage(data: data), viewModel.isStreaming {
                ZStack {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: 240, height: 160)
                        .padding(10)
                    // TODO: menu here
                }.overlay {
                    Image("facet")
                        .resizable(capInsets: .init(), resizingMode: .tile)
                        .allowsHitTesting(false)
                        .padding(10)
                }
            }
            #elseif os(iOS)
            if let data = viewModel.frame?.data, let image = UIImage(data: data), viewModel.isStreaming {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
//                        .frame(width: 960, height: 640)
                        .padding(10)
                    // TODO: menu here
                }.overlay {
                    Image("facet")
                        .resizable(capInsets: .init(), resizingMode: .tile)
                        .allowsHitTesting(false)
                        .padding(10)
                }.onAppear {
                    print((horizontalSizeClass, verticalSizeClass))
                }
                .aspectRatio(contentMode: .fit)
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
}

struct FacetPreviewProvilder: PreviewProvider {
    static var previews: some View {
        ZStack {
            Image("sample")
                .resizable()
                .frame(width: 960, height: 640)
                .padding(10)
            // TODO: menu here
        }.overlay {
            Image("facet")
                .resizable(capInsets: .init(), resizingMode: .tile)
                .allowsHitTesting(false)
                .padding(10)
        }
    }
}
