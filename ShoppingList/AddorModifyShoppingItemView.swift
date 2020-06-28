//
//  ModifyShoppingItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/3/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct AddorModifyShoppingItemView: View {
	// we use this so we can dismiss ourself (sometimes we're in a Sheet, sometimes
	// in a NavigationLink)
	@Environment(\.presentationMode) var presentationMode

	// editableItem is either a ShoppingItem to edit, or nil to signify
	// that we're creating a new ShoppingItem in this View.
	var editableItem: ShoppingItem? = nil
	
	// allowsDeletion is usually true: we will show a "Delete this Item"
	// button.  however, if we do Locations -> EditorModify -> select one
	// of the items at this location -> Delete this Item, we have a problem.
	// the editableLocation in AddOrModifyLocationView cannot be an observable
	// object, because i allow it to be nil; and so deleting an item this deep
	// in the navigation hierarchy doesn't trickle back to the AddOrModifyLocationView
	// and the view still shows the item at that location.  then, trying to look
	// at the item causes a crash, because it's not there and we crash.
	// so when AddOrModifyLocationView presents this view, we'll set this
	// to false.  yes, it's kludgey, but time will tell if there's an easier
	// way to do this.  you just can't make a binding to an optional ObservedObject?
	var allowsDeletion: Bool = true
	
	// addItemToShoppingList just means that by default, a new item will be added to
	// the shopping list, and so this is true.
	// however, if inserting a new item from the Purchased list,
	// this will be set to false. the user can override here if they wish.
	var addItemToShoppingList: Bool = true
	
	// this editableData stuct contains all of the fields of a ShoppingItem that
	// can be edited here, so that we're not doing a "live edit" on the ShoppingItem.
	// itself.  this will be defaulted properly in .onAppear()
	@State private var editableData = EditableShoppingItemData()

	// this indicates whether the editableData has been initialized from an incoming
	// editableItem and it will be flipped to true once .onAppear() has been called
	// and the editableData is appropriately set
	@State private var editableDataInitialized = false
	
	// showDeleteConfirmation controls whether a Delete This Shopping Item button appear
	// to confirm deletion of a ShoppingItem
	@State private var showDeleteConfirmation: Bool = false
	
	// this "itemToDeleteAfterDisappear" variable is a place to stash an item to be deleted, if any,
	// after the view has disappeared.  seems like a kludgey way to do this, but also seems
	// to work without incident (instead of deleting first then popping this view back
	// to its navigation parent, which seems to want to crash sometimes)
	@State private var itemToDeleteAfterDisappear: ShoppingItem?

	var body: some View {
		
		ShoppingItemEditView(editableData: $editableData, showDeleteConfirmation: $showDeleteConfirmation, allowsDeletion: allowsDeletion)
			.navigationBarTitle(barTitle(), displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(
				leading: Button(action : { self.presentationMode.wrappedValue.dismiss() }){
					Text("Cancel")
				},
				trailing: Button(action : { self.commitDataEntry() }){
					Text("Save")
						.disabled(!editableData.canBeSaved)
			})
			.onAppear(perform: loadData)
			.onDisappear(perform: deleteItemIfRequested)
			.alert(isPresented: $showDeleteConfirmation) {
				Alert(title: Text("Delete \'\(editableItem!.name!)\'?"),
							message: Text("Are you sure you want to delete this item?"),
							primaryButton: .cancel(Text("No")),
							secondaryButton: .destructive(Text("Yes"), action: self.deleteItem)
				)}
	}
	
	// called when view disappears, which is when the parent view has fully returned
	// to the screen.  this way, we don't delete out from under the parent, which seems
	// to have been the underlying bug i struggled with earlier
	func deleteItemIfRequested() {
		if let item = itemToDeleteAfterDisappear {
			ShoppingItem.delete(item: item, saveChanges: true)
		}
	}
		
	func barTitle() -> Text {
		return editableItem == nil ? Text("Add New Item") : Text("Modify Item")
	}
	
	func loadData() {
		// called on every .onAppear().  if dataLoaded is true, then we have
		// already taken care of setting up the local state editable data.  otherwise,
		// we offload all the data from the editableItem (if there is one) to the
		// local state editable data that control this view
		if !editableDataInitialized {
			if let item = editableItem {
				editableData = EditableShoppingItemData(shoppingItem: item)
			} else {
				// just be sure the default data is tweaked to place a new item on
				// the right list by default, depending on how this view was created
				editableData = EditableShoppingItemData(onList: addItemToShoppingList)
			}
			// and be sure we don't do this again (!)
			editableDataInitialized = true
		}
	}
	
	func commitDataEntry() {
		guard editableData.canBeSaved else { return }
		
		// if we already have an editableItem, use it, else create it now
		var itemForCommit: ShoppingItem
		if let item = editableItem {
			itemForCommit = item
		} else {
			itemForCommit = ShoppingItem.addNewItem()
		}
		
		// update for all edits made and we're done.  i created an extension
		// on ShoppingItem below to do this update
		itemForCommit.updateValues(from: editableData)
		ShoppingItem.saveChanges()
		presentationMode.wrappedValue.dismiss()
	}
	
	// called after confirmation to delete an item.  we only place this
	// item to delete "on hold" and it will be deleted after this view disappears --
	// which means that you'll see the deletion then take place in the parent view
	func deleteItem() {
		if let item = editableItem {
			itemToDeleteAfterDisappear = item
			presentationMode.wrappedValue.dismiss()
		}
	}
}

