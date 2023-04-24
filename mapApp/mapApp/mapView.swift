//
//  mapView.swift
//  mapApp
//
//  Created by Woojeh Chung on 4/21/23.
//

import SwiftUI
import MapKit

var curr2 = "map"

class WalkingTimeAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var walkingTime: TimeInterval

    init(coordinate: CLLocationCoordinate2D, walkingTime: TimeInterval) {
        self.coordinate = coordinate
        self.walkingTime = walkingTime
    }

    var title: String? {
        return "Estimated walking time: \(Int(walkingTime / 60)) minutes"
    }
}


struct mapView: View {
    @State var open = false
    @StateObject var locationDataManager = LocationDataManager()
    @StateObject var weatherAPI  = WeatherAPI()
    @State private var startingLocation = ""
    @State private var destinationLocation = ""
    @State var isListViewActive = false
    @State private var routePolyline: MKPolyline? = nil
    @State private var estimatedWalkingTime: TimeInterval? = nil
    @State var longitude: String = ""
    @State var latitude: String = ""
    @State var walkingTimeAnnotation: WalkingTimeAnnotation? = nil
    @State private var routeMapViewHeight: CGFloat = 0

    
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


    // To get a route from one location to another using forwardGeocoding
    // And going to calculate the midpoint of the start and the destination
    func getRoute() {
        searchForLocation(locationName: startingLocation) { (startingLocationName, startingCoordinate) in
            searchForLocation(locationName: destinationLocation) { (destinationLocationName, destinationCoordinate) in
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: startingCoordinate))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
                request.transportType = .walking
                
                let directions = MKDirections(request: request)
                directions.calculate { (response, error) in
                    if let error = error {
                        print("Error calculating route: \(error.localizedDescription)")
                        return
                    }
                    if let route = response?.routes.first {
                        let newRegion = MKCoordinateRegion(route.polyline.boundingMapRect)
                        region = newRegion
                        
                        markers = [
                            Location(name: startingLocationName, coordinate: startingCoordinate),
                            Location(name: destinationLocationName, coordinate: destinationCoordinate)
                        ]
                        
                        // Add the walking time annotation
                        if let estimatedWalkingTime = estimatedWalkingTime {
                            let midLatitude = (startingCoordinate.latitude + destinationCoordinate.latitude) / 2
                            let midLongitude = (startingCoordinate.longitude + destinationCoordinate.longitude) / 2
                            let midCoordinate = CLLocationCoordinate2D(latitude: midLatitude, longitude: midLongitude)
                            walkingTimeAnnotation = WalkingTimeAnnotation(coordinate: midCoordinate, walkingTime: estimatedWalkingTime)
                        }
                        
                        // Drawing the route on the map
                        routePolyline = route.polyline
                                    
                        // Store the estimated walking time
                        estimatedWalkingTime = route.expectedTravelTime
                        
                        // Update the height of RouteMapView
                        routeMapViewHeight = 100

                        // Calculate the midpoint and fetch the weather data
                        let midLatitude = (startingCoordinate.latitude + destinationCoordinate.latitude) / 2
                        let midLongitude = (startingCoordinate.longitude + destinationCoordinate.longitude) / 2
                        latitude = "\(midLatitude)"
                        longitude = "\(midLongitude)"
                        fetchWeatherData()
                    }
                }
            }
        }
    }

    func searchForLocation(locationName: String, completion: @escaping (String, CLLocationCoordinate2D) -> ()) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = locationName
        searchRequest.region = region
        
        MKLocalSearch(request: searchRequest).start { response, error in
            guard let response = response, let firstItem = response.mapItems.first else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            
            completion(firstItem.name ?? "", firstItem.placemark.coordinate)
        }
    }
    
    // Fetching the weather data by calling API
    func fetchWeatherData() {
            weatherAPI.fetchWeatherData(latitude: latitude, longitude: longitude)
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
                
                RouteMapView(region: $region,
                             markers: $markers,
                             routePolyline: $routePolyline,
                             walkingTimeAnnotation: $walkingTimeAnnotation)
                    .cornerRadius(25)
                    .frame(height: 400 - routeMapViewHeight)
                    .onChange(of: locationDataManager.userLocation, perform: { _ in
                        updateMarker()
                })
                
                Spacer(minLength: 30)
                
                VStack{
                    VStack{
                        HStack{
                            TextField("To", text: $startingLocation)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                                .frame(width: 150, height: 45)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 1.5)
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .inset(by: 1.5)
                                        .fill(Color.white)
                                )
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                            TextField("From", text: $destinationLocation)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                                .frame(width: 150, height: 45)
                                .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 1.5)
                                )
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                        }
                        .offset(y: -70)
                        
                        if let walkingTime = estimatedWalkingTime {
                            Text("Estimated walking time: \(Int(walkingTime / 60)) minutes")
                                .font(.system(size: 18, design: .rounded))
                                .bold()
                                .foregroundColor(.black)
                                .offset(y: -60)
                        }
                        
                        // Display weather information
                        if let weather = weatherAPI.currentWeather {
                            VStack{
                                Text("Temperature: \(String(format: "%.2f", weather.temp_f))°F")
                                    .font(.system(size: 16, design: .rounded))
                                    .bold()
                                    .foregroundColor(.black)
                                Text("Condition: \(weather.condition.text)")
                                    .font(.system(size: 16, design: .rounded))
                                    .bold()
                                    .foregroundColor(.black)
                                Text("Humidity: \(weather.humidity)%")
                                    .font(.system(size: 16, design: .rounded))
                                    .bold()
                                    .foregroundColor(.black)
                                Text("UV Index: \(String(format: "%.2f",weather.uv))")
                                    .font(.system(size: 16, design: .rounded))
                                    .bold()
                                    .foregroundColor(.black)
                            }.offset(y: -50)
                        }
                        
                        Button(action: {
                            getRoute()
                            fetchWeatherData()
                        }) {
                            Text("Get Route")
                                .font(.system(size: 20, design: .rounded))
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 200, height: 58)
                                .background(
                                    RoundedRectangle(cornerRadius: 23)
                                        .fill(Color(red: 1, green: 0.78, blue: 0.20, opacity: 0.8))
                                )
                        }
                        .offset(y: -50)
                        .buttonStyle(PlainButtonStyle())
                        .navigationBarBackButtonHidden(true)
                        
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
                        .offset(y: -30)
                        .buttonStyle(PlainButtonStyle())
                        .navigationBarBackButtonHidden(true)
                    }
                }
                .frame(width: 393, height: routeMapViewHeight + 400)
                .background(Color(red: 0.98, green: 0.92, blue: 0.91))
                .cornerRadius(52)
            }
            .opacity(open ? 0.3 : 1)
            Menu(open: $open, curr: curr2)
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

struct RouteMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var markers: [Location]
    @Binding var routePolyline: MKPolyline?
    @Binding var walkingTimeAnnotation: WalkingTimeAnnotation?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(markers.map { location -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = location.name
            return annotation
        })

        if let polyline = routePolyline {
            uiView.removeOverlays(uiView.overlays)
            uiView.addOverlay(polyline)
        }
        
        if let walkingTimeAnnotation = walkingTimeAnnotation {
            uiView.addAnnotation(walkingTimeAnnotation)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteMapView

        init(_ parent: RouteMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .red
            renderer.lineWidth = 3
            return renderer
        }
    }
}


struct mapView_Previews: PreviewProvider {
    static var previews: some View {
        mapView()
    }
}
