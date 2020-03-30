import XCTest
@testable import Fichier

final class FichierTests: XCTestCase {
  
  var files: Fichier!
  

  override func setUp() {
    files = Fichier()
  }
  
  override func tearDown() {
    files = nil
  }
  
  
  func testGetDocumentsDirectory() {
    let directory = Fichier.getDocumentsDirectory()
    XCTAssertEqual(directory.lastPathComponent, "Documents")
  }
  
  static var allTests = [
    ("testGetDocumentsDirectory", testGetDocumentsDirectory),
  ]
}
