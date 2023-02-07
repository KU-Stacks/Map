//
//  MapCircle.swift
//  Map
//
//  Created by Paul Kraft on 25.04.22.
//

import MapKit
import SwiftUI

public struct MapCircle: MapOverlay {

    // MARK: Stored Properties

    public let overlay: MKOverlay
    public let level: MKOverlayLevel?

    private let fillColor: Color?
    private let nativeFillColor: UIColor?
    private let lineWidth: CGFloat?
    private let strokeColor: Color?
    private let nativeStrokeColor: UIColor?

    // MARK: Initialization

    public init(center: CLLocationCoordinate2D, radius: CLLocationDistance, level: MKOverlayLevel? = nil, fillColor: UIColor? = nil, lineWidth: CGFloat? = nil, strokeColor: UIColor? = nil) {
        self.overlay = MKCircle(center: center, radius: radius)
        self.level = level
        self.fillColor = nil
        self.nativeFillColor = fillColor
        self.lineWidth = lineWidth
        self.strokeColor = nil
        self.nativeStrokeColor = strokeColor
    }

    public init(mapRect: MKMapRect, level: MKOverlayLevel? = nil, fillColor: UIColor? = nil, lineWidth: CGFloat? = nil, strokeColor: UIColor? = nil) {
        self.overlay = MKCircle(mapRect: mapRect)
        self.level = level
        self.fillColor = nil
        self.nativeFillColor = fillColor
        self.lineWidth = lineWidth
        self.strokeColor = nil
        self.nativeStrokeColor = strokeColor
    }

    public init(circle: MKCircle, level: MKOverlayLevel? = nil, fillColor: UIColor? = nil, lineWidth: CGFloat? = nil, strokeColor: UIColor? = nil) {
        self.overlay = circle
        self.level = level
        self.fillColor = nil
        self.nativeFillColor = fillColor
        self.lineWidth = lineWidth
        self.strokeColor = nil
        self.nativeStrokeColor = strokeColor
    }

    public init(center: CLLocationCoordinate2D, radius: CLLocationDistance, level: MKOverlayLevel? = nil, fillColor: Color?, lineWidth: CGFloat? = nil, strokeColor: Color?) {
        self.overlay = MKCircle(center: center, radius: radius)
        self.level = level
        self.fillColor = fillColor
        self.nativeFillColor = nil
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
        self.nativeStrokeColor = nil
    }

    public init(mapRect: MKMapRect, level: MKOverlayLevel? = nil, fillColor: Color?, lineWidth: CGFloat? = nil, strokeColor: Color?) {
        self.overlay = MKCircle(mapRect: mapRect)
        self.level = level
        self.fillColor = fillColor
        self.nativeFillColor = nil
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
        self.nativeStrokeColor = nil
    }

    public init(circle: MKCircle, level: MKOverlayLevel? = nil, fillColor: Color?, lineWidth: CGFloat? = nil, strokeColor: Color?) {
        self.overlay = circle
        self.level = level
        self.fillColor = fillColor
        self.nativeFillColor = nil
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
        self.nativeStrokeColor = nil
    }

    // MARK: Methods

    public func renderer(for mapView: MKMapView) -> MKOverlayRenderer {
        let renderer = (overlay as? MKCircle)
            .map { MKCircleRenderer(circle: $0) }
            ?? MKCircleRenderer(overlay: overlay)

        if let fillColor = fillColor {
            renderer.fillColor = .init(fillColor)
        } else if let fillColor = nativeFillColor {
            renderer.fillColor = fillColor
        }
        if let lineWidth = lineWidth {
            renderer.lineWidth = lineWidth
        }
        if let strokeColor = strokeColor {
            renderer.strokeColor = .init(strokeColor)
        } else if let strokeColor = nativeStrokeColor {
            renderer.strokeColor = strokeColor
        }

        return renderer
    }

}
