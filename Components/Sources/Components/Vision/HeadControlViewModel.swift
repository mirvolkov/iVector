import Combine
import Features
import SwiftUI

protocol HeadControlTools {
    func degreeToNorm(_ value: Double) -> UInt
    func normToDegree(_ value: UInt) -> Float
}

extension HeadControlTools {
    func degreeToNorm(_ value: Double) -> UInt {
        let min: Double = -22
        let max: Double = 45
        return UInt(100 * (value - min) / (max - min))
    }

    func normToDegree(_ value: UInt) -> Float {
        let min: Float = -22
        let max: Float = 45
        return Float(value) / 100.0 * (max - min) + min
    }
}

public extension HeadControlView {
    @MainActor final class ViewModel: ObservableObject, HeadControlTools {
        /// vector's head angle. Degrees (0...100)
        @Published var headAngle: UInt = 0

        private let connection: ConnectionModel
        private var bag = Set<AnyCancellable>()

        public init(with connection: ConnectionModel) {
            self.connection = connection
        }

        public func bind() {
            if let vector = connection.vector {
                $headAngle
                    .dropFirst()
                    .map { $0 }
                    .debounce(for: 0.5, scheduler: RunLoop.main)
                    .sink { [weak self] value in
                        Task {
                            if let angle = self?.normToDegree(value) {
                                try await vector.setHeadAngle(angle)
                            }
                        }
                    }
                    .store(in: &self.bag)

                connection
                    .vectorState
                    .first()
                    .map { $0.headAngleRad }
                    .map { Angle(radians: Double($0)) }
                    .map { self.degreeToNorm($0.degrees) }
                    .receive(on: RunLoop.main)
                    .assign(to: \.headAngle, on: self)
                    .store(in: &self.bag)
            }

            if let pathfinder = connection.pathfinder {
                $headAngle
                    .dropFirst()
                    .map { $0 }
                    .debounce(for: 0.5, scheduler: RunLoop.main)
                    .sink { [weak self] value in
                        Task {
                            if let angle = self?.normToDegree(value) {
                                await pathfinder.setHeadAngle(angle)
                            }
                        }
                    }
                    .store(in: &self.bag)

                pathfinder
                    .headAngle
                    .map { Angle(radians: Double($0)) }
                    .map { self.degreeToNorm($0.degrees) }
                    .receive(on: RunLoop.main)
                    .assign(to: \.headAngle, on: self)
                    .store(in: &self.bag)
            }
        }
    }
}
