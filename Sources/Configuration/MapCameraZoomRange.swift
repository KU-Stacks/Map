//
//  MapCameraZoomRange.swift
//  Map
//
//  Created by Paul Kraft on 30.04.22.
//

import SwiftUI
import MapKit

private enum MapZoomRangeKey: EnvironmentKey {

    static var defaultValue: MKMapView.CameraZoomRange? { nil }

}

extension EnvironmentValues {

    var mapZoomRange: MKMapView.CameraZoomRange? {
        get { self[MapZoomRangeKey.self] }
        set { self[MapZoomRangeKey.self] = newValue }
    }

}

extension View {

    public func mapZoomRange(_ range: MKMapView.CameraZoomRange?) -> some View {
        environment(\.mapZoomRange, range)
    }

}
