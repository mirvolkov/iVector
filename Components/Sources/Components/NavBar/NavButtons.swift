import SwiftUI

public extension View {
    typealias OnClick = () -> ()

    func socketButton(online: Bool? = nil, onClick: @escaping OnClick) -> some View {
        Button {
            onClick()
        } label: {
            Image(systemName: "antenna.radiowaves.left.and.right.circle")
                .foregroundColor(online == true ? .green : .black)
        }.buttonStyle(.plain)
    }

    func settingsButton(onClick: @escaping OnClick) -> some View {
        Button {
            onClick()
        } label: {
            Image(systemName: "gear")
        }.buttonStyle(.plain)
    }

    func motionButton(online: Bool? = nil, onClick: @escaping OnClick) -> some View {
        Button {
            onClick()
        } label: {
            Image(systemName: "gyroscope")
                .foregroundColor(online == true ? .green : .black)
        }.buttonStyle(.plain)
    }

    func tagButton(onClick: @escaping OnClick) -> some View {
        Button {
            onClick()
        } label: {
            Image(systemName: "tag.circle")
        }.buttonStyle(.plain)
    }
}
