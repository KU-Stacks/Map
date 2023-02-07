//
//  MapCompass.swift
//  Map
//
//  Created by Paul Kraft on 26.04.22.
//


import SwiftUI
import MapKit

public struct MapCompass {

    // MARK: Nested Types

    public class Coordinator {

        // MARK: Stored Properties

        private var view: MapCompass?

        // MARK: Methods

        func update(_ compassButton: MKCompassButton, with newView: MapCompass, context: Context) {
            defer { view = newView }

            if view?.visibility != newView.visibility {
                compassButton.compassVisibility = newView.visibility
            }
        }

    }

    // MARK: Stored Properties

    private let key: AnyHashable
    private let visibility: MKFeatureVisibility

    // MARK: Initialization

    public init<Key: Hashable>(key: Key, visibility: MKFeatureVisibility) {
        self.key = key
        self.visibility = visibility
    }

    // MARK: Methods

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

}


extension MapCompass: UIViewRepresentable {

    public func makeUIView(context: Context) -> MKCompassButton {
        let view = MKCompassButton(mapView: MapRegistry[key])
        updateUIView(view, context: context)
        return view
    }

    public func updateUIView(_ compassButton: MKCompassButton, context: Context) {
        if let mapView = MapRegistry[key], mapView != compassButton.mapView {
            compassButton.mapView = mapView
        }
        context.coordinator.update(compassButton, with: self, context: context)
    }

}

