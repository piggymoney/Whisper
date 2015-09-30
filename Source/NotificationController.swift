import UIKit
import Cartography
import Sugar

public protocol NotificationControllerDelegate: class {
  func notificationControllerWillHide()
}

public class NotificationController: UIViewController {

  struct Dimensions {
    static let width: CGFloat = UIScreen.mainScreen().bounds.width
    static let height: CGFloat = 24
    static let offsetHeight: CGFloat = height * 2
    static let loaderSize: CGFloat = 13
    static let loaderTitleOffset: CGFloat = 5
    static let imageSize: CGFloat = 15
  }

  struct AnimationTiming {
    static let movement: NSTimeInterval = 0.3
    static let switcher: NSTimeInterval = 0.1
    static let popUp: NSTimeInterval = 1.5
    static let loaderDuration: NSTimeInterval = 0.7
    static let totalDelay: NSTimeInterval = popUp + movement * 2
  }

  public struct BaseColors {
    public static let neutral = "C8CBD1"
    public static let error = "FA2F5B"
    public static let warning = "FFCA00"
    public static let positive = "20D6B8"
  }

  lazy private(set) var transformViews: [UIView] = { [unowned self] in
    let views = [self.titleLabel, self.customLoader, self.complementImageView]
    return views
    }()

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .Center
    label.textColor = ColorList.NotificationController.title
    label.font = FontList.NotificationController.title

    return label
    }()

  lazy var customLoader: UIImageView = { [unowned self] in
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill
    imageView.animationImages = self.loaderImages
    imageView.animationDuration = AnimationTiming.loaderDuration

    return imageView
    }()

  lazy var complementImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill

    return imageView
    }()

  public weak var delegate: NotificationControllerDelegate?
  public var height: CGFloat

  var kind: Notification.Kind?
  var showTimer = NSTimer()
  var generalConstraints = ConstraintGroup()

  let loaderImages: [UIImage] = [
    UIImage(named: ImageList.Whisper.loading1)!,
    UIImage(named: ImageList.Whisper.loading2)!,
    UIImage(named: ImageList.Whisper.loading3)!,
    UIImage(named: ImageList.Whisper.loading4)!,
    UIImage(named: ImageList.Whisper.loading5)!,
    UIImage(named: ImageList.Whisper.loading6)!,
    UIImage(named: ImageList.Whisper.loading7)!,
    UIImage(named: ImageList.Whisper.loading8)!,
    UIImage(named: ImageList.Whisper.loading9)!,
    UIImage(named: ImageList.Whisper.loading10)!,
    UIImage(named: ImageList.Whisper.loading11)!,
    UIImage(named: ImageList.Whisper.loading12)!
  ]

  // MARK: - Initializers

  public init(height: CGFloat) {
    self.height = height
    super.init(nibName: nil, bundle: nil)

    view.frame = CGRectMake(0, 0, Dimensions.width, 0)

    for subview in transformViews { view.addSubview(subview) }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Timer Methods

  func delayFired(timer: NSTimer) {
    delegate?.notificationControllerWillHide()
    removeView()
  }
}

// MARK: - Present Methods

extension NotificationController {

  private func showView() {
    view.frame = CGRectMake(0, height, Dimensions.width, 0)
    for transformView in transformViews { transformView.transform = CGAffineTransformMakeScale(0.1, 0.1) }
    UIView.animateWithDuration(AnimationTiming.movement, animations: { [unowned self] in
      self.view.frame = CGRectMake(0, self.height, Dimensions.width, Dimensions.height)
      for transformView in self.transformViews { transformView.transform = CGAffineTransformIdentity }
      }, completion: { _ in
        self.showTimer = NSTimer.scheduledTimerWithTimeInterval(AnimationTiming.popUp,
          target: self,
          selector: "delayFired:",
          userInfo: nil,
          repeats: false)
    })
  }

  private func presentView() {
    view.frame = CGRectMake(0, height, Dimensions.width, 0)
    for transformView in transformViews { transformView.transform = CGAffineTransformMakeScale(0.1, 0.1) }
    UIView.animateWithDuration(AnimationTiming.movement, animations: { [unowned self] in
      self.view.frame = CGRectMake(0, self.height, Dimensions.width, Dimensions.height)
      for transformView in self.transformViews { transformView.transform = CGAffineTransformIdentity }
      })
  }

  private func changeView(notification: Notification) {
    UIView.animateWithDuration(AnimationTiming.switcher, animations: { [unowned self] in
      for transformView in self.transformViews { transformView.transform = CGAffineTransformMakeScale(0.1, 0.1) }
      }, completion: { _ in
        self.setupViews(notification)
        for transformView in self.transformViews { transformView.transform = CGAffineTransformMakeScale(0.1, 0.1) }
        UIView.animateWithDuration(AnimationTiming.switcher, animations: { _ in
          for transformView in self.transformViews { transformView.transform = CGAffineTransformIdentity }
        })
    })
  }

  private func removeView() {
    UIView.animateWithDuration(AnimationTiming.movement, animations: { [unowned self] in
      for transformView in self.transformViews { transformView.alpha = 0 }
      for transformView in self.transformViews { transformView.transform = CGAffineTransformScale(
        CGAffineTransformMakeTranslation(0, -7.5), 0.01, 0.01) }
      self.view.frame = CGRectMake(0, self.height, Dimensions.width, 0)
      }, completion: { _ in
        self.removeFromParentViewController()
        self.view.alpha = 0
    })
  }

  private func setupViews(notification: Notification) {
    titleLabel.text = notification.title
    complementImageView.image = notification.image
    view.backgroundColor = notification.color
    kind = notification.kind

    titleLabel.sizeToFit()
    customLoader.startAnimating()
    showTimer.invalidate()
    for transformView in transformViews { transformView.transform = CGAffineTransformIdentity }
    setupConstraints()
  }
}

// MARK: - Whisperable

extension NotificationController: Whisperable {

  public func present(notification: Notification) {
    setupViews(notification)
    view.alpha = 1
    for transformView in transformViews { transformView.alpha = 1 }
    presentView()
  }

  public func show(notification: Notification) {
    setupViews(notification)
    view.alpha = 1
    for transformView in transformViews { transformView.alpha = 1 }
    showView()
  }

  public func change(notification: Notification) {
    if titleLabel.text != nil {
      changeView(notification)
      showTimer.invalidate()
    }
  }

  public func hide() {
    removeView()
    showTimer.invalidate()
  }
}

// MARK: - Autolayout

extension NotificationController {

  func setupConstraints() {
    let totalWidth = UIScreen.mainScreen().bounds.width

    if kind == .Searching {
      view.addSubview(customLoader)

      let totalObjectsWidth = Dimensions.loaderSize
        + Dimensions.loaderTitleOffset + titleLabel.frame.width
      let positionLoader = (totalWidth - totalObjectsWidth) / 2
      let topOffset = (Dimensions.height - Dimensions.loaderSize) / 2

      layout (titleLabel, customLoader, replace: generalConstraints) {
        titleLabel, customLoader in

        customLoader.left == customLoader.superview!.left + positionLoader
        customLoader.top == customLoader.superview!.top + topOffset
        customLoader.width == Dimensions.loaderSize
        customLoader.height == Dimensions.loaderSize

        titleLabel.left == customLoader.right + Dimensions.loaderTitleOffset
        titleLabel.centerY == titleLabel.superview!.centerY
      }
    } else if kind == .Default {
      customLoader.removeFromSuperview()

      let withImage = complementImageView.image != nil
      let totalOffset = withImage ? Dimensions.imageSize + Dimensions.loaderTitleOffset : 0
      let totalObjectsWidth = totalOffset + titleLabel.frame.width
      let positionImage = (totalWidth - totalObjectsWidth) / 2
      let positionTitle = withImage
        ? positionImage + Dimensions.loaderTitleOffset + Dimensions.imageSize
        : positionImage
      let topOffset = (Dimensions.height - Dimensions.imageSize) / 2

      layout (titleLabel, complementImageView, replace: generalConstraints) {
        [unowned self] titleLabel, complementImage in

        complementImage.left == complementImage.superview!.left + positionImage
        complementImage.top == complementImage.superview!.top + topOffset
        complementImage.width == Dimensions.imageSize
        complementImage.height == Dimensions.imageSize

        titleLabel.left == titleLabel.superview!.left + positionTitle
        titleLabel.top == titleLabel.superview!.top
        titleLabel.width == self.titleLabel.frame.width
      }
    }
  }
}