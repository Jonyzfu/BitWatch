//
//  InterfaceController.swift
//  BitWatch WatchKit Extension
//
//  Created by Jonyzfu on 4/21/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import WatchKit
import Foundation
import BitWatchKit


class InterfaceController: WKInterfaceController {
    
    let tracker = Tracker()
    var updating = false

    @IBOutlet weak var priceLabel: WKInterfaceLabel!
    
    @IBOutlet weak var image: WKInterfaceImage!
    
    @IBOutlet weak var lastUpdatedLabel: WKInterfaceLabel!
    
    @IBOutlet weak var diffPrice: WKInterfaceLabel!
    
    @IBAction func refreshTapped() {
        update()
    }
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        updatePrice(tracker.cachedPrice())
        image.setHidden(true)
        updateDate(tracker.cachedDate())
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        update()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func updatePrice(price: NSNumber) {
        priceLabel.setText(Tracker.priceFormatter.stringFromNumber(price))
        diffPrice.setText("0 BTC")
    }
    
    private func update () {
        // Runs a quick check to make sure not updating already
        if !updating {
            updating = true
            // Cache the current price so only update the UI if the price changes
            let originalPrice = tracker.cachedPrice()
            // Gets the latest Bitcoin price via a network request
            tracker.requestPrice { (price, error) -> () in
                // Update the label
                if error == nil {
                    self.updatePrice(price!)
                    self.updateDate(NSDate())
                    self.updateImage(originalPrice, newPrice: price!)
                }
                self.updating = false
            }
        }
    }
    
    private func updateDate (date: NSDate) {
        self.lastUpdatedLabel.setText("Last Updated \(Tracker.dateFormatter.stringFromDate(date))")
    }
    
    private func updateImage(originalPrice: NSNumber, newPrice: NSNumber) {
        if originalPrice.isEqualToNumber(newPrice) {
            // Hide the arrow image
            self.image.setHidden(true)
            self.diffPrice.setText(String(format: "%.2f BTC", (newPrice.doubleValue - originalPrice.doubleValue)))
        } else {
            // Set the image to either "Up" or "Down" depending on the direction the price changed
            if newPrice.doubleValue > originalPrice.doubleValue {
                image.setImageNamed("Up")
                self.diffPrice.setText(String(format: "%.2f BTC", (newPrice.doubleValue - originalPrice.doubleValue)))
            } else {
                image.setImageNamed("Down")
                self.diffPrice.setText(String(format: "%.2f BTC", (originalPrice.doubleValue - newPrice.doubleValue)))
            }
            image.setHidden(false)
        }
        
    }

}
