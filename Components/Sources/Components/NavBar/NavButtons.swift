import SwiftUI

extension View {
    public typealias OnClick = () -> ()

    public func socketButton(online: Bool? = nil, onClick: @escaping OnClick) -> some View {
        Button {
            onClick()
        } label: {
            Image(systemName: "antenna.radiowaves.left.and.right.circle")
                .foregroundColor(online == true ? .green : .black)
        }.buttonStyle(.plain)
    }

    public func settingsButton(onClick: @escaping OnClick) -> some View {
        Button {
            onClick()
        } label: {
            Image(systemName: "gear")
        }.buttonStyle(.plain)
    }
}
