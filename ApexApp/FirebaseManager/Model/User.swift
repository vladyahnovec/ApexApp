//
//  User.swift
//  ApexApp
//
//  Created by Круглич Влад on 3.04.25.
//
import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var mail: String
    var password: String
    var likeExercises: [String]
    
}
