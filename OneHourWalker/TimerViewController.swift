//
//  TimerViewController.swift
//  OneHourWalker
//
//  Created by Matthew Maher on 2/18/16.
//  Copyright © 2016 Matt Maher. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit

class TimerViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    
    var zeroTime = TimeInterval()
    var timer : Timer = Timer()
    
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var distanceTraveled = 0.0
    
    let healthManager:HealthKitManager = HealthKitManager()
    var height: HKQuantitySample?
    
    @IBOutlet weak var Cloud: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func getHealthKitPermission() {
        
        // Seek authorization in HealthKitManager.swift.
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                
                self.healthManager.saveCDA()

            } else {
                if error != nil {
                    print(error)
                }
                print("Permission denied.")
            }
        }
    }
    
    
    @IBAction func stopTimer(_ sender: AnyObject) {
        timer.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func syncDidTouch(_ sender: AnyObject) {
        

        // We cannot access the user's HealthKit data without specific permission.
        getHealthKitPermission()
        
        UIView.transition(with: Cloud,
                          duration:1,
                          options: UIViewAnimationOptions.transitionCrossDissolve,
                          animations: { self.Cloud.image = UIImage(named: "cloud-t") },
                          completion: nil)
        
    }

    
}
