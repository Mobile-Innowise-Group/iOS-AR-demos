//
//  FilterButton.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 09/01/2023.
//

import SwiftUI

struct FilterButton: View {
    var body: some View {
        Button {} label: {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .frame(width: 18, height: 18)
                Text("Filter eingrenzen (884)")
                    .font(Font.custom("Roboto-Regular", size: 14))
            }
            .padding()
            .foregroundColor(.white)
            .background{Color("filterButton")}
            .cornerRadius(15)
        }
    }
}

struct FilterButton_Previews: PreviewProvider {
    static var previews: some View {
        FilterButton()
    }
}
