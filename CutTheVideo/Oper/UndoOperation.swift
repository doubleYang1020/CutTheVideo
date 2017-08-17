//
//  UndoOperation.swift
//  Five-New
//
//  Created by Hiro Chin on 14/8/2017.
//  Copyright © 2017 Thel. All rights reserved.
//

import Foundation

struct UndoHistory {
  enum Operation {
    case Cut(indexPath: IndexPath)
    case Hide(indexPath: IndexPath)
    case Show(indexPath: IndexPath)
    case Rearrange(from: IndexPath, to: IndexPath)
    case Delete(indexPath: IndexPath, data: Any)
  }
  
  private var stack: Array<Operation> = []
  
  mutating func add(op: Operation) -> () {
    print("add -> op: \(op)")
    stack.append(op)
  }
  
  mutating func undo() -> Operation? {
    guard stack.count > 0 else { return .none }
    return stack.removeLast()
  }
  
  mutating func clear() -> () {
    stack.removeAll()
  }
}

extension UndoHistory.Operation: Equatable {}

func ==(lhs: UndoHistory.Operation, rhs: UndoHistory.Operation) -> Bool {
  return lhs == rhs
}
