//
//  VideoInstruction.swift
//  ToneMapDemo
//
//  Created by Jeffrey Blagdon on 2025-02-25.
//

import Foundation
import AVFoundation

final class VideoInstruction: NSObject, AVVideoCompositionInstructionProtocol {
    var requiredSourceTrackIDs: [NSValue]? {
        [videoTrackID as NSValue]
    }

    var requiredSourceSampleDataTrackIDs: [NSNumber] {
        [videoTrackID as NSNumber]
    }

    // Fixed
    let enablePostProcessing: Bool = true
    let containsTweening: Bool = false
    let passthroughTrackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid

    // Variable
    let timeRange: CMTimeRange
    let videoTrackID: CMPersistentTrackID

    init(trackID: CMPersistentTrackID, timeRange: CMTimeRange) {
        self.timeRange = timeRange
        self.videoTrackID = trackID
        super.init()
    }
}
