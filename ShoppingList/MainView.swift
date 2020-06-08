//
//  MainView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI
import CoreData

// the MainView is where the app begins.  it is a tab view with three
// tabs, all inside a NavigationView.  not much going on here, other
// than to track the selected tab (1, 2, or 3) so that we can set
// the navigation title appropriately.

// one programming note: the .onAppear() modifier is used here for two reasons:
// (1) if the database is empty (determined by whether there's a special "Unknown Location"
// already in the database), then we create that location.
// (2) loading an initial database if requested in Development.swift
// (3) dumping the current CoreData database to JSON if requested in Development.swift

struct MainView: View {
	@State private var selectedTab = 1
	
	var body: some View {
		NavigationView {
			
			// the first tabView is the shopping list.  change ShoppingListTabView1 to ShoppingListTabView2
			// to see what happens with my current investigation into sectioning the list of shopping items.
			// there seems to be a major problem -- surely with View2 when deleting some, but not all, of
			// the items in some sections; and maybe this happened one time in View1 when the list went
			// empty (although i think the database was inconsistent at that point)
			// -- it goes BOOM.  i'm working on it.
			TabView(selection: $selectedTab) {
				ShoppingListTabView2()		// <--- see note above about the 1 or 2 that appears here
					.tabItem {
						Image(systemName: "cart")
						Text("Shopping List")
				}.tag(1)
				
				PurchasedTabView()
					.tabItem {
						Image(systemName: "purchased")
						Text("Purchased")
				}.tag(2)
				
				LocationsTabView()
					.tabItem {
						Image(systemName: "map")
						Text("Locations")
				}.tag(3)
				
			} // end of TabView
			.navigationBarTitle(tabTitle(selectedTab: selectedTab))
			.onAppear(perform: doAppearanceCode)

		} // end of NavigationView
	}
		
		func tabTitle(selectedTab: Int) -> String {
			if selectedTab == 1 {
				return "Shopping List"
			} else if selectedTab == 2 {
				return "Purchased"
			} else {
				return "Locations"
			}
		}
	
	func doAppearanceCode() {
		// do we have a working database yet?  if not, create the Unknown Location
		// so that we have a working database (1 location, no items)
		if Location.unknownLocation() == nil {
			let jsonLocations: [LocationJSON] = Bundle.main.decode(from: kUnknownLocationFilename)
			Location.insertNewLocations(from: jsonLocations)
		}
	
		// do we want to load data to populate the database? (see Development.swift)
		if kPerformInitialDataLoad {
			populateDatabaseFromJSON()
			kPerformInitialDataLoad = false // don't do this again
		}
		
		// do we want to dump the database as JSON?  (see Development.swift)
		if kPerformJSONOutputDumpOnAppear {
			writeAsJSON(items: ShoppingItem.allShoppingItems(), to: kShoppingItemsFilename)
			writeAsJSON(items: Location.allUserLocations(), to: kLocationsFilename)
			kPerformJSONOutputDumpOnAppear = false // don't do this again
		}
	}
	

}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}
