//
//  VideoConfiguration.swift
//  xxx
//
//  Created by Hiro Chin on 14/8/2017.
//  Copyright © 2017 Thel. All rights reserved.
//

import AVFoundation
import CoreMedia
import Foundation

extension CMTimeRange {
  
  init(start: Int64, duration: Int64) {
    let s = CMTimeMake(start, 1)
    let d: CMTime
    if duration < 0 {
      d = CMTime(value: 0, timescale: 0, flags: CMTimeFlags.positiveInfinity, epoch: 0)
    }
    else {
      d = CMTimeMake(duration, 1)
    }
    self.init(start: s, duration: d)
  }
  
  func executionPlan(player: AVPlayer) -> () {
    player.seek(to: self.start)
    player.play()
    guard duration.flags != .positiveInfinity else { return () }
    usleep(UInt32(duration.seconds * 1_000_000))
  }
  
}


typealias VoidClosure = () -> ()
typealias VideoSegment = CMTimeRange
typealias VideoSegmentSequnce = Array<CMTimeRange>
