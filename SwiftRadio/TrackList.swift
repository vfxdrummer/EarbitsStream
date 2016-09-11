//
//  TrackList.swift
//  Swift Radio
//
//  Created by Timothy Brandt on 9/9/2016.
//

import UIKit

//*****************************************************************
// TrackList
//*****************************************************************

// Class inherits from NSObject so that you may easily add features
// i.e. Saving favorite stations to CoreData, etc

class TrackList: NSObject {
  
  var trackId            : Int
  var tracks             : [EarbitsTrack]
  var loading            : Bool
  
  override init() {
    self.trackId         = -1
    self.tracks          = []
    self.loading         = false
  }
  
  func currentTrack() -> EarbitsTrack? {
    if (self.trackId < self.tracks.count) {
      return self.tracks[self.trackId]
    } else {
      return nil
    }
  }
  
  func nextTrack() {
    if (self.loading) {return }
    if ((self.trackId + 2) > self.tracks.count) {
      loadNewEarbitsTrack()
    } else {
      self.trackId += 1
      TrackList.notifyTrackUpdated()
    }
  }
  
  func previousTrack() {
    if (self.trackId == 0) { return }
    self.trackId -= 1
    TrackList.notifyTrackUpdated()
  }
  
  func loadNewEarbitsTrack() {
    // Turn on network indicator in status bar
    self.loading = true
    
    // Get the Radio Stations
    EarbitsTrackDataManager.getEarbitsTrackDataWithSuccess() { (data) in
      let earbitsTrackJSON = JSON(data: data)
      let earbitsTrack = EarbitsTrack.parseJSON(earbitsTrackJSON)
      self.tracks.append(earbitsTrack)
      self.trackId = (self.tracks.count - 1)
      TrackList.notifyTrackUpdated()
      self.loading = false
    }
  }
  
  class func notifyTrackUpdated() {
    NSNotificationCenter.defaultCenter().postNotificationName(trackUpdatedNotificationKey, object: self)
  }
}
