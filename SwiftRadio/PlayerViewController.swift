//
//  PlayerViewController.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/22/15.
//

import UIKit
import MediaPlayer

//*****************************************************************
// Protocol
// Updates the StationsViewController when the track changes
//*****************************************************************

protocol PlayerViewControllerDelegate: class {
  func artworkDidUpdate(track: EarbitsTrack)
  func trackPlayingToggled(track: EarbitsTrack)
}

//*****************************************************************
// PlayerViewController
//*****************************************************************

class PlayerViewController: UIViewController {
  
  @IBOutlet weak var albumHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var albumImageView: SpringImageView!
  
  
  @IBOutlet weak var backgroundImage: UIImageView!
  @IBOutlet weak var artistLabel: UILabel!
  @IBOutlet weak var previousButton: UIButton!
  @IBOutlet weak var pauseButton: UIButton!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var songLabel: SpringLabel!
  @IBOutlet weak var stationDescLabel: UILabel!
  @IBOutlet weak var volumeParentView: UIView!
  @IBOutlet weak var slider = UISlider()
  
  var trackList:    TrackList!
  var earbitsTrack: EarbitsTrack?
  var downloadTask: NSURLSessionDownloadTask?
  var iPhone4 = false
  var justBecameActive = false
  var newStation = true
  var nowPlayingImageView: UIImageView!
  let radioPlayer = Player.radio
  var mpVolumeSlider = UISlider()
  
  weak var delegate: PlayerViewControllerDelegate?
  
  //*****************************************************************
  // MARK: - ViewDidLoad
  //*****************************************************************
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup handoff functionality - GH
    setupUserActivity()
    
    // Set AlbumArtwork Constraints
    optimizeForDeviceSize()
    
    self.trackList = TrackList()
    self.earbitsTrack = nil;
    self.trackList.nextTrack()
    
    // Set View Title
    self.title = "Earbits Stream"
    
    // Create Now Playing BarItem
    createNowPlayingAnimation()
    
    // Setup MPMoviePlayerController
    // If you're building an app for a client, you may want to
    // replace the MediaPlayer player with a more robust
    // streaming library/SDK. Preferably one that supports interruptions, etc.
    // Most of the good streaming libaries are in Obj-C, however they
    // will work nicely with this Swift code. There is a branch using RadioKit if
    // you need an example of how nicely this code integrates with libraries.
    setupPlayer()
    
    // Notification for when app becomes active
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(PlayerViewController.didBecomeActiveNotificationReceived),
                                                     name: "UIApplicationDidBecomeActiveNotification",
                                                     object: nil)
    
    // Notification for AVAudioSession Interruption (e.g. Phone call)
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(PlayerViewController.sessionInterrupted(_:)),
                                                     name: AVAudioSessionInterruptionNotification,
                                                     object: AVAudioSession.sharedInstance())
    
    // Notification for track updated
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(trackDidChange),
                                                     name: trackUpdatedNotificationKey,
                                                     object: nil)
    
    // Setup slider
    setupVolumeSlider()
    
    self.view.sendSubviewToBack(backgroundImage)
  }
  
  func didBecomeActiveNotificationReceived() {
    // View became active
    updateLabels()
    justBecameActive = true
    updateAlbumArtwork()
  }
  
  deinit {
    // Be a good citizen
    NSNotificationCenter.defaultCenter().removeObserver(self,
                                                        name:"UIApplicationDidBecomeActiveNotification",
                                                        object: nil)
    
    NSNotificationCenter.defaultCenter().removeObserver(self,
                                                        name: AVAudioSessionInterruptionNotification,
                                                        object: AVAudioSession.sharedInstance())
  }
  
  //*****************************************************************
  // MARK: - Setup
  //*****************************************************************
  
  func setupPlayer() {
    radioPlayer.view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    radioPlayer.view.sizeToFit()
    radioPlayer.movieSourceType = MPMovieSourceType.Streaming
    radioPlayer.fullscreen = false
    radioPlayer.shouldAutoplay = true
    radioPlayer.prepareToPlay()
    radioPlayer.controlStyle = MPMovieControlStyle.None
  }
  
  func setupVolumeSlider() {
    // Note: This slider implementation uses a MPVolumeView
    // The volume slider only works in devices, not the simulator.
    volumeParentView.backgroundColor = UIColor.clearColor()
    let volumeView = MPVolumeView(frame: volumeParentView.bounds)
    for view in volumeView.subviews {
      let uiview: UIView = view as UIView
      if (uiview.description as NSString).rangeOfString("MPVolumeSlider").location != NSNotFound {
        mpVolumeSlider = (uiview as! UISlider)
      }
    }
    
    let thumbImageNormal = UIImage(named: "slider-ball")
    slider?.setThumbImage(thumbImageNormal, forState: .Normal)
    
  }
  
  func trackDidChange() {
    earbitsTrack = trackList.currentTrack()
    if (earbitsTrack == nil) { return}
    radioPlayer.stop()
    
    radioPlayer.contentURL = NSURL(string: earbitsTrack!.trackStreamURL)
    radioPlayer.prepareToPlay()
    radioPlayer.play()
    
    updateLabels()
    
    // songLabel animate
    songLabel.animation = "flash"
    songLabel.repeatCount = 3
    songLabel.animate()
    
    resetAlbumArtwork()
    
    playPressed()
    earbitsTrack!.isPlaying = true
  }
  
  //*****************************************************************
  // MARK: - Player Controls (Play/Pause/Volume)
  //*****************************************************************
  
  
  @IBAction func previousPressed(sender: AnyObject) {
    self.trackList.previousTrack()
  }
  
  @IBAction func playPressed() {
    earbitsTrack!.isPlaying = true
    playButtonEnable(false)
    radioPlayer.play()
    updateLabels()
    
    // songLabel Animation
    songLabel.animation = "flash"
    songLabel.animate()
    
    // Start NowPlaying Animation
    nowPlayingImageView.startAnimating()
    
    // Update StationsVC
    self.delegate?.trackPlayingToggled(self.earbitsTrack!)
  }
  
  @IBAction func pausePressed() {
    earbitsTrack!.isPlaying = false
    
    playButtonEnable()
    
    radioPlayer.pause()
    updateLabels("Station Paused...")
    nowPlayingImageView.stopAnimating()
    
    // Update StationsVC
    self.delegate?.trackPlayingToggled(self.earbitsTrack!)
  }
  
  @IBAction func nextPressed(sender: AnyObject) {
    self.trackList.nextTrack()
  }
  
  @IBAction func volumeChanged(sender:UISlider) {
    mpVolumeSlider.value = sender.value
  }
  
  //*****************************************************************
  // MARK: - UI Helper Methods
  //*****************************************************************
  
  func optimizeForDeviceSize() {
    
    // Adjust album size to fit iPhone 4s, 6s & 6s+
    let deviceHeight = self.view.bounds.height
    
    if deviceHeight == 480 {
      iPhone4 = true
      albumHeightConstraint.constant = 106
      view.updateConstraints()
    } else if deviceHeight == 667 {
      albumHeightConstraint.constant = 230
      view.updateConstraints()
    } else if deviceHeight > 667 {
      albumHeightConstraint.constant = 260
      view.updateConstraints()
    }
  }
  
  func updateLabels(statusMessage: String = "") {
    
    if statusMessage != "" {
      // There's a an interruption or pause in the audio queue
      songLabel.text = statusMessage
      artistLabel.text = ""
      
    } else {
      // Radio is (hopefully) streaming properly
      if (self.earbitsTrack != nil) {
        songLabel.text = earbitsTrack!.trackName
        artistLabel.text = earbitsTrack!.artist.artistName
      }
    }
    
    // Hide station description when album art is displayed or on iPhone 4
    if earbitsTrack!.artworkLoaded || iPhone4 {
      stationDescLabel.hidden = true
    } else {
      stationDescLabel.hidden = false
    }
  }
  
  func playButtonEnable(enabled: Bool = true) {
    if enabled {
      previousButton.enabled = true
      playButton.enabled = true
      pauseButton.enabled = false
      nextButton.enabled = true
      earbitsTrack!.isPlaying = false
    } else {
      previousButton.enabled = true
      playButton.enabled = false
      pauseButton.enabled = true
      nextButton.enabled = true
      earbitsTrack!.isPlaying = true
    }
  }
  
  func createNowPlayingAnimation() {
    
    // Setup ImageView
    nowPlayingImageView = UIImageView(image: UIImage(named: "NowPlayingBars-3"))
    nowPlayingImageView.autoresizingMask = UIViewAutoresizing.None
    nowPlayingImageView.contentMode = UIViewContentMode.Center
    
    // Create Animation
    nowPlayingImageView.animationImages = AnimationFrames.createFrames()
    nowPlayingImageView.animationDuration = 0.7
    
    // Create Top BarButton
    let barButton = UIButton(type: UIButtonType.Custom)
    barButton.frame = CGRectMake(0, 0, 40, 40);
    barButton.addSubview(nowPlayingImageView)
    nowPlayingImageView.center = barButton.center
    
    let barItem = UIBarButtonItem(customView: barButton)
    self.navigationItem.rightBarButtonItem = barItem
    
  }
  
  func startNowPlayingAnimation() {
    nowPlayingImageView.startAnimating()
  }
  
  //*****************************************************************
  // MARK: - Album Art
  //*****************************************************************
  
  func resetAlbumArtwork() {
    earbitsTrack!.artworkLoaded = false
    updateAlbumArtwork()
    stationDescLabel.hidden = false
  }
  
  func updateAlbumArtwork() {
    earbitsTrack!.artworkLoaded = false
    if earbitsTrack!.artist.artistImageURL.rangeOfString("http") != nil {
      
      // Hide station description
      dispatch_async(dispatch_get_main_queue()) {
        self.albumImageView.image = nil
        self.stationDescLabel.hidden = false
      }
      
      // Attempt to download album art from an API
      if let url = NSURL(string: earbitsTrack!.artist.artistImageURL) {
        
        self.downloadTask = self.albumImageView.loadImageWithURL(url) { (image) in
          
          // Update track struct
          self.earbitsTrack!.artist.artworkImage = image
          self.earbitsTrack!.artworkLoaded = true
          
          // Turn off network activity indicator
          UIApplication.sharedApplication().networkActivityIndicatorVisible = false
          
          // Animate artwork
          self.albumImageView.animation = "wobble"
          self.albumImageView.duration = 2
          self.albumImageView.animate()
          self.stationDescLabel.hidden = true
          
          // Update lockscreen
          self.updateLockScreen()
          
          // Call delegate function that artwork updated
          self.delegate?.artworkDidUpdate(self.earbitsTrack!)
        }
      }
      
      // Hide the station description to make room for album art
      if earbitsTrack!.artworkLoaded && !self.justBecameActive {
        self.stationDescLabel.hidden = true
        self.justBecameActive = false
      }
      
    } else if earbitsTrack!.artist.artistImageURL != "" {
      // Local artwork
      self.albumImageView.image = UIImage(named: earbitsTrack!.artist.artistImageURL)
      self.earbitsTrack!.artist.artworkImage = albumImageView.image
      earbitsTrack!.artworkLoaded = true
      
      // Call delegate function that artwork updated
      self.delegate?.artworkDidUpdate(self.earbitsTrack!)
      
    } else {
      // No Station or API art found, use default art
      self.albumImageView.image = UIImage(named: "albumArt")
      self.earbitsTrack!.artist.artworkImage = albumImageView.image
    }
    
    // Force app to update display
    self.view.setNeedsDisplay()
  }
  
  //*****************************************************************
  // MARK: - MPNowPlayingInfoCenter (Lock screen)
  //*****************************************************************
  
  func updateLockScreen() {
    // Update notification/lock screen
    let albumArtwork = MPMediaItemArtwork(image: self.earbitsTrack!.artist.artworkImage!)
    
    MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
      MPMediaItemPropertyArtist: earbitsTrack!.artist.artistName,
      MPMediaItemPropertyTitle: earbitsTrack!.trackName,
      MPMediaItemPropertyArtwork: albumArtwork
    ]
  }
  
  override func remoteControlReceivedWithEvent(receivedEvent: UIEvent?) {
    super.remoteControlReceivedWithEvent(receivedEvent)
    
    if receivedEvent!.type == UIEventType.RemoteControl {
      
      switch receivedEvent!.subtype {
      case .RemoteControlPlay:
        playPressed()
      case .RemoteControlPause:
        pausePressed()
      default:
        break
      }
    }
  }
  //*****************************************************************
  // MARK: - AVAudio Sesssion Interrupted
  //*****************************************************************
  
  // Example code on handling AVAudio interruptions (e.g. Phone calls)
  func sessionInterrupted(notification: NSNotification) {
    if let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber{
      if let type = AVAudioSessionInterruptionType(rawValue: typeValue.unsignedLongValue){
        if type == .Began {
          print("interruption: began")
          // Add your code here
        } else{
          print("interruption: ended")
          // Add your code here
        }
      }
    }
  }
  
  //*****************************************************************
  // MARK: - Handoff Functionality - GH
  //*****************************************************************
  
  func setupUserActivity() {
    let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb ) //"com.graemeharrison.handoff.googlesearch" //NSUserActivityTypeBrowsingWeb
    userActivity = activity
    let url = "https://www.google.com/search?q=\(self.artistLabel.text!)+\(self.songLabel.text!)"
    let urlStr = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    let searchURL : NSURL = NSURL(string: urlStr!)!
    activity.webpageURL = searchURL
    userActivity?.becomeCurrent()
  }
  
  override func updateUserActivityState(activity: NSUserActivity) {
    let url = "https://www.google.com/search?q=\(self.artistLabel.text!)+\(self.songLabel.text!)"
    let urlStr = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    let searchURL : NSURL = NSURL(string: urlStr!)!
    activity.webpageURL = searchURL
    super.updateUserActivityState(activity)
  }
}
