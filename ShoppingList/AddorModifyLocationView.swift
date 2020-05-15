//
//  ModifyLocationView.swift
//  ShoppingList
//
//  Created by Jerry on 5/7/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct AddorModifyLocationView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@Environment(\.presentationMode) var presentationMode
	var editableLocation: Location? = nil
	
	@State private var locationName: String = "" // all of these values are suitable defaults for a new location
	@State private var visitationOrder: Int = 50
	@State private var red: Double = 0
	@State private var green: Double = 0
	@State private var blue: Double = 0
	@State private var opacity: Double = 0
	
	@State private var dataLoaded = false
	@State private var showDeleteConfirmation: Bool = false

	var body: some View {
		Form {
			// 1: Name, Visitation Order, Colors
			Section(header: Text("Basic Information")) {
				TextField("Location name", text: $locationName)
				if visitationOrder != kUnknownLocationVisitationOrder {
					Stepper(value: $visitationOrder, in: 1...100) {
						Text("Visitation Order: \(visitationOrder)")
					}
				}
				
				HStack {
					Text("Red: \(red)")
					Spacer()
					Slider(value: $red, in: 0 ... 1)
						.frame(width: 200)
				}
				HStack {
					Text("Green: \(green)")
					Spacer()
					Slider(value: $green, in: 0 ... 1)
						.frame(width: 200)
				}
				HStack {
					Text("Blue: \(blue)")
					Spacer()
					Slider(value: $blue, in: 0 ... 1)
						.frame(width: 200)
				}
				HStack {
					Text("Opacity: \(opacity)")
					Spacer()
					Slider(value: $opacity, in: 0 ... 1)
						.frame(width: 200)
				}
				Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)

			}
			
			// 2
			Section(header: Text("Location Management")) {
				HStack {
					Spacer()
					Button("Save") {
						self.commitData()
					}
					.disabled(locationName.isEmpty)
					Spacer()
				}
				
				if editableLocation != nil {
					HStack {
						Spacer()
						Button("Delete This Location") {
							self.showDeleteConfirmation = true
						}
						.foregroundColor(Color.red)
						Spacer()
					}
				}
			}  // end of Section
		} // end of Form
			.onAppear(perform: loadData)
			.navigationBarTitle("Add New Location", displayMode: .inline)
			.alert(isPresented: $showDeleteConfirmation) {
				Alert(title: Text("Delete \'\(locationName)\'?"),
							message: Text("Are you sure you want to delete this location?"),
							primaryButton: .cancel(Text("No")),
							secondaryButton: .destructive(Text("Yes"), action: self.deleteLocation)
				)}
	}
	
	func deleteLocation() {
		print("No deletion took place.  Not yet implemented for Locations.")
		// we will move all items in this location to the Unknown Location
		// if we can't find it, however, bail now
//		guard let unknownLocation = Location.unknownLocation() else { return }
		
//		// need to move all items in this location to Unknown
//		if let items = location.items as? Set<ShoppingItem> {
//			for item in items {
//				item.location?.removeFromItems(item)
//				item.setLocation(location: unknownLocation)
//			}
//		}
//		// now finish and deismiss
//		managedObjectContext.delete(location)
//		try? managedObjectContext.save()
//		presentationMode.wrappedValue.dismiss()
	}

	func commitData() {
		var locationForCommit: Location
		if let location = editableLocation {
			locationForCommit = location
		} else {
			locationForCommit = Location.addNewLocation()
		}
		
		locationForCommit.name = locationName
		locationForCommit.visitationOrder = Int32(visitationOrder)
		locationForCommit.red = red
		locationForCommit.green = green
		locationForCommit.blue = blue
		locationForCommit.opacity = opacity
		// THE PROBLEM: we now may have reordered the Locations by visitationOrder.
		// and if we return to the list of Locations, that's cool.  but if we move
		// over to the shopping list tab (or if we go back and then move over to the
		// shopping list tab), we're screwed -- it has not seen this update.
		// so we will update the parallel visitationOrder in all the shoppingList
		// items to match this order
		if let shoppingItems = locationForCommit.items as? Set<ShoppingItem> {
			for item in shoppingItems {
				item.visitationOrder = Int32(visitationOrder)
			}
		}
		try? managedObjectContext.save()
		presentationMode.wrappedValue.dismiss()
	}

	func loadData() {
		// called on every .onAppear().  if dataLoaded is true, then we have
		// already taken care of setting up the local state variables.
		if dataLoaded {
			return
		}
		// if there is an incoming editable location, offload its
		// values to the state variables
		if let location = editableLocation {
			locationName = location.name!
			visitationOrder = Int(location.visitationOrder)
			red = location.red
			green = location.green
			blue = location.blue
			opacity = location.opacity
		}
		// and be sure we don't do this again (!)
		dataLoaded = true
	}
}
