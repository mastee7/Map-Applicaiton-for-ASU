//
//  placeViewModel.swift
//  mapApp
//
//  Created by Woojeh Chung on 3/19/23.
//

import Foundation

struct place : Identifiable
{
    var id = UUID()
    var name = String()
    var latitude = Double()
    var longitude = Double()
    var type = String()
    var description = String()
    var image = String()
}

struct Section: Identifiable
{
    let id = UUID()
    let name: String
}

struct placeGroup : Identifiable
{
    var id = UUID()
    var groupName : String
    var places : [place]
}


// Will let the user select the places that they want to store and store it using coredata
public class placeViewModel:ObservableObject
{
    @Published var data = [place(name: "Hayden", latitude: 33.419076, longitude: -111.934615, type: "Library", description: "Hayden library is really good place to study. You can book study rooms if needed as well. And the view from the second floor is really good!", image: "hayden"),
                           place(name: "Nobel", latitude: 33.419917, longitude: -111.930664, type: "Library", description: "Library for engineering students.", image: "noble"),
                           place(name: "Design", latitude: 33.4215996, longitude: -111.9367939, type: "Library", description: "Old-styled quite library", image: "design"),
                           place(name: "SDFC", latitude: 33.4152209, longitude: -111.9350959, type: "Gym", description: "Workout!!!", image: "sdfc"),
                           place(name: "Memorial Union", latitude: 33.41769, longitude: -111.934346, type: "Community Center", description: "Good place to hang out with friends.", image: "mu")]
    @Published var sections = ["Library", "Gym", "Community Center"]
//    @Published var placeGroups
    
    func add(place: place) {
        data.append(place)
        print("after adding" + String(data.count))
    }
    
    func removePlace(at index: Int) {
        data.remove(at: index)
    }
    
    func findPlace(place: String) -> Int{
        var loc: Int = 0
        print(place)
        print("count is " + String(data.count))
        for p in data{
            if p.name == place
            {
                print("The size is " + String(data.count))
                return loc
            }  else {
                loc = loc + 1
            }
            print(loc)
        }
        return loc
    }
}


