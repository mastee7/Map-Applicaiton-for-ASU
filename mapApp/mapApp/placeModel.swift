//
//  placeModel.swift
//  mapApp
//
//  Created by Woojeh Chung on 3/19/23.
//

import Foundation


struct Place : Identifiable
{
    var id = UUID()
    var name = String()
    var latitude = Double()
    var longitude = Double()
    var description = String()
}

struct PlaceGroup : Identifiable
{
    var id = UUID()
    var groupName : String
    var places : [place]
}
