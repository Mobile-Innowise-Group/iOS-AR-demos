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
            HStack(alignment: .top) {
                Image(image)
                    .resizable()
                    .frame(width: 117, height: 117)
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(Font.custom("Roboto-Bold", size: 14))
                    Text(subtitle)
                        .font(Font.custom("Roboto-Regular", size: 13))
                    Text(price)
                        .font(Font.custom("Roboto-Regular", size: 12))
                        .background {
                            Color.yellow
                        }
                }
            }
        }
    }
}

struct ShoeListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoeListView(title: "NEW BALANCE", subtitle: "SNEAKER LOW AIR VAPORMAX 2021 FK DAMEN", price: "220,00€*", image: "image 10")
    }
}
