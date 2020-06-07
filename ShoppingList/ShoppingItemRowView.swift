//
//  ItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct ShoppingItemRowView: View {
	// shows one line in a list for a shopping item, used for consistency
	// note: we must have the parameter as an @ObservedObject, otherwise
	// edits made to the ShoppingItem
	// will not show when the ShoppingListView or PurchasedListView
	// is brought back on screen.
	@ObservedObject var item: ShoppingItem
	var showLocation: Bool = true
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(item.name!)
					.font(.headline)
				if showLocation {
					Text(item.location!.name!)
						.font(.caption)
				}
			}
			Spacer()
			Text(String(item.quantity))
				.font(.headline)
				.foregroundColor(Color.blue)
		}
	}
}

