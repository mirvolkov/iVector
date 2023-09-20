import Connection
import CoreML
import CoreMotion
import SwiftUI

public struct MotionRecView: View {
    public class ViewModel: ObservableObject {
        static let predictionWindowSize = 100
        var currentState = try? MLMultiArray(
            shape: [400 as NSNumber],
            dataType: MLMultiArrayDataType.double)
        let accX = try? MLMultiArray(
            shape: [ViewModel.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let accY = try? MLMultiArray(
            shape: [ViewModel.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let accZ = try? MLMultiArray(
            shape: [ViewModel.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let rotX = try? MLMultiArray(
            shape: [ViewModel.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let rotY = try? MLMultiArray(
            shape: [ViewModel.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let rotZ = try? MLMultiArray(
            shape: [ViewModel.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        var currentIndexInPredictionWindow = 0
    }

    @StateObject private var viewModel: ViewModel = .init()
    @EnvironmentObject private var store: VectorStore
    @EnvironmentObject private var env: VectorAppEnvironment
    let db: SQLiteConnection = try! .init()
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let model = try? col.init(configuration: .init())

    public var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 20) {
                Button {
                    try? db.insert(tag: "Col")
                } label: {
                    Text("C").frame(width: 120, height: 120, alignment: .center)
                }.buttonStyle(.bordered)

                Button {
                    try? db.insert(tag: "Axel")
                } label: {
                    Text("A").frame(width: 120, height: 120, alignment: .center)
                }.buttonStyle(.bordered)
            }

            HStack(alignment: .center, spacing: 20) {
                Button {
                    try? db.insert(tag: "Move")
                } label: {
                    Text("M").frame(width: 120, height: 120, alignment: .center)
                }.buttonStyle(.bordered)

                Button {
                    try? db.insert(tag: "Stay")
                } label: {
                    Text("S").frame(width: 120, height: 120, alignment: .center)
                }.buttonStyle(.bordered)
            }
        }
        .onAppear {
            self.motionManager.startAccelerometerUpdates(to: self.queue) { data, _ in
                guard let data = data?.acceleration else { return }
                try? db.insert(axelerometer: (data.x, data.y, data.z))
            }
            self.motionManager.startGyroUpdates(to: self.queue) { data, _ in
                guard let data = data else { return }
                try? db.insert(gyroscope: (data.rotationRate.x, data.rotationRate.y, data.rotationRate.z))
            }
            self.motionManager.startDeviceMotionUpdates(to: self.queue) { data, _ in
                guard let motionSample = data else { return }
                self.viewModel.rotX![self.viewModel.currentIndexInPredictionWindow] = motionSample.rotationRate.x as NSNumber
                self.viewModel.rotY![self.viewModel.currentIndexInPredictionWindow] = motionSample.rotationRate.y as NSNumber
                self.viewModel.rotZ![self.viewModel.currentIndexInPredictionWindow] = motionSample.rotationRate.z as NSNumber
                self.viewModel.accX![self.viewModel.currentIndexInPredictionWindow] = motionSample.userAcceleration.x as NSNumber
                self.viewModel.accY![self.viewModel.currentIndexInPredictionWindow] = motionSample.userAcceleration.y as NSNumber
                self.viewModel.accZ![self.viewModel.currentIndexInPredictionWindow] = motionSample.userAcceleration.z as NSNumber
                self.viewModel.currentIndexInPredictionWindow += 1
                if self.viewModel.currentIndexInPredictionWindow == MotionRecView.ViewModel.predictionWindowSize {
                    self.viewModel.currentIndexInPredictionWindow = 0
                }

                let modelPrediction = try? model?.prediction(
                    x: self.viewModel.accX!,
                    y: self.viewModel.accY!,
                    z: self.viewModel.accZ!,
//                    rotation_x: rotX!,
//                    rotation_y: rotY!,
//                    rotation_z: rotZ!,
                    stateIn: self.viewModel.currentState!)
                // Update the state vector
                self.viewModel.currentState = modelPrediction?.stateOut
                print(modelPrediction?.label)
//                try? db.insert(motion : (data.attitude.pitch, data.attitude.roll, data.attitude.yaw))
            }
        }
    }
}
