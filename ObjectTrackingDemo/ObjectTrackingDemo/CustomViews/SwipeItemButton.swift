//
//  SwipeItemButton.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 02/01/2023.
//

import SwiftUI

struct LeftItemButton: View {
    @State var sysImage: String
    @State var buttonText: String
    var completion: (() -> Void)?
    
    var body: some View {
            Button {
                completion?()
            } label: {
                VStack(alignment: .center ,spacing: 5) {
                    Image(sysImage)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                    Text(buttonText)
                        .font(Font.custom("Roboto-Regular", size: 10))
                        .foregroundColor(.black)
                }
                .frame(height: 130)
            }
    }
}

struct RightItemButton: View {
    @State var sysImage: String
    @State var buttonText: String
    
    var body: some View {
            Button {} label: {
                VStack(alignment: .center ,spacing: 5) {
                    Image(systemName: sysImage)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                    Text(buttonText)
                        .font(Font.custom("Roboto-Regular", size: 10))
                        .foregroundColor(.black)
                }
                .frame(height: 130)
            }
    }
}
