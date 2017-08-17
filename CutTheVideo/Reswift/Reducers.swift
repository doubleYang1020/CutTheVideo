//
//  Reducers.swift
//  CutTheVideo
//
//  Created by Hiro Chin on 17/8/2017.
//  Copyright © 2017 huyangyang. All rights reserved.
//

import ReSwift


func reducer(action: Action, state: AppState?) -> AppState {
  guard var state = state else { return AppState() }
  
  switch action {
    
  case let action as Actions.AddUndoOperation:
    state.undoHistory.add(op: action.operation)
    
  case _ as Actions.PopUndoOperation:
//    state.currentOperation = state.undoHistory.undo()
    break
    
  default:
    break
    
  }
  
  return state
}
