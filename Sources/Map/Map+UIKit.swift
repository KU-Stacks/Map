//
//  Map+UIKit.swift
//  Map
//
//  Created by Paul Kraft on 25.04.22.
//

import MapKit
import UIKit
import SwiftUI

extension Map: UIViewRepresentable {

    public func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let mapCamera = MKMapCamera()
        mapCamera.centerCoordinate = CLLocationCoordinate2D(
            latitude: 37.540744,
            longitude: 127.076451
        )
        mapCamera.pitch = 0
        mapCamera.altitude = 3000 // example altitude
        mapCamera.heading = 20
        
        // set the camera property
        mapView.camera = mapCamera
        
        updateUIView(mapView, context: context)
        
        return mapView
    }

    public func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.mapType = .mutedStandard
        mapView.showsBuildings = false
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = false
        mapView.showsUserLocation = true
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true
        mapView.pointOfInterestFilter = .excludingAll
        mapView.camera.heading = 20
        context.coordinator.update(mapView, from: self, context: context)
    }

}
