//
//  ShoeListView.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 02/01/2023.
//

import SwiftUI

struct ShoeListView: View {
    @State var title: String
    @State var subtitle: String
    @State var price: String
    @State var image: String
    var body: some View {
        VStack {
            HStack {
                HStack(alignment: .top) {
                    Image(image)
                        .resizable()
                        .frame(width: 117, height: 117)
                    VStack(alignment: .leading, spacing: 10) {
                        Text(title)
                            .font(Font.custom("Roboto-Bold", size: 14))
                        Text(subtitle)
                            .font(Font.custom("Roboto-Regular", size: 13))
                            .lineLimit(2, reservesSpace: true)
                        Text(price)
                            .font(Font.custom("Roboto-Regular", size: 12))
                            .background {
                                Color.yellow
                            }
                    }
                }
                HStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 3, height: 28)
                        .foregroundColor(.gray)
                        .opacity(0.2)
                }
            }
            Divider()
        }.padding(.leading, 15)
    }
}
