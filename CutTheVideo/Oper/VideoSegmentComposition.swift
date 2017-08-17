//
//  VideoSegmentComposition.swift
//  xxx
//
//  Created by Hiro Chin on 14/8/2017.
//  Copyright © 2017 Thel. All rights reserved.
//

import AVFoundation


enum VideoError: Error {
  case blankSegment
  case emptyVideoTrack
}

let VideoType = AVMediaTypeVideo
let AudioType = AVMediaTypeVideo

struct VideoSegmentComposition {
  
  static func bar(source: URL, destination: URL, instruction: VideoSegmentSequnce) throws -> () {
    let composition = try! composite(source: source, instruction: instruction)
    export(asset: composition, destination: destination)
  }
  
  static func composite(source: URL, instruction: VideoSegmentSequnce) throws -> AVComposition {
    let asset = AVAsset(url: source)
    guard instruction.count > 0 else { throw VideoError.blankSegment }
    guard asset.tracks(withMediaType: VideoType).count > 0 else { throw VideoError.emptyVideoTrack }
    
    let composition = AVMutableComposition()
    var currentTimeStart = kCMTimeZero  // 每次写入的时间
    
    let mutableVideoTrack = composition.addMutableTrack(
      withMediaType: VideoType,
      preferredTrackID: kCMPersistentTrackID_Invalid
    ) // 空视频轨道
    var mutableAudioTrack: AVMutableCompositionTrack? = .none
    if asset.tracks(withMediaType: AudioType).count > 0 {
      mutableAudioTrack = composition.addMutableTrack(
        withMediaType: AudioType,
        preferredTrackID: kCMPersistentTrackID_Invalid
      )
    }
    
    let sourceVideoTrack = asset.tracks(withMediaType: VideoType).first!
    for ins in instruction {
      try? mutableVideoTrack.insertTimeRange(ins, of: sourceVideoTrack, at: currentTimeStart)
      currentTimeStart = CMTimeAdd(currentTimeStart, ins.duration)
    }
    mutableVideoTrack.preferredTransform = sourceVideoTrack.preferredTransform
    
    if let sourceAudioTrack = asset.tracks(withMediaType: AudioType).first {
      currentTimeStart = kCMTimeZero
      for ins in instruction {
        try? mutableAudioTrack?.insertTimeRange(ins, of: sourceAudioTrack, at: currentTimeStart)
        currentTimeStart = CMTimeAdd(currentTimeStart, ins.duration)
      }
    }
    
    return composition
  }
  
  static func export(asset: AVAsset, destination: URL) -> () {
    try? FileManager.default.removeItem(at: destination)
    let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
    
    exportSession.outputFileType = AVFileTypeMPEG4
    exportSession.outputURL = destination
    exportSession.shouldOptimizeForNetworkUse = true
    exportSession.exportAsynchronously {
      print("processing")
      if (exportSession.status == .failed) {
        print(exportSession.error!)
        print("failed: -> \(String(describing: exportSession.error?.localizedDescription))")
      }
      else {
        print("compsitied location: \(destination)")
      }
      if exportSession.status == .completed {
      }
      
      store.dispatch(Actions.ExportFinished(
        isCompelete: exportSession.status == .completed,
        error: exportSession.error
      ))
    }
    print("should be processing")
  }
  
}
