//
//  EarbitsTrackTests.swift
//  EarbitsTrackTests
//
//  Created by Tim Brandt on 9/9/16.
//  Copyright © 2016 matthewfecher.com. All rights reserved.
//

import XCTest

class EarbitsTrackTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testEarbitsTrackJSON() {
    // Get the Earbits Tracks
    EarbitsTrackDataManager.getEarbitsTrackDataFromFileWithSuccess() { (data) in
      let earbitsTrackJSON = JSON(data: data)
      
      XCTAssertEqual(earbitsTrackJSON["id"].string, "4f5431431d480502ec00562f")
      XCTAssertEqual(earbitsTrackJSON["name"].string, "Is There Still Time")
      XCTAssertEqual(earbitsTrackJSON["media_file"].string, "http://media-http-prod-0.earbits.com/4ee43cc8734463bb637621e89ce0820c.mp3")
      XCTAssertEqual(earbitsTrackJSON["artist_name"].string, "Sherry Lynn")
      XCTAssertEqual(earbitsTrackJSON["feature_image"].string, "http://cdn-1.earbits.com/images/52607e78b93af7000200024e/1382055544/main/Sherry_Lynn_Promo_Pic_09.jpeg?1382055544")
      
      let earbitsTrack = EarbitsTrack.parseJSON(earbitsTrackJSON)
      
      XCTAssertEqual(earbitsTrack.trackId, "4f5431431d480502ec00562f")
      XCTAssertEqual(earbitsTrack.trackName, "Is There Still Time")
      XCTAssertEqual(earbitsTrack.trackStreamURL, "http://media-http-prod-0.earbits.com/4ee43cc8734463bb637621e89ce0820c.mp3")
      XCTAssertEqual(earbitsTrack.artist.artistName, "Sherry Lynn")
      XCTAssertEqual(earbitsTrack.artist.artistImageURL, "http://cdn-1.earbits.com/images/52607e78b93af7000200024e/1382055544/main/Sherry_Lynn_Promo_Pic_09.jpeg?1382055544")
    }
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock {
      // Put the code you want to measure the time of here.
    }
  }
  
}
