import UIKit

extension TodayViewController {
  func showConfirmButtons() {
    UIView.animateWithDuration(0.2, animations: { () -> Void in
      self.bigGulpButton.transform = CGAffineTransformMakeScale(0.001, 0.001)
      self.smallGulpButton.transform = CGAffineTransformMakeScale(0.001, 0.001)
    }) { (_) -> Void in
      UIView.animateWithDuration(0.2) {
        self.bigConfirmButton.transform = CGAffineTransformMakeScale(1, 1)
        self.smallConfirmButton.transform = CGAffineTransformMakeScale(1, 1)
      };
    }
  }

  func hideConfirmButtons() {
    UIView.animateWithDuration(0.2, animations: { () -> Void in
      self.bigConfirmButton.transform = CGAffineTransformMakeScale(0.001, 0.001)
      self.smallConfirmButton.transform = CGAffineTransformMakeScale(0.001, 0.001)
    }) { (_) -> Void in
      UIView.animateWithDuration(0.2) {
        self.bigGulpButton.transform = CGAffineTransformMakeScale(1, 1)
        self.smallGulpButton.transform = CGAffineTransformMakeScale(1, 1)
      };
    }
  }
}
