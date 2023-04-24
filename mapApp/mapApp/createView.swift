//
//  createView.swift
//  mapApp
//
//  Created by Woojeh Chung on 3/19/23.
//

import SwiftUI

struct createView: View {
    
    @State var newUsrId : String = ""
    @State var newUsrPw : String = ""
    @State var newUsrEmail : String = ""
    @State var newUsrPNum : String = ""
    
    @ObservedObject var userVM: userViewModel
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppUser.email, ascending: true)],
        animation: .default)
    private var users:  FetchedResults<AppUser>
    
    init(vm: userViewModel){
        self.userVM = vm
    }
    
    var body: some View {
        VStack{
            Text("")
            Text("ASU Interactive Map")
                .foregroundColor(.blue)
                .font(.title)
                .bold()
            Text("")
            Spacer()
            
            Text("Please enter your informations.")
            Spacer()
            
            // Text Fields
            VStack{
                Text("LOGIN")
                    .foregroundColor(.teal)
                    .font(.title3)
                    .bold()
                Text("")
                HStack{
                    Spacer(minLength: 90)
                    Text("ID: ")
                    TextField("Enter user ID", text: $userVM.usrId,
                    onEditingChanged: { (changed) in
                        print("User Id Entered - \(changed)")
                        
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer(minLength: 90)
                }
                Text("")
                HStack{
                    Spacer(minLength: 90)
                    Text("PW: ")
                    TextField("Enter Password", text: $userVM.usrPw,
                    onEditingChanged: { (changed) in
                        print("User Pw Entered - \(changed)")
                        
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer(minLength: 90)
                }
                Text("")
                HStack{
                    Spacer(minLength: 90)
                    Text("email: ")
                    TextField("Enter email", text: $userVM.email,
                    onEditingChanged: { (changed) in
                        print("User email Entered - \(changed)")
                        
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer(minLength: 90)
                }
                Text("")
                HStack{
                    Spacer(minLength: 90)
                    Text("Phone: ")
                    TextField("Enter phone number", text: $userVM.pNum,
                    onEditingChanged: { (changed) in
                        print("User pNum Entered - \(changed)")
                        
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer(minLength: 90)
                }
            }
            
            Spacer(minLength: 50)
            
            Button(action: {
                            userVM.add()
                        }) {
                            Text("              Create              ")
                                .font(.title3)
                                .padding(7)
                                .cornerRadius(40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.green, lineWidth: 2))
                        }
                        
                        NavigationLink("", destination: ContentView().navigationBarBackButtonHidden(true), isActive: $userVM.navigateToContentView)
        }
    }
}

struct createView_Previews: PreviewProvider {
    static var previews: some View {
        let vc = PersistenceController.shared.container.viewContext
        createView(vm: userViewModel(context: vc)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
