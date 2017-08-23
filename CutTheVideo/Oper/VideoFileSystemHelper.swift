//
//  VideoFileSystemHelper.swift
//  Five-New
//
//  Created by Chen Hao on 27/12/2016.
//  Copyright © 2016 Thel. All rights reserved.
//

import Foundation

struct VideoFileSystemHelper {
  
  static func shareFolder(withPath: String? = .none) -> URL {
    guard let folderPath = NSSearchPathForDirectoriesInDomains(
      FileManager.SearchPathDirectory.documentDirectory,
      FileManager.SearchPathDomainMask.userDomainMask,
      true
      ).first
      else { fatalError("can not get temp folder loation") }
    
    if let path = withPath {
      return URL(fileURLWithPath: folderPath).appendingPathComponent(path)
    }
    return URL(fileURLWithPath: folderPath)
  }
  
  static func createTempFolder() -> URL {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    dateFormatter.dateFormat = "YYYY-MM-dd_HH-mm-ss_ms"
    
    let folderName = dateFormatter.string(from: Date())
    let fullURL = shareFolder(withPath: "mov_\(folderName)")
    
    do {
      try FileManager.default.createDirectory(
        at: fullURL,
        withIntermediateDirectories: false,
        attributes: .none
      )
    }
    catch {
      fatalError(error.localizedDescription)
    }
    
    log.verbose("folder path: \(fullURL)")
    
    return fullURL
  }
  
  static func removeTempFolder(tempFolderURL: URL) -> () {
    do {
      try FileManager.default.removeItem(at: tempFolderURL)
    }
    catch {
      fatalError(error.localizedDescription)
    }
  }
  
  static func removeAllTempFolders() -> () {
    _ = VideoFileSystemHelper
      .listFolder(folderURL: shareFolder(), allFiles: true)
      .filter({ $0.lastPathComponent.hasPrefix("mov_") })
      .map({ removeTempFolder(tempFolderURL: $0) })
  }
  
  static func listFolder(folderURL: URL, allFiles: Bool = false, fileExtension: String = "mov") -> [URL] {
    do {
      let files = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: .none, options: [])
      if allFiles {
        return files
      }
      return files.filter { $0.pathExtension == fileExtension }
    } catch {
      fatalError(error.localizedDescription)
    }
  }
  
}
