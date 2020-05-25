//
//  ModifyShoppingItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/3/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct AddorModifyShoppingItemView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@Environment(\.presentationMode) var presentationMode
	var editableItem: ShoppingItem? = nil
	
	@State private var itemName: String = "" // these are suitable defaults for a new shoppiing item
	@State private var itemQuantity: Int = 1
	@State private var selectedLocationIndex: Int = 0
	
	@State private var dataLoaded = false
	@State private var showDeleteConfirmation: Bool = false
	var placeOnShoppingList: Bool = true // assume we want new items on shopping list, set to false if adding a new item

	// we need access to the complete list of Locations to populate the picker
	@FetchRequest(entity: Location.entity(),
								sortDescriptors: [NSSortDescriptor(keyPath: \Location.visitationOrder, ascending: true)])
	var locations: FetchedResults<Location>

	var body: some View {
		Form {
			// 1
			Section(header: Text("Basic Information")) {
				HStack(alignment: .firstTextBaseline) {
					MyFormLabelText(labelText: "Name: ")
					TextField("Item name", text: $itemName, onCommit: { self.commitDataEntry() })
				}
				Stepper(value: $itemQuantity, in: 1...10) {
					HStack {
						MyFormLabelText(labelText: "Quantity: ")
						Text("\(itemQuantity)")
					}
				}
				Picker(selection: $selectedLocationIndex,
							 label: MyFormLabelText(labelText: "Location: ")) {
					ForEach(0 ..< locations.count, id:\.self) { index in
						Text(self.locations[index].name!)
					}
				}
			}
			
			// 2 -- operational buttons
			Section(header: Text("Shopping Item Management")) {
				HStack {
					Spacer()
					Button("Save") {
						self.commitDataEntry()
					}
					.disabled(itemName.isEmpty)
					Spacer()
				}

				if editableItem != nil {
					HStack {
					Spacer()
					Button("Delete This Shopping Item") {
						self.showDeleteConfirmation = true
						// self.deleteItem()
					}
					.foregroundColor(Color.red)
					Spacer()
				}
				}

			}
			.onAppear(perform: loadData)
			.alert(isPresented: $showDeleteConfirmation) {
				Alert(title: Text("Delete \'\(editableItem!.name!)\'?"),
							message: Text("Are you sure you want to delete this item?"),
							primaryButton: .cancel(Text("No")),
							secondaryButton: .destructive(Text("Yes"), action: self.deleteItem)
				)}
	
		
		} // end of Form
			.navigationBarTitle(barTitle(), displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading: Button(action : {
				self.presentationMode.wrappedValue.dismiss()
			}){
				Text("Cancel")
			})

	}
	
	func barTitle() -> Text {
		return editableItem == nil ? Text("Add New Item") : Text("Modify Item")
	}
	
	func loadData() {
		// called on every .onAppear().  if dataLoaded is true, then we have
		// already taken care of setting up the local state variables.
		if dataLoaded {
			return
		}
		// if there is an incoming editable shopping item, offload its
		// values to the state variables
		if let item = editableItem {
			itemName = item.name!
			itemQuantity = Int(item.quantity)
			let locationNames = locations.map() { $0.name! }
			if let index = locationNames.firstIndex(of: item.location!.name!) {
				selectedLocationIndex = index
			} else {
				selectedLocationIndex = locations.count - 1 // index of Unknown Location
			}
		}
		// and be sure we don't do this again (!)
		dataLoaded = true
	}
	
	func commitDataEntry() {
		// if we already have an editableItem, use it,
		// else create it now
		var itemForCommit: ShoppingItem
		if let item = editableItem {
			itemForCommit = item
		} else {
			itemForCommit = ShoppingItem.addNewItem()
		}

		// fill in basic info fields
		itemForCommit.name = itemName
		itemForCommit.quantity = Int32(itemQuantity)
		itemForCommit.onList = placeOnShoppingList
		// if existing object, remove its reference from its locations (notice ?.?.!)
		editableItem?.location?.removeFromItems(editableItem!)
		// then update location info
		itemForCommit.setLocation(locations[selectedLocationIndex])
		ShoppingItem.saveChanges()
		presentationMode.wrappedValue.dismiss()
	}
	
	func deleteItem() {
		if let item = editableItem {
			let location = item.location
			location?.removeFromItems(item)
			ShoppingItem.delete(item: item)
			presentationMode.wrappedValue.dismiss()
		}
	}
}
