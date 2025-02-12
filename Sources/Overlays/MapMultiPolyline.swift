//
//  MapMultiPolyline.swift
//  Map
//
//  Created by Paul Kraft on 25.04.22.
//

import MapKit
import SwiftUI

public struct MapMultiPolyline: MapOverlay {

    // MARK: Stored Properties

    public let overlay: MKOverlay
    public let level: MKOverlayLevel?

    private let lineWidth: CGFloat?
    private let strokeColor: Color?
    private let nativeStrokeColor: UIColor?

    // MARK: Initialization

    public init(polylines: [MKPolyline], level: MKOverlayLevel? = nil, lineWidth: CGFloat? = nil, strokeColor: UIColor? = nil) {
        self.overlay = MKMultiPolyline(polylines)
        self.level = level
        self.lineWidth = lineWidth
        self.strokeColor = nil
        self.nativeStrokeColor = strokeColor
    }

    public init(multiPolyline: MKMultiPolyline, level: MKOverlayLevel? = nil, lineWidth: CGFloat? = nil, strokeColor: UIColor? = nil) {
        self.overlay = multiPolyline
        self.level = level
        self.lineWidth = lineWidth
        self.strokeColor = nil
        self.nativeStrokeColor = strokeColor
    }

    public init(polylines: [MKPolyline], level: MKOverlayLevel? = nil, lineWidth: CGFloat? = nil, strokeColor: Color?) {
        self.overlay = MKMultiPolyline(polylines)
        self.level = level
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
        self.nativeStrokeColor = nil
    }

    public init(multiPolyline: MKMultiPolyline, level: MKOverlayLevel? = nil, lineWidth: CGFloat? = nil, strokeColor: Color?) {
        self.overlay = multiPolyline
        self.level = level
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
        self.nativeStrokeColor = nil
    }

    // MARK: Methods

    public func renderer(for mapView: MKMapView) -> MKOverlayRenderer {
        let renderer = (overlay as? MKMultiPolyline)
            .map { MKMultiPolylineRenderer(multiPolyline: $0) }
            ?? MKMultiPolylineRenderer(overlay: overlay)

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
