//
//  TestView.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 30/12/2022.
//

import SwiftUI

struct FilterScreen: View {
    var body: some View {
        NavigationView {
            List {
                ShoeListView(
                    title: "NEW BALANCE",
                    subtitle: "SNEAKER LOW AIR VAPORMAX 2021 FK DAMEN",
                    price: "220,00€*",
                    image: "image 10"
                )
                ShoeListView(
                    title: "NEW BALANCE",
                    subtitle: "SNEAKER LOW AIR VAPORMAX 2021 FK DAMEN",
                    price: "220,00€*",
                    image: "image 10"
                )
                ShoeListView(
                    title: "NEW BALANCE",
                    subtitle: "SNEAKER LOW AIR VAPORMAX 2021 FK DAMEN",
                    price: "220,00€*",
                    image: "image 10"
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Sportrschuhe fur Drinnen")
                        .font(Font.custom("Roboto-Regular", size: 20))
                }
            }
//            .navigationTitle(
//                Text("Sportrschuhe fur Drinnen")
//                    .font(Font.custom("Roboto-Regular", size: 20))
//            )
        }
    }
}

struct FilterScreen_Previews: PreviewProvider {
    static var previews: some View {
        FilterScreen()
    }
}
