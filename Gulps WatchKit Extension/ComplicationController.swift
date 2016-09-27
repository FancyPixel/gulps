import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {

  func requestedUpdateDidBegin() {
    let server = CLKComplicationServer.sharedInstance()
    guard let activeComplications = server.activeComplications else { return }
    activeComplications.forEach { server.reloadTimeline(for: $0) }
  }

  func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
    if complication.family == .utilitarianSmall {
      let smallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
      smallFlat.textProvider = CLKSimpleTextProvider(text: "42%")
      smallFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
      smallFlat.tintColor = .palette_main
      handler(smallFlat)
    } else if complication.family == .utilitarianLarge {
      let largeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
      largeFlat.textProvider = CLKSimpleTextProvider(text: "Goal: 42%", shortText:"42%")
      largeFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
      largeFlat.tintColor = .palette_main
      handler(largeFlat)
    } else if complication.family == .circularSmall {
      let circularSmall = CLKComplicationTemplateCircularSmallRingImage()
      circularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
      circularSmall.ringStyle = .closed
      circularSmall.tintColor = .palette_main
      handler(circularSmall)
    } else if complication.family == .modularSmall {
      let modularSmall = CLKComplicationTemplateModularSmallRingImage()
      modularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
      modularSmall.ringStyle = .closed
      modularSmall.tintColor = .palette_main
      handler(modularSmall)
    }
  }

  func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
    let percentage = WatchEntryHelper.sharedHelper.percentage() ?? 0

    if complication.family == .utilitarianSmall {
      let smallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
      smallFlat.textProvider = CLKSimpleTextProvider(text: "\(percentage)%")
      smallFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
      smallFlat.tintColor = .palette_main
      handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: smallFlat))
    } else if complication.family == .utilitarianLarge {
      let largeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
      largeFlat.textProvider = CLKSimpleTextProvider(text: "Goal: \(percentage)%", shortText: "\(percentage)%")
      largeFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
      largeFlat.tintColor = .palette_main
      handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: largeFlat))
    } else if complication.family == .circularSmall {
      let circularSmall = CLKComplicationTemplateCircularSmallRingImage()
      circularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
      circularSmall.ringStyle = .closed
      circularSmall.fillFraction = Float(percentage) / 100.0
      circularSmall.tintColor = .palette_main
      handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: circularSmall))
    } else if complication.family == .modularSmall {
      let modularSmall = CLKComplicationTemplateModularSmallRingImage()
      modularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
      modularSmall.ringStyle = .closed
      modularSmall.fillFraction = Float(percentage) / 100.0
      modularSmall.tintColor = .palette_main
      handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: modularSmall))
    }
  }

  // MARK: - Time Travel

  func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
    handler(CLKComplicationTimeTravelDirections())
  }
}
