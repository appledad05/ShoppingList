//
//  LocationRowView.swift
//  ShoppingList
//
//  Created by Jerry on 6/1/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// ONCE AGAIN: i pulled this code out of the List/Section/ForEach/NavigationLink
// hierarchy in LocationTabView to simply the code, initially without @ObservedObject.
// then updates in the LocationTabView were not reflected.  when i came
// back and added @ObservedObject, all visual updates work finen.
// identifying the variable
// as an @Observed object causes SwiftUI to update this view properly.
struct LocationRowView: View {
	@ObservedObject var location: Location
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(location.name!)
					.font(.headline)
				Text("\(location.items!.count) items")
					.font(.caption)
			}
			if location.visitationOrder != kUnknownLocationVisitationOrder {
				Spacer()
				Text(String(location.visitationOrder))
			}
		}
	}
}

//struct LocationRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationRowView()
//    }
//}
