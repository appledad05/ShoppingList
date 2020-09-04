#  About "ShoppingList"

This is a simple, iOS project using SwiftUI to process a shopping list that you can take to the grocery store with you, and swipe off the items as you pick them up.  It persists data in CoreData.  Although written using SwiftUI, it does not use @FetchRequest or Combine; rather, I rely on internal notifications using the default NotificationCenter to post data changes and then have view models respond to those changes.

This project seems reasonably stable and does pretty much work as I suggest, as of XCode 11.7/iOS 13.7.  Feel free to use this as is, to develop further,  to completely ignore, or even just to inspect and then send me a note to tell me I am doing this all wrong.  

I have (only quickly) tested this project in XCode 12 beta 6 and the good news is: it seems to work in the simulator.  However, I have not loaded in on a physical device for testing, since I don't like to turn my phone into a development testbed for beta sofware.

## Last Update of Note

My Last Update of note was **September 4, 2020**, when these were some of the changes I made.

* Tapping on the "Move All Items Off-list" button in the ShoppingListTabView now triggers a confirmation Alert.  Because of the placement of this button just above the tab bar, it would be too easy to accidentally tap this button when you have a full shopping list in front of you.  

Other than for future bug fixes (i.e., *removal of coding anomalies*) and perhaps some updating of comments within the code for things that have evolved during development, **this is the last, public update of the project**.



## General App Structure

 ![](Screenshot1.jpg)  ![](Screenshot2.jpg) 


 ![](Screenshot3.jpg)  ![](Screenshot4.jpg) 

The main screen is a TabView, to show 
* a current shopping list, 
* a (searchable) list of previously purchased items, 
* a list of "locations" in a store, such as "Dairy," "Fruits & Vegetables," "Deli," and so forth, 
* an in-store timer, to track how long it takes you to complete shopping, and
* optionally, for purposes of demonstration, a "Dev Tools" tab to make wholesale adjustments to the data and the shopping list display (this can be hidden for real usage).

The CoreData model has only two entities named "ShoppingItem" and "Location," with every ShoppingItem having a to-one relationship to a Location (the inverse is to-many).

* **ShoppingItems** have an id (UUID), a name, a quantity, a boolean "onList" that indicates whether the item is on the list for today's shopping exercise, or not on the list (and so available in the purchased list for future promotion to the shopping list), and also an "isAvailable" boolean that provides a strike-through appearance for the item when false (sometimes an item is on the list, but not available today, and I want to remember that when planning the future shopping list).    ShoppingItems currently have a visitationOrder, that mirrors the visitationOrder of the Location to which they are assigned, but the current version of the code does not read or write of the value of this field (i.e., feel free to delete it from the Core Data model if you have not already built out a large database using previous versions of the code).

* **Locations** have an id (UUID), a name, a visitationOrder (an integer, as in, go to the dairy first, then the deli, then the canned vegetables, etc), and then values red, green, blue, opacity to define a color that is used to color every item listed in the shopping list. 

For the first two tabs, swiping an item (from trailing to leading)  moves a shopping item from one list to the other list (from "on the list" to "purchased" and vice-versa).  

* This is an issue with SwiftUI, even after WWDC2020: the only swipe supported is a swipe-to-delete and it shows "Delete" in white on a red background for the action.  I like to swipe as I shop to move items off the shopping list (not delete them from Core Data), so I have co-opted the swipe to mean "move to the other list," despite the destructive "Delete"  showing. This behaviour can be adjusted in code to mean "delete, really" if you prefer (see Development.swift).

Tapping on any item in either list lets you edit it for name, quantity, assign/edit the store location in which it is found, or even delete the item.  Long pressing on an item gives you a contextMenu to let you move items between lists,  toggle between the item being available and not available, or directly delete the item (if a swipe does not already mean "delete").

The shopping list is sorted by the visitation order of the location in which it is found (and then alphabetically within each Location).  Items in the shopping list cannot be otherwise re-ordered, although all items in the same Location have the same color as a form of grouping.  Tapping on the leading icon in the navigation bar will toggle the display from a simple, one-section list, to a multi-section list.

* Why don't you let me drag these items to reorder them, you ask?  Well, I did the reordering thing one time with .onMove(), and discovered that moving items around in a list in SwiftUI is an absolutely horrific user-experience when you have 30 or 40 items on the list -- so I don't so that anymore.  And I also don't see that you can drag between Sections of a list.


The third tab shows a list of all locations, listed in visitationOrder (an integer from 1...100).  One special Location is the "Unknown Location," which serves as the default location for all new items.  I use this special location to mean that "I don't really know where this item is yet, but I'll figure it out at the store." In programming terms, this location has the highest of all visitationOrder values, so that it comes last in the list of Locations, and shopping items with an unassigned/unknown location will come at the bottom of the shopping list. 

Tapping on a Location in the list lets you edit location information, including reassigning the visitation order, its color, and delete it.  (Individually adjusting RGB and Alpha may not the best UI in this app, but it will have to do for iOS 13.  Also, using color to distinguish different Locations may not even be a good UI, since a significant portion of users either cannot distinguish color or cannot choose visually compatible colors very well.)  You will also see a list of the ShoppingItems that are associated with this Location. A long press on a location (other than the "unknown location") will allow you to delete the location directly.

* Why not let the user drag the Locations around to reset the order? Well, it's partly the SwiftUI visual problem with .onMove() mentioned above. 

* What happens to ShoppingItems in a Location when a Location is deleted?  The items are not deleted, but simply moved to the Unknown Location.

The fourth tab is an in-store timer, with three simple button controls: "Start," "Stop," and "Reset."  This timer will be (optionally) paused when the app goes inactive (e.g., if you get a phone call while you're shopping), although the default is to not pause it when going inactive. (See Development.swift to change this behaviour.)

Finally, there is a  tab for "development-only" purposes, that allows wholesale loading of sample data, removal of all data, and offloading data for later use. This tab should not appear in any production version of the app (see Development.swift to hide this).

So, 

* **If you plan to use this app**, the app will start with an empty shopping list and an almost-empty location list (it will contain the sacred "Unknown Location"); from there you can create your own shopping items and locations associated with those items.  

* **If you plan to play with or just test out this app**, go straight  to the Dev Tools tab and tap the "Load Sample Data" button.  Now you can  play with the app, and eventually delete the data when you're finished.


## App Architecture Comment

This version makes no direct use of @FetchRequest or Combine and I have *gone completely old-school*, just like I would have built this app using UIKit, before there was SwiftUI and Combine. 

* I post internal notifications through the NotificationCenter that a ShoppingItem or a Location has either been created, or edited, or is about to be deleted.  (Remember, notifications are essentially a form of using the more general Combine framework.) Every  view model loads its data only once from Core Data and signs up for appropriate notifications to stay in-sync without additional fetches from Core Data.  Each view model can then react accordingly, alerting SwiftUI so that the associated View needs to be updated.  This  design suits my needs, but may not be necessary for your own projects, for which straightforward use of @FetchRequest might well be sufficient.




## Future Work

Although this is the last, public release of the project, there are many directions to move with this code.

* I'd like to look at CloudKit support for the database for my own use, although such a development  could return to public view if I run into trouble and have to ask for help.  The general theory is that you just replace NSPersistentContainer with NSPersistentCloudkitContainer, flip a few switches in the project, add the right entitlements, and off you go. *I doubt that is truly the case*, and certainly there will be a collection of new issues that arise.

* I should invest a little time with iPadOS.  Unfortunately, my iPad 2 is stuck in iOS 9, so it's not important to me right now.  As a future option, though -- even though you probably don't want to drag an iPad around in the store with you -- you might want to use it to update the day's shopping list and then, via the cloud, have those changes show up on your phone to use in-store.

*  I still get console messages at runtime about tables laying out outside the view hierarchy, and one that's come up recently of "Trying to pop to a missing destination." I see fewer of these messages in XCode 11.7.  When using contextMenus, I get a plenty of "Unable to simultaneously satisfy constraints" messages.  I'm ignoring them for now, and I have already seen fewer or none of these in testing out XCode 12 (through beta 6). 


* I have thought about expanding the app and database to support multiple "Stores," each of which has "Locations," and having "ShoppingItems" being many-to-many with Locations so one item can be available in many Stores would be a nice exercise. But I have worked with Core Data several times, and I don't see that I gain anything more in the way of learning about SwiftUI by doing this, so I doubt that I'll pursue this any time soon.

* I could add a printing capability, or even a general sharing capability (e.g., email the shopping list to someone else).  I did something like this in another (*UI-Kit based*) project, so it should be easy, right?  

I have, only briefly, tested out this code with **XCode 12beta 6**, and here are some observations so far:

* Core Data now automatically generates an extension of a Core Data class to be Identifiable, if the data model has an id field (mine has type UUID, but maybe other Hashable types apply as well).  So adding my own conformance of Shopping Item and Location to Identifiable is no longer needed.  However, XCode will generate a duplicate conformance error, not so much on my adding conformance, but *primarily on its own generated file*, which was a little confusing at first.

* GroupedListStyle now puts a section header in .uppercase by default, but you can override that by using .textCase(.none) so the header displays the title exactly as you want.

* Tapping on a List item in iOS with a NavigationLink becomes "selected" in its hilighting as it was in iOS 13, but upon return, unlike iOS 13, the list item remains hilighted as "selected."  I will have to research the problem and the notion of List selection -- in UIKit, it was simply a tableView.deselectRow(at: animated:) call.

* Things otherwise look good, and even the "deletion issue" that I worked on so much early in this project and (*I think*) have eliminated in the current code does not pop up (*so far*) in the new XCode 12 beta 6.  

Note that I am  certainly not at all interested in creating the next, killer 
shopping list app or moving any of this to the App Store.  *The world really does not need a new list-making app*.  
If you want to take this code and run with it ... go right ahead.


##  View Updating Issues

Remember that I built this project in public only as an experiment, and to offer some  suggested code to the  folks who keep running into SwiftUI's **generic problem** of: 

> an item appears in View A; it is edited in View B (a detail view that appears either by a NavigationLink or a .sheet presentation); but its appearance in View A does not get updated properly upon return.  

SwiftUI does a lot of the updating for you automatically (the *single-source-of-truth doctrine*), but the situation is more tricky when using Core Data because  the model data consists of objects (classes), not structs.  SwiftUI does provide @FetchRequest and @ObservedObject (and Combine if you go deeper), but the updating problem is not solved just by sprinkling @ObservedObject property wrappers around in your code. It especially matters in SwiftUI whether you pass around structs or classes  in SwiftUI Views, and exactly how you pass them.  


Indeed, the biggest issue that I found in this app involved updates following a **deletion** of a Core Data object.  My conclusion is that  @FetchRequest and SwiftUI don't always interact that well with respect to deletions, and that is what drove me to the architecture and my reliance on using the NotificationCenter that you will find in the app. (*I have extensive comments in the code about the problems I faced in -- see ShoppingItemRowData.swift*).


* I think that my current use of notifications and "view models" in place of @FetchRequest solves a lot of the **generic problem** in the distributed SwiftUI situation that occurs in *this* app.  



## Closing

The project is what it is -- a project that began trying to learn how to use SwiftUI with a Core Data store. On a basic level, understanding the SwiftUI lifecycle of how Views come and go turned out to be a major undertaking.  On the Core Data side, using @FetchRequest was the obvious, right thing -- until it wasn't.  Then adding a few sprinkles of Combine looked like the right thing -- until it wasn't.  I learned a lot ... and that was the point of this project.


Feel free to contact me about questions and comments.


## License

* The SearchBarView in the Purchased items view was created by Simon Ng.  It appeared in [an article in AppCoda](https://www.appcoda.com/swiftui-search-bar/) and is copyright ©2020 by AppCoda. You can find it on GitHub under AppCoda/SwiftUISearchBar. 
* The app icon was created by Wes Breazell from [the Noun Project](https://thenounproject.com). 
* The extension I use on Bundle to load JSON files is due to Paul Hudson (@twostraws, [hackingwithswift.com](https://hackingwithswift.com)) 

Otherwise, almost all of the code is original,  and it's yours if you want it -- please see LICENSE for the usual details and disclaimers.

