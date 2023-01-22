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
                Spacer().frame(height: 30)
                Image(uiImage: viewModelWrapper.profileImageData != nil ? (UIImage(data: viewModelWrapper.profileImageData!) ?? UIImage(named: "placeholder"))! : UIImage(named: "placeholder")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 10)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 30) {
                        Text("Followers: ").font(Font.headline.weight(.bold))
                        Text("\(viewModelWrapper.followers)")
                    }
                    HStack(spacing: 30) {
                        Text("Following: ").font(Font.headline.weight(.bold))
                        Text("\(viewModelWrapper.following)")
                    }
                }
                Spacer().frame(height: 10)
                HStack() {
                    VStack(alignment: .leading) {
                        Text("Name:").font(Font.headline.weight(.bold))
                        Text(viewModelWrapper.username).fixedSize(horizontal: false, vertical: true)
                        Spacer().frame(height: 10)
                        Text("Company:").font(Font.headline.weight(.bold))
                        Text(viewModelWrapper.company).fixedSize(horizontal: false, vertical: true)
                        Spacer().frame(height: 10)
                        Text("Blog:").font(Font.headline.weight(.bold))
                        Text(viewModelWrapper.blog).fixedSize(horizontal: false, vertical: true)
                        Spacer().frame(height: 20)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .border(.black, width: 2)
                }.padding()
                
                VStack(alignment: .leading) {
                    Text("Notes").font(Font.headline.weight(.bold))
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
                            DispatchQueue.main.async {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        })
                    }
                    .buttonStyle(MyStyle())
                }.padding(.horizontal)
                Spacer().frame(height: 30)
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
            .frame(maxWidth: 100, maxHeight: 50)
            .contentShape(Rectangle())
            .border(Color.gray, width: 5)
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
        viewModel?.username.receive(on: DispatchQueue.main).sink { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.username = value
        }.store(in: &subsciptions)
        
        viewModel?.company.receive(on: DispatchQueue.main).sink { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.company = value
        }.store(in: &subsciptions)
        
        viewModel?.blog.receive(on: DispatchQueue.main).sink { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.blog = value
        }.store(in: &subsciptions)
        
        viewModel?.following.receive(on: DispatchQueue.main).sink { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.following = value
        }.store(in: &subsciptions)
        
        viewModel?.followers.receive(on: DispatchQueue.main).sink { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.followers = value
        }.store(in: &subsciptions)
        
        viewModel?.profileImageData.receive(on: DispatchQueue.main).sink { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.profileImageData = value
        }.store(in: &subsciptions)
        
        viewModel?.note.receive(on: DispatchQueue.main).sink { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.note = value
        }.store(in: &subsciptions)
        
        viewModel?.error.receive(on: DispatchQueue.main).sink { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.showError(value)
        }.store(in: &subsciptions)
        
        setupReachability()
    }
    
    func showError(_ error: String) {
        _ = Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("Got it!")))
    }
    
    private func setupReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(showOfflineDeviceUI(notification:)), name: NSNotification.Name.connectivityStatus, object: nil)
    }
    
    @objc func showOfflineDeviceUI(notification: Notification) {
        if NetworkMonitor.shared.isConnected {
            print("Connected")
            viewModel?.load()
        } else {
            print("Not connected")
            viewModel?.handleReachabilityNoInternet()
        }
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
