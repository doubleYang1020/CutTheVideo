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
let AudioType = AVMediaTypeAudio

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
        exit(1)
      }
      
      store.dispatch(Actions.ExportFinished(
        isCompelete: exportSession.status == .completed,
        error: exportSession.error
      ))
    }
    print("should be processing")
  }
  
  static func splitVideo(assets: [AVAsset], destinationFolder: URL) -> () {
    let timeScale: CMTimeScale = 600
    let cpuCount = ProcessInfo.processInfo.activeProcessorCount
    
    let semaphore = DispatchSemaphore(value: cpuCount - 1)
    let segmentCount = assets.reduce(0, { $0 + Int(ceil($1.duration.seconds)) })
    store.dispatch(Actions.WillExport(count: segmentCount))
    
    for asset in assets {
      let sectionId = assets.index(of: asset) ?? 0
      for i in 0..<Int(ceil(asset.duration.seconds)) {
        let outputURL = destinationFolder.appendingPathComponent( "\(sectionId)_\(i.leftPad(expectedLength: 2)).mov", isDirectory: false)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset1280x720) else { return () }
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.outputURL = outputURL
        let start = CMTime(seconds: Double(i), preferredTimescale: timeScale)
        let duration: CMTime
        if i == segmentCount - 1 {
          duration = CMTimeSubtract(asset.duration, CMTime(seconds: Double(i), preferredTimescale: timeScale))
        }
        else {
          duration = CMTime(seconds: Double(1), preferredTimescale:timeScale)
        }
        let timeRange = CMTimeRange(start: start, duration: duration)
        
        exportSession.timeRange = timeRange
        
        semaphore.wait()
        exportSession.exportAsynchronously(completionHandler: {
          print("\(store.state.processingCount) : \(i) -> \(exportSession.status == .completed)")
          semaphore.signal()
          DispatchQueue.main.async {
            store.dispatch(Actions.ExportCompelete(isSuccess: exportSession.status == .completed))
          }
        })
      }
    }
    
  }
  
  static func composite(assets: [AVAsset]) -> AVComposition {
    let hasAudioTrack = assets.reduce(false) { $0 || $1.tracks(withMediaType: AudioType).count > 0 }
    let composition = AVMutableComposition()
    var currentTimeStart = kCMTimeZero  // 每次写入的时间
    
    let mutableVideoTrack = composition.addMutableTrack(
      withMediaType: VideoType,
      preferredTrackID: kCMPersistentTrackID_Invalid
    ) // 空视频轨道
    let mutableAudioTrack: AVMutableCompositionTrack?
    if hasAudioTrack {
      mutableAudioTrack = composition.addMutableTrack(
        withMediaType: AudioType,
        preferredTrackID: kCMPersistentTrackID_Invalid
      )
    }
    else {
      mutableAudioTrack = .none
    }
    
    for asset in assets {
      let timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
      
      let sourceVideoTrack = asset.tracks(withMediaType: VideoType).first!
      try? mutableVideoTrack.insertTimeRange(timeRange, of: sourceVideoTrack, at: currentTimeStart)
      mutableVideoTrack.preferredTransform = sourceVideoTrack.preferredTransform
      
      if let sourceAudioTrack = asset.tracks(withMediaType: AudioType).first {
        try? mutableAudioTrack?.insertTimeRange(timeRange, of: sourceAudioTrack, at: currentTimeStart)
      }
      currentTimeStart = CMTimeAdd(currentTimeStart, asset.duration)
    }
    
    return composition
  }
  
}
