import SwiftUI

public struct VSliderView: View {
    @Binding var value: UInt
    private var gradientColors: [Color]
    private var sliderColor: Color
    private var maxValue: UInt
    private let borderPadding: CGFloat = 2

    public init(
        value: Binding<UInt>,
        gradientColors: [Color],
        sliderColor: Color = .black,
        max: UInt = 100,
        action: ((_ value: Int) -> Void)? = nil
    ) {
        _value = value
        maxValue = max
        self.sliderColor = sliderColor
        self.gradientColors = gradientColors
    }

    // convert value into Y position (note 0 - is middle)
    private func valueToOffset(for geometry: GeometryProxy) -> CGFloat {
        (CGFloat(value) / CGFloat(maxValue) * 2 - 1) * (geometry.size.height / 2 -
            geometry.size.width / 2 -
            borderPadding)
    }

    // conver Y position into value (0...maxValue)
    private func offsetToValue(_ offset: CGFloat, for geometry: GeometryProxy) -> UInt {
        let halfWidth = geometry.size.width / 2
        let halfHeight = geometry.size.height / 2
        let percent = (offset / (halfHeight - halfWidth) + 1)
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
                            endPoint: .init(x: 0, y: 1)
                        ))

                    slider(geometry)
                }
                .cornerRadius(geometry.size.width)
            }
        }
    }

    private func slider(_ geometry: GeometryProxy) -> some View {
        Circle()
            .strokeBorder(sliderColor, lineWidth: 2)
            .background(sliderBorder)
            .animation(.linear, value: 0.1)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .offset(x: 0, y: valueToOffset(for: geometry))
            .padding(borderPadding)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let diff = gesture.location.y - geometry.size.height / 2
                        let halfWidth = geometry.size.width / 2
                        let halfHeight = geometry.size.height / 2
                        var offset = min(halfHeight - halfWidth, diff)
                        offset = max(-halfHeight + halfWidth, offset)
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
