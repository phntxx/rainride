//
//  UsefulFunctions.swift
//  rainride
//
//  Created by Bastian on 28.09.18.
//  Copyright © 2018 phntxx. All rights reserved.
//

import Foundation

// This file is not being called by anything and is merely used to store functions that may be useful in the future.

// Function to check if coordinates are within the heading of the user.
func checkDirection (direction: String, lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double{
    if ((direction == "North") || (direction == "North-East") || (direction == "North-West") || (direction == "North-Northeast") || (direction == "North-Northwest")) {
        if(lat2 > lat1) {
            return distanceInKmBetweenEarthCoordinates (lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)
        } else {
            return Double(99999)
        }
    } else if ((direction == "East") || (direction == "North-East") || (direction == "South-East") || (direction == "East-Southeast") || (direction == "East-Northeast")) {
        if (lng2 > lng1) {
            return distanceInKmBetweenEarthCoordinates (lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)
        } else {
            return Double(99999)
        }
    } else if ((direction == "South") || (direction == "South-East") || (direction == "South-West") || (direction == "South-Southeast") || (direction == "South-Southwest")) {
        if (lat2 < lat1) {
            return distanceInKmBetweenEarthCoordinates (lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)
        } else {
            return Double(99999)
        }
    } else if ((direction == "West") || (direction == "North-West") || (direction == "South-West") || (direction == "West-Northwest") || (direction == "West-Southwest")) {
        if (lng2 < lng1) {
            return distanceInKmBetweenEarthCoordinates (lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)
        } else {
            return Double(99999)
        }
    }
    return Double(99999)
}

// Function to calculate the distance between two coordinates.
func distanceInKmBetweenEarthCoordinates (lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
    let earthRadiusKm = 6371
    let dLat = degreesToRadians (degrees: (lat2-lat1))
    let dLon = degreesToRadians (degrees: (lng2-lng1))
    let latitude1 = degreesToRadians (degrees: lat1)
    let latitude2 = degreesToRadians (degrees: lat2)
    let a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(latitude1) * cos(latitude2)
    let c = 2 * atan2(sqrt(a), sqrt(1-a))
    return Double(earthRadiusKm) * Double(c)
}

// Function to convert degrees into radians
func degreesToRadians (degrees: Double) -> Double {
    return (degrees * Double.pi / 180)
}

// Function to convert heading degree-values into human-readable text
func convertHeading (heading: Float) -> String {
    if (11.25 <= heading && heading < 33.75) {
        return "North-Northeast"
     } else if (33.75 <= heading && heading < 56.25) {
        return "North-East"
     } else if (56.25 <= heading && heading < 78.75) {
        return "East-Northeast"
     } else if (78.75 <= heading && heading < 101.25) {
        return "East"
     } else if (101.25 <= heading && heading < 123.75) {
        return "East-Southeast"
     } else if (123.75 <= heading && heading < 146.25) {
        return "South-East"
     } else if (146.25 <= heading && heading < 168.75) {
        return "South-Southeast"
     } else if (168.75 <= heading && heading < 191.25) {
        return "South"
     } else if (191.25 <= heading && heading < 213.75) {
        return "South-Southwest"
     } else if (213.75 <= heading && heading < 236.25) {
        return "South-West"
     } else if (236.25 <= heading && heading < 258.75) {
        return "West-Southwest"
     } else if (258.75 <= heading && heading < 281.25) {
        return "West"
     } else if (281.25 <= heading && heading < 303.75) {
        return "West-Northwest"
     } else if (303.75 <= heading && heading < 326.25) {
        return "North-West"
     } else if (326.25 <= heading && heading < 348.75) {
        return "North-Northwest"
     } else {
        return "North"
     }
}

