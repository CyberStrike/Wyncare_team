//
//  HealthKitManager.swift
//  OneHourWalker
//
//  Created by Matthew Maher on 2/19/16.
//  Copyright © 2016 Matt Maher. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager {
    
    let healthKitStore: HKHealthStore = HKHealthStore()
    
    
    
    func authorizeHealthKit(_ completion: ((success: Bool, error: NSError?) -> Void)!) {
        
        
        func dataTypesToWrite() -> Set<HKSampleType>
        {
            let dietaryCalorieEnergyType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)!
            let activeEnergyBurnType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
            let heightType:  HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
            let weightType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
            let ccdType: HKDocumentType = HKObjectType.documentType(forIdentifier: HKDocumentTypeIdentifier.CDA)!
            let distanceWalkingRunningType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
            let writeDataTypes: Set<HKSampleType> = [dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, ccdType, distanceWalkingRunningType]
            
            return writeDataTypes
        }


        
        // State the health data type(s) we want to read from HealthKit.
        let healthDataToRead = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!)
        
        // State the health data type(s) we want to write from HealthKit.
        //let healthDataToWrite = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!)
        
        // State the health data type(s) we want to write from HealthKit.
        //let healthCCDataToWrite = Set(arrayLiteral: HKObjectType.documentType(forIdentifier: HKDocumentTypeIdentifier.CDA)!)
        
        // Just in case OneHourWalker makes its way to an iPad...
        if !HKHealthStore.isHealthDataAvailable() {
            print("Can't access HealthKit.")
        }
        
        // Request authorization to read and/or write the specific data.
        healthKitStore.requestAuthorization(toShare: dataTypesToWrite(), read: healthDataToRead) { (success, error) -> Void in
            if( completion != nil ) {
                completion(success:success, error:error)
            }
        }
    }
    
    func getHeight(_ sampleType: HKSampleType , completion: ((HKSample?, NSError?) -> Void)!) {
        
        // Predicate for the height query
        let distantPastHeight = Date.distantPast as Date
        let currentDate = Date()
        let lastHeightPredicate = HKQuery.predicateForSamples(withStart: distantPastHeight, end: currentDate, options: HKQueryOptions())
        
        // Get the single most recent height
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Query HealthKit for the last Height entry.
        let heightQuery = HKSampleQuery(sampleType: sampleType, predicate: lastHeightPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error ) -> Void in
                
                if let queryError = error {
                    completion(nil, queryError)
                    return
                }
                
                // Set the first HKQuantitySample in results as the most recent height.
                let lastHeight = results!.first
            
                if completion != nil {
                    completion(lastHeight, nil)
                }
        }
        
        // Time to execute the query.
        self.healthKitStore.execute(heightQuery)
    }
    
    func saveDistance(distanceRecorded: Double, date: Date ) {
                
        // Set the quantity type to the running/walking distance.
        let distanceType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
        
        // Set the unit of measurement to miles.
        let distanceQuantity = HKQuantity(unit: HKUnit.mile(), doubleValue: distanceRecorded)
        
        // Set the official Quantity Sample.
        let distance = HKQuantitySample(type: distanceType!, quantity: distanceQuantity, start: date, end: date)
        
        // Save the distance quantity sample to the HealthKit Store.
        healthKitStore.save(distance, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                print(error)
            } else {
                print("The distance has been recorded! Better go check!")
            }
        })
    }

    
    func saveCDA(){
        
        let today = Date()
        let urlPath: String = "https://raw.githubusercontent.com/chb/sample_ccdas/master/HL7%20Samples/CCD.sample.xml"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                do {
                    let cdaSample = try HKCDADocumentSample.init(data: data! as Data, start: today, end:today, metadata: nil)
                    self.healthKitStore.save(cdaSample) {
                        
                        (success, error) -> Void in
                        
                        if( error != nil ) {
                            print(error)
                        } else {
                            print("Hallelujah!!")
                        }
                        
                    }
                } catch {
                    // Handle validation error here...
                }
                
                print("Everyone is fine, file downloaded successfully.")
            }
        }
        
        task.resume()
        
        
    }
}

