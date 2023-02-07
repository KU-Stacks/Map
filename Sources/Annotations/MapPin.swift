//
//  MapPin.swift
//  Map
//
//  Created by Paul Kraft on 22.04.22.
//

import MapKit
import SwiftUI

public struct MapPin {

    // MARK: Nested Types

    private class Annotation: NSObject, MKAnnotation {

        // MARK: Stored Properties

        let coordinate: CLLocationCoordinate2D

        // MARK: Initialization

        init(_ coordinate: CLLocationCoordinate2D) {
            self.coordinate = coordinate
        }

    }

    // MARK: Stored Properties

    private let coordinate: CLLocationCoordinate2D
    private let tint: Color?
    public let annotation: MKAnnotation

    // MARK: Initialization

    public init(coordinate: CLLocationCoordinate2D, tint: Color?) {
        self.coordinate = coordinate
        self.tint = tint
        self.annotation = Annotation(coordinate)
    }

}

// MARK: - MapAnnotation

extension MapPin: MapAnnotation {

    public static func registerView(on mapView: MKMapView) {
        mapView.register(
            MKPinAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: reuseIdentifier)
    }

    public func view(for mapView: MKMapView) -> MKAnnotationView? {
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: Self.reuseIdentifier, for: annotation)
        view.annotation = annotation
        if let tint = tint, let pin = view as? MKPinAnnotationView {
            pin.pinTintColor = .init(tint)
        }
        return view
    }

}
