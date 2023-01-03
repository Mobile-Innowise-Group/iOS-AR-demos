//
//  BewertungenLabel.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 03/01/2023.
//

import SwiftUI

struct BewertungetLabel: View {
    var body: some View {
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
                    }.padding(.leading, -12)
                .frame(width: 154, height: 29)
                .foregroundColor(.clear)
    }
}

struct Bewertungen_Previews: PreviewProvider {
    static var previews: some View {
        BewertungetLabel()
    }
}
