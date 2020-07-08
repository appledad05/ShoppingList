//
//  PersistentStore.swift
//  ShoppingList
//
//  Created by Jerry on 7/4/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import CoreData

final class PersistentStore {
	
	private(set) static var shared = PersistentStore()
	
	// this makes sure we're the only one who can create one of these
	private init() { }
		
	lazy var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentContainer(name: "ShoppingList")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
			
		})
		// these next two lines added per suggestion by "Apple Staff" on the Apple Developer Forums
		// https://developer.apple.com/forums/thread/650173
		container.viewContext.automaticallyMergesChangesFromParent = true
		container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		return container
	}()
	
	var context: NSManagedObjectContext { persistentContainer.viewContext }
	
	func saveContext () {
		// let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch let error as NSError {
				NSLog("Unresolved error saving context: \(error), \(error.userInfo)")
			}
		}
	}
}