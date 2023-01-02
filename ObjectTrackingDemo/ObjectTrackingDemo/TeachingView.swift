//
//  TeachingView.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 02/01/2023.
//

import SwiftUI

struct TeachingView: View {
    var body: some View {
        VStack {
            HStack() {
                Button {
                    
                } label: {
                    Image(systemName: "xmark")
                }
            }
            Text("VERSUCHEN SIE, DIESE TURNSHUNE AUNZPROBIEREN")
                .multilineTextAlignment(.center)
                .font(Font.custom("Roboto-Bold", size: 20))
                .padding()
            Text("Sie müssen ein Bein von allen Seiten scannen, bis die Ebenen gelb gefärbt sind")
                .multilineTextAlignment(.center)
                .font(Font.custom("Roboto-Regular", size: 16))
                .padding()
            Image("image 38")
                .resizable()
        }.overlay {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.clear)
        }
    }
}

struct TeachingView_Previews: PreviewProvider {
    static var previews: some View {
        TeachingView()
    }
}
