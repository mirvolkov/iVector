//
//  File.swift
//  
//
//  Created by Miroslav Volkov on 29.08.2022.
//

import Foundation

public struct VectorCameraFrame {
    public let data: Data
}

public protocol Camera {
    /// Request Vector's camera feed
    /// - Returns AsyncStream type with frame
    /// - Throws error if request failed
    func requestCameraFeed() throws -> AsyncStream<VectorCameraFrame>
}
