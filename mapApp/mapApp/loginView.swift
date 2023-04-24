//
//  loginView.swift
//  mapApp
//
//  Created by Woojeh Chung on 3/19/23.
//

import SwiftUI
import MapKit

var curr1 = "home"

struct Location: Identifiable{
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct loginView: View {
    
    @State var open = false
    @StateObject var locationDataManager = LocationDataManager()
    @State var isListViewActive = false
    
    // Will be implementing the user location manager to figure out where the user is located 
    //@ObservedObject var usrLocationManager : LocationDataManager
    
    private var defaultLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: locationDataManager.userLocation?.coordinate.latitude ?? 33.4255,
            longitude: locationDataManager.userLocation?.coordinate.longitude ?? -111.9400
        )
    }
    
    func initialRegion() -> MKCoordinateRegion {
        let initialLocation = defaultLocation
        return MKCoordinateRegion(
            center: initialLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    }

    func initialMarkers() -> [Location] {
        return [
            Location(name: "Current Location", coordinate: defaultLocation)
        ]
    }
    
    func updateMarker() {
        if let userLocation = locationDataManager.userLocation {
            region.center = userLocation.coordinate
            markers = [Location(name: "Current Location", coordinate: userLocation.coordinate)]
        }
    }

    
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 33.4255, longitude: -111.9400), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @State private var markers: [Location] = [Location(name: "Current Location", coordinate: CLLocationCoordinate2D(latitude: 33.4255, longitude: -111.9400))]

    
    var body: some View {
        ZStack{
            VStack{
                VStack{
                    Spacer(minLength: 160)
                    HStack {
                        Button(action: {self.open.toggle()}){
                            Image(systemName: "text.justify")
                                .font(.title3)
                                .foregroundColor(Color.white)
                        }
                        Spacer()
                        Image(systemName: "bell")
                            .font(.title2)
                            .foregroundColor(Color.white)
                    }.padding(.horizontal)
                    Spacer(minLength: 10)
                    
                    //Hello! Register to get started
                    Text("ASU ")
                        .foregroundColor(Color(#colorLiteral(red: 0.53, green: 0.13, blue: 0.25, alpha: 1)))
                        .font(.title)
                        .bold()
                    + Text("Interactive Map")
                        .foregroundColor(Color(#colorLiteral(red: 0.12, green: 0.14, blue: 0.17, alpha: 1))).tracking(-0.3)
                        .font(.system(size: 30, design: .rounded))
                        .bold()
                    Spacer(minLength: 30)
                }
                
                Map(coordinateRegion: $region,
                    interactionModes: .all,
                    annotationItems: markers
                ){ location in
                    MapMarker(coordinate: location.coordinate)
                }
                .cornerRadius(25)
                .frame(height: 500)
                .onChange(of: locationDataManager.userLocation, perform: { _ in
                            updateMarker()
                })
                
                Spacer(minLength: 30)
                
                VStack{
                    VStack{
                        NavigationLink(destination: listView().navigationBarBackButtonHidden(true), isActive: $isListViewActive) {
                            EmptyView()
                        }
                        .hidden()
                        Button(action: {
                            self.isListViewActive = true
                        }) {
                            Text("Location List")
                                .font(.system(size: 20, design: .rounded))
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 200, height: 58)
                                .background(
                                    RoundedRectangle(cornerRadius: 23)
                                        .fill(Color(red: 1, green: 0.78, blue: 0.20, opacity: 0.8))
                                )
                        }
                        .offset(y: -70)
                        .buttonStyle(PlainButtonStyle())
                        .navigationBarBackButtonHidden(true)
                    }
                }
                .frame(width: 393, height: 300)
                .background(Color(red: 0.98, green: 0.92, blue: 0.91))
                .cornerRadius(52)
            }
            .opacity(open ? 0.3 : 1)
            Menu(open: $open, curr: curr1)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0.85, blue: 0.85), Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
        )
        .onAppear {
            region = initialRegion()
            markers = initialMarkers()
        }
    }
}

struct Menu: View {
    @Binding var open: Bool
    @State var curr : String
    @AppStorage("userID") private var userID: String = ""
    
    var body: some View {
        VStack{
            VStack{
                HStack{
                    Spacer(minLength: 110)
                    Text("Menu")
                        .font(.system(size: 30, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {self.open.toggle()}){
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .frame(width: 32, height: 32)
                    }.padding(.trailing, 30)
                }
                HStack{
                    Spacer(minLength: 90)
                    VStack{
                        ZStack{
                            Image("default_asu")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                                .padding(.horizontal, 24)
                            
                            Circle()
                                .stroke(.purple)
                                .frame(width: 80, height: 80)
                                .offset(x: 2, y: 1)
                            
                            Circle()
                                .stroke(.green)
                                .frame(width: 80, height: 80)
                                .offset(x: -2, y: -1)
                        }
                        Text(userID)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.top, 10)
                            .padding(.bottom, 40)
                    }
                    Spacer(minLength: 60)
                }
                .padding(.top, 10)
            }
            .padding(.top, 50)
            
            Row(isRow: whereAmI(str: "home"), icon: "house", text: "Home", location: AnyView(loginView()))
            Row(isRow: whereAmI(str: "followers"), icon: "person.3", text: "Followers", location: AnyView(loginView()))
            Row(isRow: whereAmI(str: "map"), icon: "map", text: "Map", location: AnyView(mapView()))
            Row(isRow: whereAmI(str: "locationList"), icon: "list.bullet", text: "Location Lists", location: AnyView(listView()))
            
            
            Spacer(minLength: 300)
            
            Row(isRow: false, icon: "power", text: "Sign Out", location: AnyView(ContentView()))
            Spacer()
            
        }
        .padding(.vertical, 30)
        .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color(red: 0, green: 0.85, blue: 0.85)]), startPoint: .top, endPoint: .bottom))
        .padding(.trailing, 100)
        .offset(x: open ? 0 : -UIScreen.main.bounds.width)
        .animation(.default)
        .onTapGesture {
            self.open.toggle()
        }
        .edgesIgnoringSafeArea(.vertical)
        .frame(height: 900)
        .cornerRadius(52)
    }
    func whereAmI(str : String) -> Bool {
        if str == curr  {
            return true
        }   else {
            return false
        }
    }
}

// This is for the row inside the menu view
struct Row: View {
    var isRow: Bool
    var icon = "house"
    var text = "Dashboard"
    var location : AnyView
    
    var body: some View {
        NavigationLink(destination: location.navigationBarBackButtonHidden(true)){
            HStack{
                Image(systemName: icon)
                    .foregroundColor(isRow ? .purple : .white)
                    .font(.system(size: 20, weight: isRow ? .heavy : .regular))
                    .frame(width: 48, height: 32)
                Text(text)
                    .foregroundColor(isRow ? .purple : .white)
                    .font(.system(size: 17, weight: isRow ? .bold : .regular))
                
                Spacer()
            }
            .padding(4)
            .padding(.leading, 9)
            .background(isRow ? .white : .white.opacity(0))
            .padding(.trailing, 60)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .offset(x: 60)
        }.navigationBarBackButtonHidden(true)
    }
}


struct loginView_Previews: PreviewProvider {
    static var previews: some View {
        loginView()
    }
}
