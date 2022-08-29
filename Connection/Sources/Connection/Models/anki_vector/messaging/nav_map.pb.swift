// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: anki_vector/messaging/nav_map.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

// Copyright (c) 2018 Anki, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License in the file LICENSE.txt or at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// External interface for robot <-> app and robot <-> sdk communication
// about the robot's navigational memory map.

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// Every tile in the nav map will be tagged with a content key referring to
/// the different environmental elements that Vector can identify.
public enum Anki_Vector_ExternalInterface_NavNodeContentType: SwiftProtobuf.Enum {
  public typealias RawValue = Int
  case navNodeUnknown // = 0
  case navNodeClearOfObstacle // = 1
  case navNodeClearOfCliff // = 2
  case navNodeObstacleCube // = 3
  case navNodeObstacleProximity // = 4
  case navNodeObstacleProximityExplored // = 5
  case navNodeObstacleUnrecognized // = 6
  case navNodeCliff // = 7
  case navNodeInterestingEdge // = 8
  case navNodeNonInterestingEdge // = 9
  case UNRECOGNIZED(Int)

  public init() {
    self = .navNodeUnknown
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .navNodeUnknown
    case 1: self = .navNodeClearOfObstacle
    case 2: self = .navNodeClearOfCliff
    case 3: self = .navNodeObstacleCube
    case 4: self = .navNodeObstacleProximity
    case 5: self = .navNodeObstacleProximityExplored
    case 6: self = .navNodeObstacleUnrecognized
    case 7: self = .navNodeCliff
    case 8: self = .navNodeInterestingEdge
    case 9: self = .navNodeNonInterestingEdge
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .navNodeUnknown: return 0
    case .navNodeClearOfObstacle: return 1
    case .navNodeClearOfCliff: return 2
    case .navNodeObstacleCube: return 3
    case .navNodeObstacleProximity: return 4
    case .navNodeObstacleProximityExplored: return 5
    case .navNodeObstacleUnrecognized: return 6
    case .navNodeCliff: return 7
    case .navNodeInterestingEdge: return 8
    case .navNodeNonInterestingEdge: return 9
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension Anki_Vector_ExternalInterface_NavNodeContentType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [Anki_Vector_ExternalInterface_NavNodeContentType] = [
    .navNodeUnknown,
    .navNodeClearOfObstacle,
    .navNodeClearOfCliff,
    .navNodeObstacleCube,
    .navNodeObstacleProximity,
    .navNodeObstacleProximityExplored,
    .navNodeObstacleUnrecognized,
    .navNodeCliff,
    .navNodeInterestingEdge,
    .navNodeNonInterestingEdge,
  ]
}

#endif  // swift(>=4.2)

/// An individual sample of vector's nav map.  This quad's size will vary and
/// depends on the resolution the map requires to effectively identify
/// boundaries in the environment.
public struct Anki_Vector_ExternalInterface_NavMapQuadInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var content: Anki_Vector_ExternalInterface_NavNodeContentType = .navNodeUnknown

  public var depth: UInt32 = 0

  public var colorRgba: UInt32 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// General information about the nav map as a whole.
public struct Anki_Vector_ExternalInterface_NavMapInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var rootDepth: Int32 = 0

  public var rootSizeMm: Float = 0

  public var rootCenterX: Float = 0

  public var rootCenterY: Float = 0

  public var rootCenterZ: Float = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// Requests nav map data from the robot at a specified maximum update frequency.
/// Responses in the nav map stream may be sent less frequently if the robot does
/// not consider there to be relevant new information.
public struct Anki_Vector_ExternalInterface_NavMapFeedRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var frequency: Float = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// A full nav map sent from the robot.  It contains an origin_id that
/// which can be compared against the robot's current origin_id, general
/// info about the map, and a collection of quads representing the map's
/// content.
public struct Anki_Vector_ExternalInterface_NavMapFeedResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var originID: UInt32 = 0

  public var mapInfo: Anki_Vector_ExternalInterface_NavMapInfo {
    get {return _mapInfo ?? Anki_Vector_ExternalInterface_NavMapInfo()}
    set {_mapInfo = newValue}
  }
  /// Returns true if `mapInfo` has been explicitly set.
  public var hasMapInfo: Bool {return self._mapInfo != nil}
  /// Clears the value of `mapInfo`. Subsequent reads from it will return its default value.
  public mutating func clearMapInfo() {self._mapInfo = nil}

  public var quadInfos: [Anki_Vector_ExternalInterface_NavMapQuadInfo] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _mapInfo: Anki_Vector_ExternalInterface_NavMapInfo? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Anki_Vector_ExternalInterface_NavNodeContentType: @unchecked Sendable {}
extension Anki_Vector_ExternalInterface_NavMapQuadInfo: @unchecked Sendable {}
extension Anki_Vector_ExternalInterface_NavMapInfo: @unchecked Sendable {}
extension Anki_Vector_ExternalInterface_NavMapFeedRequest: @unchecked Sendable {}
extension Anki_Vector_ExternalInterface_NavMapFeedResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "Anki.Vector.external_interface"

extension Anki_Vector_ExternalInterface_NavNodeContentType: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "NAV_NODE_UNKNOWN"),
    1: .same(proto: "NAV_NODE_CLEAR_OF_OBSTACLE"),
    2: .same(proto: "NAV_NODE_CLEAR_OF_CLIFF"),
    3: .same(proto: "NAV_NODE_OBSTACLE_CUBE"),
    4: .same(proto: "NAV_NODE_OBSTACLE_PROXIMITY"),
    5: .same(proto: "NAV_NODE_OBSTACLE_PROXIMITY_EXPLORED"),
    6: .same(proto: "NAV_NODE_OBSTACLE_UNRECOGNIZED"),
    7: .same(proto: "NAV_NODE_CLIFF"),
    8: .same(proto: "NAV_NODE_INTERESTING_EDGE"),
    9: .same(proto: "NAV_NODE_NON_INTERESTING_EDGE"),
  ]
}

extension Anki_Vector_ExternalInterface_NavMapQuadInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".NavMapQuadInfo"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "content"),
    2: .same(proto: "depth"),
    3: .standard(proto: "color_rgba"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularEnumField(value: &self.content) }()
      case 2: try { try decoder.decodeSingularUInt32Field(value: &self.depth) }()
      case 3: try { try decoder.decodeSingularUInt32Field(value: &self.colorRgba) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.content != .navNodeUnknown {
      try visitor.visitSingularEnumField(value: self.content, fieldNumber: 1)
    }
    if self.depth != 0 {
      try visitor.visitSingularUInt32Field(value: self.depth, fieldNumber: 2)
    }
    if self.colorRgba != 0 {
      try visitor.visitSingularUInt32Field(value: self.colorRgba, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anki_Vector_ExternalInterface_NavMapQuadInfo, rhs: Anki_Vector_ExternalInterface_NavMapQuadInfo) -> Bool {
    if lhs.content != rhs.content {return false}
    if lhs.depth != rhs.depth {return false}
    if lhs.colorRgba != rhs.colorRgba {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anki_Vector_ExternalInterface_NavMapInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".NavMapInfo"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "root_depth"),
    2: .standard(proto: "root_size_mm"),
    3: .standard(proto: "root_center_x"),
    4: .standard(proto: "root_center_y"),
    5: .standard(proto: "root_center_z"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.rootDepth) }()
      case 2: try { try decoder.decodeSingularFloatField(value: &self.rootSizeMm) }()
      case 3: try { try decoder.decodeSingularFloatField(value: &self.rootCenterX) }()
      case 4: try { try decoder.decodeSingularFloatField(value: &self.rootCenterY) }()
      case 5: try { try decoder.decodeSingularFloatField(value: &self.rootCenterZ) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.rootDepth != 0 {
      try visitor.visitSingularInt32Field(value: self.rootDepth, fieldNumber: 1)
    }
    if self.rootSizeMm != 0 {
      try visitor.visitSingularFloatField(value: self.rootSizeMm, fieldNumber: 2)
    }
    if self.rootCenterX != 0 {
      try visitor.visitSingularFloatField(value: self.rootCenterX, fieldNumber: 3)
    }
    if self.rootCenterY != 0 {
      try visitor.visitSingularFloatField(value: self.rootCenterY, fieldNumber: 4)
    }
    if self.rootCenterZ != 0 {
      try visitor.visitSingularFloatField(value: self.rootCenterZ, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anki_Vector_ExternalInterface_NavMapInfo, rhs: Anki_Vector_ExternalInterface_NavMapInfo) -> Bool {
    if lhs.rootDepth != rhs.rootDepth {return false}
    if lhs.rootSizeMm != rhs.rootSizeMm {return false}
    if lhs.rootCenterX != rhs.rootCenterX {return false}
    if lhs.rootCenterY != rhs.rootCenterY {return false}
    if lhs.rootCenterZ != rhs.rootCenterZ {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anki_Vector_ExternalInterface_NavMapFeedRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".NavMapFeedRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "frequency"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularFloatField(value: &self.frequency) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.frequency != 0 {
      try visitor.visitSingularFloatField(value: self.frequency, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anki_Vector_ExternalInterface_NavMapFeedRequest, rhs: Anki_Vector_ExternalInterface_NavMapFeedRequest) -> Bool {
    if lhs.frequency != rhs.frequency {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anki_Vector_ExternalInterface_NavMapFeedResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".NavMapFeedResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "origin_id"),
    2: .standard(proto: "map_info"),
    3: .standard(proto: "quad_infos"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt32Field(value: &self.originID) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._mapInfo) }()
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.quadInfos) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.originID != 0 {
      try visitor.visitSingularUInt32Field(value: self.originID, fieldNumber: 1)
    }
    try { if let v = self._mapInfo {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if !self.quadInfos.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.quadInfos, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anki_Vector_ExternalInterface_NavMapFeedResponse, rhs: Anki_Vector_ExternalInterface_NavMapFeedResponse) -> Bool {
    if lhs.originID != rhs.originID {return false}
    if lhs._mapInfo != rhs._mapInfo {return false}
    if lhs.quadInfos != rhs.quadInfos {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
