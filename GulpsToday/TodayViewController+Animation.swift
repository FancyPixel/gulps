import UIKit

extension TodayViewController {
  func showConfirmButtons() {
    UIView.animate(withDuration: 0.2, animations: { () -> Void in
      self.bigGulpButton.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
      self.smallGulpButton.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
    }, completion: { (_) -> Void in
      UIView.animate(withDuration: 0.2, animations: {
        self.bigConfirmButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.smallConfirmButton.transform = CGAffineTransform(scaleX: 1, y: 1)
      }) ;
    }) 
  }

  func hideConfirmButtons() {
    UIView.animate(withDuration: 0.2, animations: { () -> Void in
      self.bigConfirmButton.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
      self.smallConfirmButton.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
    }, completion: { (_) -> Void in
      UIView.animate(withDuration: 0.2, animations: {
        self.bigGulpButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.smallGulpButton.transform = CGAffineTransform(scaleX: 1, y: 1)
      }) ;
    }) 
  }
}
