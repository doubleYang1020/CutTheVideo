//
//  Actions.swift
//  CutTheVideo
//
//  Created by Hiro Chin on 17/8/2017.
//  Copyright © 2017 huyangyang. All rights reserved.
//

import ReSwift


struct Actions {
  
  struct AddUndoOperation: Action {
    let operation: UndoHistory.Operation
  }
  
  struct PopUndoOperation: Action {}
  
  struct ExportFinished: Action {
    let isCompelete: Bool
    let error: Error?
  }
  
  struct WillExport: Action {
    let count: Int
  }
  
  struct ExportCompelete: Action {
    let isSuccess: Bool
  }
}
