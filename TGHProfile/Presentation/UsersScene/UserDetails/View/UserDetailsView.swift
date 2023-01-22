//
//  UserDetailsView.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 29/12/2022.
//

import Foundation
import SwiftUI
import Combine

@available(iOS 13.0, *)
struct UserDetailsView: View {
    @ObservedObject var viewModelWrapper: UserDetailsViewModelWrapper
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var noteString: String = ""
    @State var text: String = ""

    var body: some View {
        List {
            VStack(spacing: 8) {
                Image(uiImage: viewModelWrapper.profileImageData != nil ? (UIImage(data: viewModelWrapper.profileImageData!) ?? UIImage(named: "placeholder"))! : UIImage(named: "placeholder")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 10)
                HStack(spacing: 30) {
                    Text("followers: \(viewModelWrapper.followers)")
                    Text("following: \(viewModelWrapper.following)")
                }
                Spacer().frame(height: 20)
                HStack() {
                    VStack(alignment: .leading) {
                        Text("name: \(viewModelWrapper.username)")
                        Text("company: \(viewModelWrapper.company)")
                        Text("blog: \(viewModelWrapper.blog)")
                        Spacer().frame(height: 20)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .border(.black, width: 2)
                }.padding()
                
                VStack(alignment: .leading) {
                    Text("Notes")
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                
                HStack() {
                    TextEditor(text: $noteString)
                        .frame(minHeight: 30, alignment: .leading)
                        .border(Color.black, width: 2)
                        .multilineTextAlignment(.leading)
                }.padding(.horizontal)
                
                Spacer().frame(height: 20)
                HStack() {
                    Button("Save") {
                        self.viewModelWrapper.viewModel?.didTapSave(noteString: noteString.description, completion: {
                            self.presentationMode.wrappedValue.dismiss()
                        })
                    }.padding(.bottom, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .buttonStyle(MyStyle())
                }.padding(.horizontal)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                self.viewModelWrapper.viewModel?.viewWillAppear()
                noteString = viewModelWrapper.note
            }
            

        }
    }
}

struct MyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
    }
}

@available(iOS 13.0, *)
final class UserDetailsViewModelWrapper: ObservableObject {
    var viewModel: UserDetailsViewModel?
    @Published var username: String = ""
    @Published var company: String = ""
    @Published var blog: String = ""
    @Published var following: Int = 0
    @Published var followers: Int = 0
    @Published var profileImageData: Data? = nil
    @Published var note: String = ""
    var subsciptions = Set<AnyCancellable>()
    
    init(viewModel: UserDetailsViewModel?) {
        self.viewModel = viewModel
        viewModel?.username.sink { [weak self] value in self?.username = value }.store(in: &subsciptions)
        viewModel?.company.sink { [weak self] value in self?.company = value }.store(in: &subsciptions)
        viewModel?.blog.sink { [weak self] value in self?.blog = value }.store(in: &subsciptions)
        viewModel?.following.sink { [weak self] value in self?.following = value }.store(in: &subsciptions)
        viewModel?.followers.sink { [weak self] value in self?.followers = value }.store(in: &subsciptions)
        viewModel?.profileImageData.sink { [weak self] value in self?.profileImageData = value }.store(in: &subsciptions)
        viewModel?.note.sink { [weak self] value in self?.note = value }.store(in: &subsciptions)
    }
}

#if DEBUG
struct UserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsView(viewModelWrapper: previewViewModelWrapper)
    }
    
    static var previewViewModelWrapper: UserDetailsViewModelWrapper = {
        var viewModel = UserDetailsViewModelWrapper(viewModel: nil)
        return viewModel
    }()
}
#endif
