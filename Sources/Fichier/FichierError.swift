//
//  FichierError.swift
//
//
//  Created by Tommi Kivimäki on 30.11.2019.
//

import Foundation

public extension Fichier {
  enum FichierError: Swift.Error {
    case failedToWriteFile
    case failedToCreateDirectory
    case directoryNotFound
    case failedToReadDirectory
  }
}
