//
//  Exercise.swift
//  ApexApp
//
//  Created by Круглич Влад on 4.04.25.
//

import Foundation
import FirebaseFirestore

struct Exercise: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var categoryID: String
    var categoryName: String?
    var img: String
}
