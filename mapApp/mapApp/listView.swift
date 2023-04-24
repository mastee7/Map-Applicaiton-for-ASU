//
//  listView.swift
//  mapApp
//
//  Created by Woojeh Chung on 3/19/23.
//

// list idea from https://thehappyprogrammer.com/custom-list-in-swiftui

import SwiftUI

var curr3 = "locationList"

// creating a blur tags
struct blurTags: View{
    var tags: Array<String>
        let namespace: Namespace.ID
        var body: some View {
            HStack {
                ForEach(tags, id: \.self) { tag in
                    Text("\(tag)")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .font(.caption)

                }
            }.matchedGeometryEffect(id: "tags", in: namespace)
        }
}

struct BlurView: UIViewRepresentable {
    
    let style: UIBlurEffect.Style
    
    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIView,
                      context: UIViewRepresentableContext<BlurView>) {
        
    }
}

struct smallcardView: View {

    var p: place
    let namespace: Namespace.ID

    var body: some View {
        GeometryReader { g in
            VStack(alignment: .leading) {
                HStack {
                    Image(p.image)
                        .resizable()
                        .frame(width: 120, height: 90)
                        .cornerRadius(10)
                        .matchedGeometryEffect(id: "image", in: namespace)

                    VStack(alignment: .leading) {
                        Spacer()
                        Text(p.name)
                            .foregroundColor(Color.teal)
                            .matchedGeometryEffect(id: "title", in: namespace)
                        Spacer()
                        HStack {
                            Text(p.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .matchedGeometryEffect(id: "ratingNum", in: namespace)
                                .multilineTextAlignment(.leading)
                        }
                    }.padding(.leading)
                    Spacer()
                    VStack {
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color.white)
                            .matchedGeometryEffect(id: "ellipsis", in: namespace)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct bigcardView: View {
    var p: place
    let namespace: Namespace.ID
    @ObservedObject var placeVM: placeViewModel
    
    var body: some View {
        NavigationLink(destination: listDetailView(currPlace: p, placeVM: placeVM)){
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Image(p.image)
                        .resizable()
                        .frame(height: 150)
                        .frame(maxHeight: .infinity)
                        .cornerRadius(10)
                        .matchedGeometryEffect(id: "image", in: namespace)
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(p.name)
                            .foregroundColor(Color.teal)
                            .matchedGeometryEffect(id: "title", in: namespace)
                        Spacer()
                        HStack {
                            Text(p.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .matchedGeometryEffect(id: "ratingNum", in: namespace)
                        }
                    }
                    Spacer()
                    VStack {
                        Spacer()
                    }
                }
            }
        }
    }
}

enum CardPosition: CaseIterable {
    case small, big
}

struct CardDetector: View {

    var p: place
    @State var position: CardPosition
    @Namespace var namespace
    @ObservedObject var placeVM: placeViewModel
    
    var body: some View {

            Group {
                switch position {
                case .small:
                    smallcardView(p: p, namespace: namespace)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(BlurView(style: .regular))
                        .cornerRadius(10)
                        .padding(.vertical,6)
                        .onLongPressGesture {
                            withAnimation {
                                position = .big
                            }
                        }.padding(.horizontal)
                case .big:
                    bigcardView(p: p, namespace: namespace, placeVM: placeVM)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 270)
                        .background(BlurView(style: .regular))
                        .cornerRadius(10)
                        .padding(.vertical,6)
                        .onLongPressGesture {
                            withAnimation {
                                position = .small
                            }
                        }.padding(.horizontal)
                }
            }
        }
}

struct listView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var placeVM = placeViewModel()
    @State var small = true
    @State var open = false
    @Namespace var namespace
    @State private var position: CardPosition = .small
    @State var isMapViewActive = false
    @State var isPlusPresented = false
    @State var placeName = String()
    @State var placeType = String()
    @State var latitude = Double()
    @State var longitude = Double()
    @State var description = String()
    
    
    var body: some View {
        NavigationView{
            ZStack{
                VStack {
                    VStack{
                        Spacer(minLength: 250)
                        //Hello! Register to get started
                        HStack {
                            Button(action: {self.open.toggle()}){
                                Image(systemName: "text.justify")
                                    .font(.title3)
                                    .foregroundColor(Color.white)
                            }
                            Spacer()
                            Button(action: {
                                isPlusPresented = true
                            }){
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(Color.white)
                            }
                            .alert("Please enter place data.", isPresented: $isPlusPresented, actions: {
                                TextField("Place name", text: $placeName)
                                TextField("Place type", text: $placeType)
                                TextField("Description", text: $description)
                                Button("OK", action: {
                                    print("Adding place \(placeName) into the database...")
                                    placeVM.add(place: place(name: placeName, latitude: 0.0, longitude: 0.0, type: placeType, description: description, image: "default_asu"))
                                })
                                Button("Cancel", role:.cancel, action:{})
                            })
                        }.padding(.horizontal)
                        Text("ASU ")
                            .foregroundColor(Color(#colorLiteral(red: 0.53, green: 0.13, blue: 0.25, alpha: 1)))
                            .font(.title)
                            .bold()
                        + Text("Interactive Map")
                            .foregroundColor(Color(#colorLiteral(red: 0.12, green: 0.14, blue: 0.17, alpha: 1))).tracking(-0.3)
                            .font(.system(size: 30, design: .rounded))
                            .bold()
                        Capsule()
                            .fill(Color(red: 1, green: 0.78, blue: 0.20, opacity: 0.8))
                            .frame(width: 200, height: 200)
                            .opacity(0.3)
                            .offset(x: -150, y: -55)
                        Spacer()
                        Capsule()
                            .fill(Color(red: 1, green: 0.78, blue: 0.20, opacity: 0.8))
                            .frame(width: 200, height: 200)
                            .opacity(0.3)
                            .offset(x: 150, y: 105)
                    }
                    .offset(y: 10)
                    
                    VStack{
                        ScrollView {
                            VStack {
                                ForEach(placeVM.data, id: \.id) { place in
                                    NavigationLink(destination: listDetailView(currPlace: place, placeVM: placeVM)) {
                                        CardDetector(p : place, position : self.position, placeVM: placeVM)
                                    }
                                }
                            }
                        }
                        .frame(height: 540)
                        .offset(y:-380)
                        ZStack{
                            NavigationLink(destination: mapView().navigationBarBackButtonHidden(true), isActive: $isMapViewActive) {
                                EmptyView()
                            }
                            .hidden()
                            Button(action: {
                                self.isMapViewActive = true
                            }) {
                                Text("Back to Map")
                                    .font(.system(size: 20, design: .rounded))
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 58)
                                    .background(
                                        RoundedRectangle(cornerRadius: 23)
                                            .fill(Color(red: 1, green: 0.78, blue: 0.20, opacity: 0.8))
                                    )
                            }
                            .offset(y: -10)
                            .buttonStyle(PlainButtonStyle())
                            .navigationBarBackButtonHidden(true)
                            
                        }
                        .frame(width: 393, height: 150)
                        .background(Color(red: 0.98, green: 0.92, blue: 0.91))
                        .cornerRadius(52)
                        .position(x : 196.5, y : -300)
                    }
                }
                .opacity(open ? 0.3 : 1)
                Menu(open: $open, curr: curr3)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0.85, blue: 0.85), Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            )
        }
    }
}

struct listView_Previews: PreviewProvider {
    static var previews: some View {
        listView()
    }
}
