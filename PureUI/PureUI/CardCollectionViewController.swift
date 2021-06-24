//
//  CardCollectionViewController.swift
//  PureUI
//
//  Created by Wyatt Eberspacher on 6/24/21.
//

import UIKit
import AVKit
import SystemExtensions

public struct Card {
  let title: String?
  let subtitle: String?
  let image: UIImage?
  let video: URL?
  
  public init(title: String?,
              subtitle: String?,
              image: UIImage?,
              video: URL?) {
    self.title = title
    self.subtitle = subtitle
    self.image = image
    self.video = video
  }
}

public protocol CardCollectionViewControllerDelegate: AnyObject {
  func didSelectNewCard(isFinalCard: Bool)
}

/// UI Template for a swipable card view.
///
/// Implements a UICollectionView and several UILabels to offer a re-useable view controller.
/// Structure: Title and Subtitle above each card. Large primay card on-screen that is centered, with next and previous cards available to the sides. Page dots below card.
/// Behavior:
/// - Resizes to screen size
/// - Responds to swipes and drags left and right to switch between visible cards. Responds to taps on previous and next card.
/// - Crossfades active title and subtitle for each card
/// - Autoplays videos from a URL if they are defined for that card. Overlays image with play button after first play
/// Surfaces:
/// - Selection actions, with knowledge of if that was the final card
/// - Direct selection of cards, for control via other UI elements (ex: proceed button)
public class CardCollectionViewController: UIViewController {
  
  public weak var delegate: CardCollectionViewControllerDelegate?
  
  // Collection data
  private var cards: [Card]
  private var cardReuseId: String
  private var textColor: UIColor
  
  // Default image size and aspect for phone XS screen size
  private let phoneXSWidth: CGFloat = 295
  private let phoneXSHeight: CGFloat = 400
  
  private let imageSpacing: CGFloat = 16
  private let horizontalInset: CGFloat = 40
  
  // Calculate required card width from screen size
  private lazy var imageWidth: CGFloat = {
    let screenWidth = UIScreen.main.bounds.width
    let itemWidth = screenWidth - 2 * horizontalInset
    return itemWidth
  }()
  
  // Resize card height to maintain aspect ratio of cards.
  private lazy var imageHeight: CGFloat = {
    return phoneXSHeight * (imageWidth / phoneXSWidth)
  }()
  
  // On iphone XS screen, 295 is the width required to fit. Use this against the base
  private lazy var imageWidthRatio: CGFloat = {
    return imageWidth / phoneXSWidth
  }()
  
  // Prevent un-neccesary actions by checking if card already selected
  private var previousSelectedPage: Int = 0
  
  // UI components
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = textColor
    return label
  }()
  
  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = textColor
    label.numberOfLines = 2
    label.textAlignment = .center
    return label
  }()
  
  private lazy var collectionView: UICollectionView = {
    let collection = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    collection.translatesAutoresizingMaskIntoConstraints = false
    collection.isScrollEnabled = true
    collection.showsHorizontalScrollIndicator = false
    collection.backgroundColor = .clear
    return collection
  }()
  
  private lazy var collectionLayout: UICollectionViewLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: imageWidth, height: imageHeight)
    layout.minimumInteritemSpacing = imageSpacing
    layout.sectionInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    return layout
  }()
  
  private lazy var pageDots: UIPageControl = {
    let page = UIPageControl()
    page.translatesAutoresizingMaskIntoConstraints = false
    page.pageIndicatorTintColor = .gray
    page.currentPageIndicatorTintColor = .systemRed
    return page
  }()
  
  public init(cards: [Card],
              reuseId: String,
              textColor: UIColor,
              titleFont: UIFont,
              subtitleFont: UIFont) {
    self.cards = cards
    self.cardReuseId = reuseId
    self.textColor = textColor
    super.init(nibName: nil, bundle: nil)
    self.titleLabel.font = titleFont
    self.subtitleLabel.font = subtitleFont
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    NSLayoutConstraint.activate([
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
      titleLabel.heightAnchor.constraint(equalToConstant: 30),
      
      subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44),
      subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -44),
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      subtitleLabel.heightAnchor.constraint(equalToConstant: 48),
    ])
    
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(CardCollectionItem.self, forCellWithReuseIdentifier: cardReuseId)
    view.addSubview(collectionView)
    NSLayoutConstraint.activate([
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
      
      // This works, suggesting the collection view does not inherit height from cells.
      collectionView.heightAnchor.constraint(equalToConstant: imageHeight),
    ])
    
    view.addSubview(pageDots)
    NSLayoutConstraint.activate([
      pageDots.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      pageDots.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 4),
      pageDots.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    
    // Load initial labels
    setLabelsForPage(0)
  }
  
  // Auto-play first video when the view appears.
  public override func viewDidAppear(_ animated: Bool) {
    let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CardCollectionItem
    cell?.playVideo()
  }
  
  // Stop all videos if the view disappears, to prevent audio overlap.
  public override func viewWillDisappear(_ animated: Bool) {
    for cell in collectionView.visibleCells{
      let item = cell as! CardCollectionItem
      item.stopVideo()
    }
  }
}

extension CardCollectionViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let cardCount = cards.count
    pageDots.numberOfPages = cardCount
    return cardCount
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cardReuseId, for: indexPath) as? CardCollectionItem else {
      return UICollectionViewCell()
    }
    let cardData = cards[indexPath.item]
    cell.setUp(data: cardData)
    return cell
  }
}

extension CardCollectionViewController: UICollectionViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    pageDots.currentPage = getCurrentPage(scrollView)
  }
  
  // Implements custom scroll/swipe behavior.
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    // Stop scrolling:
    targetContentOffset.pointee = scrollView.contentOffset
    
    // If swiping faster than a lower limit, interpret as a swipe.
    let horizontalVelocity = velocity.x
    let magnitudeThatTriggersSwipe: CGFloat = 0.5
    let targetPage: Int
    if horizontalVelocity > magnitudeThatTriggersSwipe {
      targetPage = previousSelectedPage + 1
    } else if horizontalVelocity < (-1 * magnitudeThatTriggersSwipe) {
      targetPage = previousSelectedPage - 1
    } else {
      targetPage = getCurrentPage(scrollView)
    }
    selectPage(targetPage)
  }
  
  // Start video on tap of play button
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionItem
    // Prevent re-start of video on secondary tap of card
    if !cell.isPlayingVideo {
      cell.playVideo()
    }
  }
  
  // If the active card has yet to play its video, autoplay it.
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    let index = IndexPath(row: previousSelectedPage, section: 0)
    if let cell = collectionView.cellForItem(at: index) as? CardCollectionItem,
       !cell.hasPlayedVideo {
      cell.playVideo()
    }
  }
}

// Functions for use with UICollectionViewDelegate, in particular scrolling
extension CardCollectionViewController {
  /// Use current contentOffset and frame width to know which card is currently "primary"
  private func getCurrentPage(_ scrollView: UIScrollView) -> Int {
    let ratio = (collectionView.contentOffset.x + horizontalInset) / collectionView.frame.width
    let rounded = ratio.rounded(.toNearestOrAwayFromZero)
    return Int(rounded)
  }
  
  /// User driven or programatic access point to select a page.
  private func selectPage(_ targetPage: Int) {
    // Ensure page target is within bounds
    let maxPage = cards.count - 1
    var newPage = max(targetPage, 0)
    newPage = min(newPage, maxPage)
    let newIndex = IndexPath(row: newPage, section: 0)
    
    // Handle videos, if they exist
    if newPage != previousSelectedPage {
      let oldIndex = IndexPath(row: previousSelectedPage, section: 0)
      if let oldCell = collectionView.cellForItem(at: oldIndex) as? CardCollectionItem {
        oldCell.stopVideo()
      }
      
      // Update UI and inform delegate
      setLabelsForPage(newPage)
      delegate?.didSelectNewCard(isFinalCard: newPage == maxPage)
    }
    
    // Select page
    previousSelectedPage = newPage
    
    // Scrolls new primary card to center of screen
    collectionLayout.collectionView?.selectItem(at: newIndex, animated: true, scrollPosition: .centeredHorizontally)
  }
  
  /// Updates title and subtitle for current page
  private func setLabelsForPage(_ page: Int) {
    let card = cards[page]
    if let title = card.title {
      transitionAttributed(label: titleLabel, text: title)
    }
    if let subtitle = card.subtitle {
      transitionAttributed(label: subtitleLabel, text: subtitle)
    }
  }
  
  // Fancy-schmancy cross fade effect!
  private func transitionAttributed(label: UILabel, text: String) {
    let attributedString = NSAttributedString(string: text,
                                              font: label.font,
                                              color: label.textColor,
                                              lineSpacing: 6,
                                              alignment: .center)
    UIView.transition(with: label,
                      duration: 0.2,
                      options: .transitionCrossDissolve,
                      animations: {
                        label.attributedText = attributedString
                      },
                      completion: nil)
  }
}

// Extension to contain public facing functions of the CardCollectionViewController
extension CardCollectionViewController {
  /// As titled, selects the next page if it exists
  public func selectNextCard() {
    let targetPage = previousSelectedPage + 1
    selectPage(targetPage)
  }
}

// Individual item in the collection view. Has an image, optional video url, and a play button to overlay
class CardCollectionItem: UICollectionViewCell {
  
  private var videoUrl: URL?
  
  // Prevent restarts of video on tap while video is already playing
  internal var isPlayingVideo: Bool = false
  
  // Determine if the video should autoplay, or if we show the image plus the play button overlay.
  internal var hasPlayedVideo: Bool = false
  
  // UI Components
  
  // GradientView helps with setting the UI up before assets are ready to go. Also serves to clip the contained assets neatly.
  private lazy var imageContainerView: GradientView = {
    let view = GradientView(topColor: UIColor(red: 0.84, green: 0.86, blue: 0.87, alpha: 1.0),
                            bottomColor: UIColor(red: 0.73, green: 0.76, blue: 0.77, alpha: 1.0))
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 24
    view.clipsToBounds = true
    return view
  }()
  
  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  private lazy var videoPlayerLayer: AVPlayerLayer = {
    let playerLayer = AVPlayerLayer()
    playerLayer.isHidden = true
    playerLayer.videoGravity = .resizeAspectFill
    return playerLayer
  }()
  
  private lazy var playIconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = UIImage(systemName: "play.circle.fill")?.withRenderingMode(.alwaysTemplate)
    imageView.tintColor = .gray
    imageView.isHidden = true
    return imageView
  }()
  
  // Specific card details not required at time of init.
  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
    contentView.addSubview(imageContainerView)
    imageContainerView.addSubview(imageView)
    imageContainerView.layer.addSublayer(videoPlayerLayer)
    imageContainerView.addSubview(playIconImageView)
    NSLayoutConstraint.activate([
      imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
      imageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      
      imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
      
      playIconImageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
      playIconImageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
      playIconImageView.widthAnchor.constraint(equalToConstant: 64),
      playIconImageView.heightAnchor.constraint(equalToConstant: 64),
    ])
  }
  
  /// Digest a Card into an item for the collectionView
  internal func setUp(data: Card) {
    imageView.image = data.image
    videoUrl = data.video
    if videoUrl != nil {
      playIconImageView.isHidden = false
    }
  }
  
  /// Create a new AVPlayer, assign it to the layer, then show and play the video.
  internal func playVideo() {
    guard let url = videoUrl else { return }
    videoPlayerLayer.player = AVPlayer(url: url)
    videoPlayerLayer.frame = imageContainerView.bounds
    videoPlayerLayer.isHidden = false
    playIconImageView.isHidden = true
    videoPlayerLayer.player?.play()
    isPlayingVideo = true
    hasPlayedVideo = true
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handleVideoDidFinishPlaying),
                                           name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                           object: videoPlayerLayer.player?.currentItem)
  }
  
  /// Reverse the process of playVideo() to stop the video and show the image w/ play button overaly. An artifical stop, that is the video did not play to the end.
  internal func stopVideo() {
    guard videoUrl != nil else { return }
    videoPlayerLayer.isHidden = true
    playIconImageView.isHidden = false
    videoPlayerLayer.player?.pause()
    isPlayingVideo = false
    NotificationCenter.default.removeObserver(self)
  }
  
  /// When a video completes naturally, leave it on its last frame, but show the play button overlay.
  @objc
  private func handleVideoDidFinishPlaying() {
    playIconImageView.isHidden = false
    isPlayingVideo = false
    NotificationCenter.default.removeObserver(self)
  }
  
  override var isHighlighted: Bool {
    didSet {
      playIconImageView.alpha = isHighlighted ? 0.7 : 1
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
