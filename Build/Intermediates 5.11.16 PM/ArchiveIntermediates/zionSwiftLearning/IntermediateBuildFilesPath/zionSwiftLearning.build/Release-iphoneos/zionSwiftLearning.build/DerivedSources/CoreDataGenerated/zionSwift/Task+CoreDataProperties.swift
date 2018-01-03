//
//  Task+CoreDataProperties.swift
//  
//
//  Created by Apple-1 on 02/01/18.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task");
    }

    @NSManaged public var name: String?

}
