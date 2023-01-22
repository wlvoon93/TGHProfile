//
//  UserDetailsView.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 29/12/2022.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
struct UserDetailsView: View {
    @ObservedObject var viewModelWrapper: UserDetailsViewModelWrapper
    var body: some View {
        List {
            VStack(spacing: 8) {
                RemoteImageView(
                  urlString: viewModelWrapper.avatarUrl,
                  placeholder: {
                    Image("placeholder").frame(width: 40) // etc.
                  },
                  image: {
                    $0.resizable().aspectRatio(UIImage(named: "profile_picture")!.size, contentMode: .fill)
                  }
                )
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
                    VStack(alignment: .leading) {
                        Text("name: John")
                        Text("company: Apple")
                        Text("blog: www.apple.com")
                        Spacer().frame(height: 20)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .border(.black, width: 2)
                }.padding(.horizontal)
                
                Spacer().frame(height: 20)
                Button("Save") {
                    
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                self.viewModelWrapper.viewModel?.viewWillAppear()
            }
        }
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
    @Published var avatarUrl: String = ""
    
    init(viewModel: UserDetailsViewModel?) {
        self.viewModel = viewModel
        viewModel?.username.observe(on: self) { [weak self] value in self?.username = value }
        viewModel?.company.observe(on: self) { [weak self] value in self?.company = value }
        viewModel?.blog.observe(on: self) { [weak self] value in self?.blog = value }
        viewModel?.following.observe(on: self) { [weak self] value in self?.following = value }
        viewModel?.followers.observe(on: self) { [weak self] value in self?.followers = value }
        viewModel?.avatarUrl.observe(on: self) { [weak self] value in self?.avatarUrl = value }
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
