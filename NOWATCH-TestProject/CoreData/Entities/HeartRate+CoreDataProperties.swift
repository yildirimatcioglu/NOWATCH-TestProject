// Created on 30/05/2024

import CoreData
import Foundation

public extension HeartRate {
    @nonobjc class func fetchRequest() -> NSFetchRequest<HeartRate> {
        NSFetchRequest<HeartRate>(entityName: "HeartRate")
    }

    @NSManaged var datetime: Date?
    @NSManaged var value: Int32

}

extension HeartRate : Identifiable { }
