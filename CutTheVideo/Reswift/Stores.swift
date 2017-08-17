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
}
