//
//  Artist.swift
//  Swift Radio
//
//  Created by Timothy Brandt on 9/9/2016.
//

import UIKit

//*****************************************************************
// Artist
//*****************************************************************

// Class inherits from NSObject so that you may easily add features
// i.e. Saving favorite stations to CoreData, etc

class Artist: NSObject {
  
  var artistName         : String
  var artistImageURL     : String
  var artworkImage       : UIImage?
  
  init(artistName: String, artistImageURL: String) {
    self.artistName      = artistName
    self.artistImageURL  = artistImageURL
    self.artworkImage    = nil
  }
  
  //*****************************************************************
  // MARK: - JSON Parsing into object
  //*****************************************************************
  
  class func parseJSON(artistJSON: JSON) -> (Artist) {
    let artistName      = artistJSON["name"].string ?? ""
    let artistImageURL  = artistJSON["feature_image"].string ?? ""
    
    let track = Artist(artistName: artistName, artistImageURL: artistImageURL)
    return track
  }
  
}
