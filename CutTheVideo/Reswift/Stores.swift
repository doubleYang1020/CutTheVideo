//
//  Stores.swift
//  CutTheVideo
//
//  Created by Hiro Chin on 17/8/2017.
//  Copyright © 2017 huyangyang. All rights reserved.
//

import ReSwift


struct AppState: StateType {
  var undoHistory = UndoHistory()
  var videoSegmentSequence: [VideoSegment] = []
  var processingCount: Int = -1
}

extension Integer {
  func leftPad(expectedLength: Int) -> String {
    guard expectedLength > 1 else { return self.description }
    let natureLength = self.description.characters.count
    let padLength = expectedLength - natureLength
    if padLength > 0 {
      let x = (0..<padLength).reduce("", { $0.0 + "0" })
      return x + self.description
    }
    return self.description
  }
  
}
