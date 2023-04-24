//
//  ContentView.swift
//  mapApp
//
//  Created by Woojeh Chung on 3/19/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var usrId : String = ""
    @State var usrPw : String = ""
    @State private var showingAlert = false
    @State private var navigateToLoginView = false
    @State var isCreateView = false
    @StateObject var placeVM: placeViewModel = placeViewModel()
    @AppStorage("userID") private var userID: String = ""
    @State var placeholder : String = ""
    
    var body: some View {
        NavigationView {
            VStack{
                Spacer(minLength: 230)
                //Hello! Register to get started
                Text("ASU ")
                    .foregroundColor(Color(#colorLiteral(red: 0.53, green: 0.13, blue: 0.25, alpha: 1)))
                    .font(.title)
                    .bold()
                + Text("Interactive Map")
                    .foregroundColor(Color(#colorLiteral(red: 0.12, green: 0.14, blue: 0.17, alpha: 1))).tracking(-0.3)
                    .font(.system(size: 30, design: .rounded))
                    .bold()
                Spacer(minLength: 50)
                Image("mapicon")
                    .resizable()
                    .scaledToFit()
                    .frame(height:100)
                Spacer(minLength: 60)
                
                VStack{
                    Spacer(minLength: 100)
                    
                    // Text Fields
                    VStack{
                        Spacer(minLength: 20)
                        Text("Please Login")
                            .foregroundColor(.gray)
                            .font(.system(size: 25, design: .rounded))
                        Text("")
                        Spacer(minLength: 20)
                        HStack{
                            Spacer(minLength: 90)
                            TextField("Enter ID", text: $usrId,
                            onEditingChanged: { (changed) in
                                print("User Id Entered - \(changed)")
                                
                            })
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            .frame(width: 300, height: 58)
                            .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 1.5)
                            )                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            Spacer(minLength: 90)
                        }
                        Text("")
                        HStack{
                            Spacer(minLength: 90)
                            TextField("Enter Password", text: $usrPw,
                            onEditingChanged: { (changed) in
                                print("User Pw Entered - \(changed)")
                                
                            })
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            .frame(width: 300, height: 58)
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
                            Spacer(minLength: 90)
                        }
                    }
                    
                    Spacer(minLength: 70)

                    //Buttons
                    VStack{
                        NavigationLink(destination: loginView(), isActive: $navigateToLoginView) {
                            Button(action: {
                                if usrId.isEmpty || usrPw.isEmpty {
                                    showingAlert = true
                                } else {
                                    let userVM = userViewModel(context: viewContext)
                                    if let _ = userVM.fetchUser(withId: usrId, password: usrPw) {
                                        let loggedInUserID = usrId
                                        userID = loggedInUserID
                                        navigateToLoginView = true
                                    } else {
                                        showingAlert = true
                                    }
                                }
                            }) {
                                Text("Log in")
                                    .font(.system(size: 20, design: .rounded))
                                    .bold()
                                    .padding(7)
                                    .frame(width: 335, height: 58)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 23)
                                            .fill(Color(red: 1, green: 0.78, blue: 0.20, opacity: 0.8))
                                    )
                            }
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text("Login Failed"), message: Text("Invalid username or password. Please try again."), dismissButton: .default(Text("OK")))
                        }
                        
                        Text("")
                        
                        NavigationLink(destination: createView(vm: userViewModel(context: PersistenceController.shared.container.viewContext)).navigationBarBackButtonHidden(true), isActive: $isCreateView) {
                            EmptyView()
                        }
                        .hidden()
                        Button(action: {
                            self.isCreateView = true
                        }) {
                            Text("Location List")
                                .font(.system(size: 20, design: .rounded))
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 335, height: 58)
                                .background(
                                    RoundedRectangle(cornerRadius: 23)
                                        .fill(Color(red: 1, green: 0.78, blue: 0.20, opacity: 0.8))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .navigationBarBackButtonHidden(true)
                    }
                    
                    Spacer(minLength: 50)
                    
                    // Credential
                    VStack{
                        Text("Woojeh Chung")
                            .foregroundColor(.teal)
                            .font(.body)
                            .bold()
                        Text("CSE 335")
                            .foregroundColor(.teal)
                            .font(.body)
                            .bold()
                    }
                    Spacer(minLength: 150)
                }
                .padding(.horizontal, 29)
                .padding(.top, 26)
                .padding(.bottom, 170)
                .frame(width: 393, height: 700)
                .background(Color(red: 0.98, green: 0.92, blue: 0.91))
                .cornerRadius(52)
            }
            .padding(.top, 22)
            .frame(width: 393, height: 852)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0.85, blue: 0.85), Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            )
        }
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
