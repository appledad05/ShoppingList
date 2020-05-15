//
//  MainView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData


struct MainView: View {
	// @Environment(\.managedObjectContext) var managedObjectContext
	var body: some View {
		TabView {
			ShoppingListView()
				.tabItem {
					Image(systemName: "cart")
					Text("Shopping List")
			}
			
			PurchasedItemView()
				.tabItem {
					Image(systemName: "purchased")
					Text("Purchased")
			}
			
			LocationsView()
				.tabItem {
					Image(systemName: "map")
					Text("Locations")
			}
		}
		.onAppear(perform: doAppearanceCode)
	}
	
	func doAppearanceCode() {
		if kPerformJSONOutputDumpOnAppear {
			writeAsJSON(items: ShoppingItem.allShoppingItems())
			writeAsJSON(items: Location.allLocations())
		}
		if kPerformInitialDataLoad {
			populateDatabaseFromJSON()
		}
	}
	

}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}
