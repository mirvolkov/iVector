import SwiftUI

public struct HSliderView: View {
    @Binding var value: UInt
    private var gradientColors: [Color]
    private var sliderColor: Color
    private var maxValue: UInt
    private let borderPadding: CGFloat = 2

    public init(
        value: Binding<UInt>,
        gradientColors: [Color],
        sliderColor: Color = .black,
        max: UInt,
        action: ((_ value: Int) -> Void)? = nil
    ) {
        _value = value
        maxValue = max
        self.sliderColor = sliderColor
        self.gradientColors = gradientColors
    }

    // convert value into x position (note 0 - is middle)
    private func valueToOffset(for geometry: GeometryProxy) -> CGFloat {
        (CGFloat(value) / CGFloat(maxValue) * 2 - 1) * (geometry.size.width / 2 -
            geometry.size.height / 2 -
            borderPadding)
    }

    // conver x position into value (0...maxValue)
    private func offsetToValue(_ offset: CGFloat, for geometry: GeometryProxy) -> UInt {
        let halfWidth = geometry.size.width / 2
        let halfHeight = geometry.size.height / 2
        let percent = (offset / (halfWidth - halfHeight) + 1)
        return UInt(percent * CGFloat(maxValue) / 2)
    }

    public var body: some View {
        HStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: .init(colors: gradientColors),
                            startPoint: .zero,
                            endPoint: .init(x: 1, y: 0)
                        ))

                    slider(geometry)
                }
                .cornerRadius(geometry.size.height)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func slider(_ geometry: GeometryProxy) -> some View {
        Circle()
            .strokeBorder(sliderColor, lineWidth: 2)
            .background(sliderBorder)
            .animation(.linear, value: 0.1)
            .frame(width: geometry.size.height, height: geometry.size.height)
            .offset(x: valueToOffset(for: geometry), y: 0)
            .padding(borderPadding)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let diff = gesture.location.x - geometry.size.height / 2
                        let halfWidth = geometry.size.width / 2
                        let halfHeight = geometry.size.height / 2
                        var offset = min(halfWidth - halfHeight, diff)
                        offset = max(-halfWidth + halfHeight, offset)
                        let newValue = offsetToValue(offset, for: geometry)
                        self.value = newValue
                    }
            )
    }

    private var sliderBorder: some View {
        Circle()
            .fill(sliderColor)
    }
}
