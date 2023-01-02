//
//  ShoeModel.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 02/01/2023.
//

import Foundation

struct ShoeModel: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var subtitle: String
    var price: String
    var image: String
}
