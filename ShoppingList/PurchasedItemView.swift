//
//  PurchasedItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct PurchasedItemView: View {
	
	// CoreData setup
	// @Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(entity: ShoppingItem.entity(),
								sortDescriptors: [
									NSSortDescriptor(keyPath: \ShoppingItem.name, ascending: true)],
								predicate: NSPredicate(format: "onList == false")
	) var purchasedItems: FetchedResults<ShoppingItem>

	
	var body: some View {
		NavigationView {
			List {
				
				// add new item stays at top
				NavigationLink(destination: AddorModifyShoppingItemView(placeOnShoppingList: false)) {
					HStack {
						Spacer()
						Text("Add New Item")
							.foregroundColor(Color.blue)
						Spacer()
					}
				}
				
				Section(header: Text("Items Listed: \(purchasedItems.count)")) {
					ForEach(purchasedItems, id:\.self) { item in
						NavigationLink(destination: AddorModifyShoppingItemView(editableItem: item)) {
							ShoppingItemView(item: item)
						} // end of NavigationLink
					} // end of ForEach
						.onDelete(perform: moveToShoppingList)
					
				} // end of Section
				
			}  // end of List
				.listStyle(GroupedListStyle())
				.navigationBarTitle(Text("Purchased Items"))
			
		}  // end of NavigationView
	}
	
	func moveToShoppingList(indexSet: IndexSet) {
		for index in indexSet {
			let item = purchasedItems[index]
			item.onList = true
		}
		ShoppingItem.saveChanges()
	}
	
}