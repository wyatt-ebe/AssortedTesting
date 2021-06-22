//
//  VolumeListener.swift
//  SystemTools
//
//  Created by Wyatt Eberspacher on 6/17/21.
//

import Foundation
import Combine
import MediaPlayer

public protocol VolumeListenerDelegate: AnyObject {
  func volumeChanged()
}

//Fun note: If spotify is running, and the account is paired with a separate playing device, Spotify seems to submit its own volume change request (applies volume change to all devices), which causes this to fire twice

/// Simple class that contains a volumeView that should be added to a viewController than wishes to use this feature. The delegate will respond to ALL volume change events so long as the VC is presented on screen.
public class VolumeListener {
  var cancellables = [AnyCancellable]()
  
  /// Replaces the default volume view that shows up when the colume changes.
  public let volumeView = MPVolumeView(frame: .zero)
  
  /// Responds to volume changes
  public weak var delegate: VolumeListenerDelegate?
  
  let initialVolume: Float
  
  // Sets up a Combine publisher that is listening to the volume change controller that is triggered by adding MPVolumeView to an active view.
  public init() {
    self.initialVolume = AVAudioSession.sharedInstance().outputVolume
    NotificationCenter.default
      .publisher(for: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"))
      .compactMap { $0.userInfo }
      .sink(receiveValue: { [weak self] (val) in
        guard let self = self else { return }
        
        // Only respond if the containing view is still presented on screen.
        guard self.volumeView.superview?.window != nil else { return }
        
        // Ensure this is not a continous input (press & hold), and that it is a user input.
        if self.isShutterInputAllowed,
           let reason = val["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String,
           reason == "ExplicitVolumeChange" {
          self.delegate?.volumeChanged()
        }
      
        // Reset access even if no action taken, to prevent press and hold toggling.
        self.blockAccess()
      })
      .store(in: &cancellables)
  }
  
  // Great to confirm no memory leaks
  deinit {
    print("deinit \(type(of: self))")
  }
  
  // Theoreticly, this resets the volume when it being "eaten" by the camera. However, the behavior starts to get weird the navigation stack is considered. For example, if the volume is raised after the view is used, then the view is returned to, the volume would be reset to whatever it was when the view FIRST loaded. Would replace the delgate call above.
  func resetVolume(_ action: @escaping () -> Void) {
    let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
      if slider?.value != self.initialVolume {
        slider?.value = self.initialVolume
        self.delegate?.volumeChanged()
      }
    }
  }
  
  var timerTenthSeconds: Int = 0 // block time in ms
  var timer: Timer?
  
  var isShutterInputAllowed: Bool {
    return timerTenthSeconds == 0
  }
  
  func blockAccess() {
    let blockTenthSeconds = 4
    timerTenthSeconds = blockTenthSeconds
    if timer == nil {
      timer = Timer.scheduledTimer(timeInterval: 0.1,
                                   target: self,
                                   selector: #selector(timerFire),
                                   userInfo: nil,
                                   repeats: true)
    }
  }
  
  @objc
  func timerFire() {
    guard timerTenthSeconds > 0 else { return }
    timerTenthSeconds -= 1
    if timerTenthSeconds == 0 {
      timer?.invalidate()
      timer = nil
    }
  }
}

