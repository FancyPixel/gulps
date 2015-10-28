import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {

    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        if complication.family == .UtilitarianSmall {
            let smallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
            smallFlat.textProvider = CLKSimpleTextProvider(text: "42%")
            smallFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
            smallFlat.tintColor = .mainColor()
            handler(smallFlat)
        } else if complication.family == .UtilitarianLarge {
            let largeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
            largeFlat.textProvider = CLKSimpleTextProvider(text: "Goal: 42%", shortText:"42%")
            largeFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
            largeFlat.tintColor = .mainColor()
            handler(largeFlat)
        } else if complication.family == .CircularSmall {
            let circularSmall = CLKComplicationTemplateCircularSmallRingImage()
            circularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
            circularSmall.ringStyle = .Closed
            circularSmall.tintColor = .mainColor()
            handler(circularSmall)
        } else if complication.family == .ModularSmall {
            let modularSmall = CLKComplicationTemplateModularSmallRingImage()
            modularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
            modularSmall.ringStyle = .Closed
            modularSmall.tintColor = .mainColor()
            handler(modularSmall)
        }
    }

    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimelineEntry?) -> Void) {
        var percentage = 0
        if let storedPercentage = EntryHelper.sharedHelper.percentage() {
            percentage = storedPercentage
        }

        if (complication.family == .UtilitarianSmall) {
            let smallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
            smallFlat.textProvider = CLKSimpleTextProvider(text: "\(percentage)%")
            smallFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
            smallFlat.tintColor = .mainColor()
            handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: smallFlat))
        } else if complication.family == .UtilitarianLarge {
            let largeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
            largeFlat.textProvider = CLKSimpleTextProvider(text: "Goal: \(percentage)%", shortText: "\(percentage)%")
            largeFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
            largeFlat.tintColor = .mainColor()
            handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: largeFlat))
        } else if complication.family == .CircularSmall {
            let circularSmall = CLKComplicationTemplateCircularSmallRingImage()
            circularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
            circularSmall.ringStyle = .Closed
            circularSmall.fillFraction = Float(percentage) / 100.0
            circularSmall.tintColor = .mainColor()
            handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: circularSmall))
        } else if complication.family == .ModularSmall {
            let modularSmall = CLKComplicationTemplateCircularSmallRingImage()
            modularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "complication")!)
            modularSmall.ringStyle = .Closed
            modularSmall.fillFraction = Float(percentage) / 100.0
            modularSmall.tintColor = .mainColor()
            handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: modularSmall))
        }
    }
    
    // MARK: - Time Travel
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler(.None)
    }
}
