import Lottie
import SwiftUI

#if os(macOS)
import AppKit
#endif

#if os(iOS)
public struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    
    public init(name: String, loopModel: LottieLoopMode = .loop) {
        self.name = name
        self.loopMode = loopModel
    }
    
    public func makeUIView(context: UIViewRepresentableContext<LottieView>) -> AnimationView {
        let animationView = AnimationView()
        let animation = Animation.named(name, bundle: Bundle.module, subdirectory: nil, animationCache: nil)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = loopMode
        animationView.play()
        return animationView
    }

    public func updateUIView(_ uiView: AnimationView, context: UIViewRepresentableContext<LottieView>) {}
}
#endif

#if os(macOS)
public struct LottieView: NSViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    
    public init(name: String, loopModel: LottieLoopMode = .loop) {
        self.name = name
        self.loopMode = loopModel
    }
    
    public func makeNSView(context: NSViewRepresentableContext<LottieView>) -> AnimationView {
        let animationView = AnimationView()
        let animation = Animation.named(name, bundle: Bundle.module, subdirectory: nil, animationCache: nil)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = loopMode
        animationView.play()
        return animationView
    }

    public func updateNSView(_ uiView: AnimationView, context: NSViewRepresentableContext<LottieView>) {}
}
#endif
