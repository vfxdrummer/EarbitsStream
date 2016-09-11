//
//  DataManager.swift
//  Swift Radio
//
//  Created by Timothy Brandt 09/09/16.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import Alamofire
import UIKit

class EarbitsTrackDataManager {
  
  //*****************************************************************
  // Helper class to get either local or remote JSON
  //*****************************************************************
  
  class func getEarbitsTrackDataWithSuccess(success: ((metaData: NSData!) -> Void)) {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      if useLocalJSON {
        getEarbitsTrackDataFromFileWithSuccess() { data in
          success(metaData: data)
        }
      } else {
        loadDataFromURL(earbitsStreamURL) { data, error in
          if let urlData = data {
            success(metaData: urlData)
          }
        }
      }
    }
  }
  
  //*****************************************************************
  // Load local Earbits Track JSON Data
  //*****************************************************************
  
  class func getEarbitsTrackDataFromFileWithSuccess(success: (data: NSData) -> Void) {
    
    if let filePath = NSBundle.mainBundle().pathForResource("earbitsTrack", ofType:"json") {
      do {
        let data = try NSData(contentsOfFile:filePath,
                              options: NSDataReadingOptions.DataReadingUncached)
        success(data: data)
      } catch {
        fatalError()
      }
    } else {
      print("The local JSON file could not be found")
    }
  }
  
  //*****************************************************************
  // REUSABLE DATA/API CALL METHOD
  //*****************************************************************
  
  class func loadDataFromURL(url: String, completion:(data: NSData?, error: NSError?) -> Void) {
    
    Alamofire.request(.GET, url).validate().responseData { response in
      switch response.result {
      case .Success:
        if let data = response.result.value {
          completion(data: data, error: nil)
        }
      case .Failure(let error):
        completion(data: nil, error: error)
      }
    }
  }
}