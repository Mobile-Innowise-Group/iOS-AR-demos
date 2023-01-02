//
//  TestView.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 30/12/2022.
//

import SwiftUI

struct FilterScreen: View {
    @State private var showDetail: Bool = false
    var items: [ShoeModel] = [
        ShoeModel(
            title: "NEW BALANCE",
            subtitle: "SNEAKER LOW AIR VAPORMAX 2021 FK DAMEN",
            price: "220,00€*",
            image: "image1"
        ),
        ShoeModel(
            title: "TIMBERLAND",
            subtitle: "TURNSCHUHE PREMIUM 6-INCH BOOT WOMEN TIMBERLAND",
            price: "219,99€*",
            image: "image4"
        ),
        ShoeModel(
            title: "NIKE",
            subtitle: "SNEAKER LOW AIR MAX 97 SE W DOMEN",
            price: "190,00€*",
            image: "image3"
        ),
        ShoeModel(
            title: "ASICS",
            subtitle: "LOW GEL SNEAKERS-KINSEI OG WOMEN",
            price: "189,95€*",
            image: "image4"
        )
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(items) { item in
                        SwipeItem(
                            content: {
                                ShoeListView(
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    price: item.price,
                                    image: item.image
                                )
                            }, left: {
                                Button {} label: {
                                    FakeSwipeItem()
                                }
                            }, right: {
                                Button {} label: {
                                    LeftSwipeItem {
                                        self.showDetail = true
                                    }
                                }
                                .navigationDestination(isPresented: $showDetail) {
                                    DetailShoeScreen()
                                }
                            }, itemHeight: 130)
                    }
                }
            }
//                List(items, id: \.self) { item in
//                    SwipeItem(
//                        content: {
//                            ShoeListView(
//                                title: item.title,
//                                subtitle: item.subtitle,
//                                price: item.price,
//                                image: item.image
//                            )
//                        }, left: {
//                            Button {} label: {
//                                FakeSwipeItem()
//                            }
//                        }, right: {
//                            Button {} label: {
//                                LeftSwipeItem {
//                                    self.showDetail = true
//                                }
//                            }
//                            .navigationDestination(isPresented: $showDetail) {
//                                DetailShoeScreen()
//                            }
//                        }, itemHeight: 130)
//                }
                .listStyle(.grouped)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Text("Sportrschuhe fur Drinnen")
                                    .font(Font.custom("Roboto-Bold", size: 20))
                            }
                        }
        }
    }
}

struct FilterScreen_Previews: PreviewProvider {
    static var previews: some View {
        FilterScreen()
    }
}
