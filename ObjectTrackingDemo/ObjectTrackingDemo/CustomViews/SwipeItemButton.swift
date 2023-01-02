//
//  SwipeItemButton.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 02/01/2023.
//

import SwiftUI

struct SwipeItemButton: View {
    @State var sysImage: String
    @State var buttonText: String
    var completion: (() -> Void)?
    
    var body: some View {
            Button {
                completion?()
            } label: {
                VStack {
                    Image(systemName: sysImage)
                    Text(buttonText)
                        .font(Font.custom("Roboto-Regular", size: 11))
                }
                .padding(.leading, 5)
                .frame(height: 130)
            }
    }
}
