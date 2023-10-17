import SwiftUI

public extension View {
    typealias OnClick = () -> ()

    func socketButton(online: Bool? = nil, onClick: OnClick? = nil) -> some View {
        Button {
            onClick?()
        } label: {
            Image(systemName: "antenna.radiowaves.left.and.right.circle")
                .foregroundColor(online == true ? .green : .black)
        }.buttonStyle(.plain).disabled(onClick == nil)
    }

    func settingsButton(onClick: OnClick? = nil) -> some View {
        Button {
            onClick?()
        } label: {
            Image(systemName: "gear")
        }.buttonStyle(.plain).disabled(onClick == nil)
    }

    func motionButton(online: Bool? = nil, onClick: OnClick? = nil) -> some View {
        Button {
            onClick?()
        } label: {
            Image(systemName: "gyroscope")
                .foregroundColor(online == true ? .green : .black)
        }.buttonStyle(.plain).disabled(onClick == nil)
    }

    func tagButton(online: Bool? = nil, onClick: OnClick? = nil) -> some View {
        Button {
            onClick?()
        } label: {
            Image(systemName: "tag.circle")
                .foregroundColor(online == true ? .green : .black)
        }.buttonStyle(.plain).disabled(onClick == nil)
    }

    func camButton(online: Bool? = nil, onClick: OnClick? = nil) -> some View {
        Button {
            onClick?()
        } label: {
            Image(systemName: "camera.circle")
                .foregroundColor(online == true ? .green : .black)
        }.buttonStyle(.plain).disabled(onClick == nil)
    }

    func micButton(online: Bool? = nil, onClick: OnClick? = nil) -> some View {
        Button {
            onClick?()
        } label: {
            Image(systemName: "mic.circle")
                .foregroundColor(online == true ? .green : .black)
        }.buttonStyle(.plain).disabled(onClick == nil)
    }
}
