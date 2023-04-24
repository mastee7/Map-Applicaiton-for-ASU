//
//  listDetailView.swift
//  mapApp
//
//  Created by Woojeh Chung on 3/30/23.
//

import SwiftUI
import MapKit

struct listDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let currPlace : place
    @ObservedObject var placeVM: placeViewModel
    
    @State private var coor_location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var region = MKCoordinateRegion()
    @State private var markers: [Location] = []
    @State var showingDeleteAlarm = false
    
    
    var body: some View {
        ZStack{
            ScrollView{
                VStack(){
                    Image(currPlace.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height:180)
                        .cornerRadius(10)
                    Text(currPlace.description)
                        .padding(50)
                        .navigationTitle(currPlace.name)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(role: .destructive, action:
                                        {
                                    showingDeleteAlarm = true
                                },
                                       label: {
                                    Image(systemName: "trash")
                                })
                                .alert("Delete Record", isPresented: $showingDeleteAlarm, actions:{
                                    Button("Delete", action:{
                                        let x = placeVM.findPlace(place: currPlace.name)
                                        print("index is" + String(x))
                                        placeVM.removePlace(at: x)
                                        dismiss()
                                        showingDeleteAlarm = false
                                    })
                                    Button("Cancel", role: .cancel, action: {
                                        showingDeleteAlarm = false
                                    })
                                }, message: {
                                    Text("Are you sure you want to delete \(currPlace.name)?")
                                })
                            }
                        }
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0.85, blue: 0.85), Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                    )
                    VStack{
                        Map(coordinateRegion: $region,
                            interactionModes: .all,
                            annotationItems: markers
                        ){ location in
                            MapAnnotation(coordinate: location.coordinate){
                                Image(systemName: "pin.circle.fill").foregroundColor(.green)
                                Text(location.name)
                            }
                        }
                        .frame(width: 400, height: 500)
                        .cornerRadius(40)
                        .onAppear{
                            coor_location = CLLocationCoordinate2D(latitude: currPlace.latitude, longitude: currPlace.longitude)
                            region.center = coor_location
                            region.span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                            markers = [Location(name: currPlace.name, coordinate: coor_location)]
                        }
                    }
                }
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0.85, blue: 0.85), Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
        )
    }
}

