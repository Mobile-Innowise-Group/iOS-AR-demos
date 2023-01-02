//
//  DetailShoeScreen.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 02/01/2023.
//

import SwiftUI

struct DetailShoeScreen: View {
    @State private var showAlert: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                Image("airForce")
                    .resizable()
                    .frame(height: 350)
                VStack(alignment: .leading) {
                    Button {
                        self.showAlert = true
                    } label: {
                        Image(systemName: "arkit")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                    }
                    .padding([.leading, .bottom], 15)
                    RoundedRectangle(cornerRadius: 8)
                        .overlay {
                            Text("NIKE")
                                .font(Font.custom("Roboto-Regular", size: 12))
                                .foregroundColor(.white)
                        }
                        .frame(width: 47, height: 32)
                        .padding(.leading, 15)
                    Text("Sneaker low Air Max 97 SE W Damen")
                        .lineLimit(2, reservesSpace: true)
                        .font(Font.custom("Roboto-Bold", size: 26))
                        .padding(.leading, 15)
                    HStack {
                        RoundedRectangle(cornerRadius: 1)
                            .overlay {
                                HStack {
                                    VStack {
                                        Image(systemName: "star.fill")
                                            .frame(width: 17, height: 17)
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 29, height: 29)
                                    .background(Color.gray)
                                    Text("Keine Bewertungen")
                                        .font(Font.custom("Roboto-Regular", size: 12))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(width: 154, height: 29)
                            .foregroundColor(.clear)
                        Spacer()
                        Text("190,00€*")
                            .frame(width: 95, height: 29)
                            .background {
                                Color.yellow
                            }
                            .padding(.trailing, 15)
                    }.padding(.leading, 10)
                    Text("Produktinformation")
                        .font(Font.custom("Roboto-Bold", size: 20))
                        .padding()
                    Text("ID: 5bc3f493-8...")
                        .font(Font.custom("Roboto-Regular", size: 12))
                        .padding()
                }
                VStack {
                    HStack {
                        Circle()
                            .frame(width: 9, height: 9)
                            .foregroundColor(.green)
                        Text("Verfugbar")
                        Spacer()
                        Text("38,39")
                    }.padding()
                    Button {} label: {
                        RoundedRectangle(cornerRadius: 8)
                            .overlay {
                                HStack {
                                    Spacer()
                                    Text("Auswählen")
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "cart")
                                        .resizable()
                                        .foregroundColor(.black)
                                        .frame(width: 18, height: 18)
                                        .padding(.trailing, 10)
                                }
                            }
                            .foregroundColor(Color.yellow)
                    }.frame(height: 43)
                    .padding([.leading, .trailing], 25)
                }
            }
        }.toolbar(.hidden, for: .tabBar)
    }
}

struct DetailShoeScreen_Previews: PreviewProvider {
    static var previews: some View {
        DetailShoeScreen()
    }
}
