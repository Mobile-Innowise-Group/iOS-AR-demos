//
//  ShoeChooseButton.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 03/01/2023.
//

import SwiftUI

struct ShoeChooseButton: View {
    var body: some View {
        HStack {
            ButtonCircle(sysImageName: "1.circle") {}
            ButtonCircle(sysImageName: "2.circle") {}
            ButtonCircle(sysImageName: "3.circle") {}
        }
    }
}

struct ButtonCircle: View {
    @State var sysImageName: String
    var completion: (() -> Void)?
    var body: some View {
        Button {
            completion?()
        } label: {
            Image(systemName: sysImageName)
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
}

struct ShoeChooseButton_Previews: PreviewProvider {
    static var previews: some View {
        ShoeChooseButton()
    }
}
