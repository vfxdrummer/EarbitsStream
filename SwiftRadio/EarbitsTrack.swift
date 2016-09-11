//
//  EarbitsTrack.swift
//  Swift Radio
//
//  Created by Timothy Brandt on 9/9/2016.
//

import UIKit

//*****************************************************************
// EarbitsTrack
//*****************************************************************

// Class inherits from NSObject so that you may easily add features
// i.e. Saving favorite stations to CoreData, etc

class EarbitsTrack: NSObject {
  
  var trackId            : String
  var trackName          : String
  var trackStreamURL     : String
  var artist             : Artist
  var artworkLoaded      : Bool
  var isPlaying          : Bool
  
  init(trackId: String, trackName: String, trackStreamURL: String, artist: Artist) {
    self.trackId         = trackId
    self.trackName       = trackName
    self.trackStreamURL  = trackStreamURL
    self.artist          = artist
    self.artworkLoaded   = false
    self.isPlaying       = false
  }
  
  //*****************************************************************
  // MARK: - JSON Parsing into object
  //*****************************************************************
  
  class func parseJSON(earbitsTrackJSON: JSON) -> (EarbitsTrack) {
    
    let artist = Artist.parseJSON(earbitsTrackJSON["artist"])
    
    let trackId         = earbitsTrackJSON["track_id"].string ?? ""
    let trackName       = earbitsTrackJSON["name"].string ?? ""
    let trackStreamURL  = earbitsTrackJSON["media_file"].string ?? ""
    
    let track = EarbitsTrack(trackId: trackId, trackName: trackName, trackStreamURL: trackStreamURL, artist: artist)
    return track
  }
  
}
