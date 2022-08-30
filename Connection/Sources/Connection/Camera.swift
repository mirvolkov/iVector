//
//  File.swift
//  
//
//  Created by Miroslav Volkov on 29.08.2022.
//

import Foundation

public struct VectorCameraFrame {
    
}

protocol Camera {
    /// Request Vector's camera feed
    /// - Returns AsyncStream type with frame
    /// - Throws error if request failed
    func requestFeed() throws -> AsyncStream<VectorCameraFrame>
}
