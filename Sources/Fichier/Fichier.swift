//
//  Fichier.swift
//  Fichier = File
//
//  Created by Tommi Kivimäki on 30.11.2019.
//

import Foundation

final public class Fichier: NSObject {
  private let fileManager: FileManager
  
  public init(fileManager: FileManager = FileManager.default) {
    self.fileManager = fileManager
    super.init()
  }
  
  
  /// Creates a directory
  /// - Parameter url: URL to be created
  public func createDirectory(at url: URL) throws {
    do {
      try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    } catch {
      throw FichierError.failedToCreateDirectory
    }
  }
  
  
  /// Writes contents to a file
  /// - Parameter string: Content to be written
  /// - Parameter url: File URL
  public func write(content string: String, to url: URL) throws -> URL {
    do {
      // If the path does not exist let's create the sub-directories.
      let urlWithoutFileName = url.deletingLastPathComponent()
      if !directoryExists(at: urlWithoutFileName) {
        try fileManager.createDirectory(at: urlWithoutFileName, withIntermediateDirectories: true, attributes: nil)
      }
      try string.write(to: url, atomically: true, encoding: String.Encoding.utf8)
      return url
    } catch {
      throw FichierError.failedToWriteFile
    }
  }
  
  
  /// Convenience method to write content with specific title
  /// - Parameters:
  ///   - content: Content to be written
  ///   - titled: Title used to create a sub-directory for the `index.html`
  ///   - withScands: Uses ä, Ä, ö and Ö letters in file names if set to true
  ///   - destination: Destination URL
  public func write(_ content: String, titled: String, output destination: URL, withScands: Bool = false) throws -> URL {
    let name: String
    
    if withScands {
      name = titled
        .lowercased()
        .replacingOccurrences(of: " ", with: "-")
        .replacingOccurrences(of: "ä", with: "a")
        .replacingOccurrences(of: "Ä", with: "A")
        .replacingOccurrences(of: "ö", with: "o")
        .replacingOccurrences(of: "Ö", with: "O")
    } else {
      name = titled
        .lowercased()
        .replacingOccurrences(of: " ", with: "-")
    }
    
    
    let destinationURL = destination.appendingPathComponent(name).appendingPathComponent("index.html")
    
    return try write(content: content, to: destinationURL)
  }
  
  
  /// Reads content of a file
  /// - Parameter url: File URL to be read
  public func readFileContent(from url: URL) -> String? {
    guard let data = fileManager.contents(atPath: url.path) else { return nil }
    return String(data: data, encoding: .utf8)
  }
  
  
  /// Reads the contents of a directory
  /// - Parameter url: Directory URL to read
  /// - Returns: Array of URLs found from a directory
  public func readDirectory(from url: URL) throws -> [URL] {
    guard directoryExists(at: url) else {
      throw FichierError.directoryNotFound
    }
    do {
      let content = try fileManager.contentsOfDirectory(at: url,
                                                        includingPropertiesForKeys: [],
                                                        options: .skipsHiddenFiles)
      return content
    } catch {
      throw FichierError.failedToReadDirectory
    }
  }
  
  
  /// Return a current directory
  /// - Returns: The URL of a current directory
  public func getCurrentDirectory() -> URL {
    let current = fileManager.currentDirectoryPath
    return URL(fileURLWithPath: current, isDirectory: true)
  }
  
  
  /// Finds all the files in a directory and in any of its sub-directories. Recursive search without any limit for the amount of nested sub-directories.
  /// - Parameter urls: URLs that need to be searched
  /// - Parameter found: Found URLs
  public func getAllFiles(from urls: [URL], _ found: [URL] = []) throws -> [URL] {
    if let head = urls.first {
      var tail = Array(urls.dropFirst())
      var files: [URL] = []
      
      // Find the contents of the head
      do {
        let index = try readDirectory(from: head)
        // Perkaa indexistä file urlit ja folder urlit erikseen
        // Appendaa folder urlit tail:iin myöhemmin prosessoitavaksi
        // File urlit ovatkin suoraan tuloksia.
        
        index.forEach({ (url) in
          directoryExists(at: url) ? tail.append(url) : files.append(url)
        })
      } catch {
        throw FichierError.directoryNotFound
      }
    
      return try getAllFiles(from: tail, found + files)
    } else {
      return found
    }
  }
  
  
  #if os(macOS)
  /// Finds out if a directory exists
  /// - Parameter url: URL for the directory
  /// - Returns: Boolean value indicating if the directory exists
  private func directoryExists(at url: URL) -> Bool {
    var isDirectory: ObjCBool = false
    fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
    return isDirectory.boolValue
  }
  
  #elseif os(Linux)
  
  private func directoryExists(at url: URL) -> Bool {
    return directoryExistsLinux(url.path)
  }
  #endif
}
