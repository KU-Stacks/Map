//
//  Map+Coordinator.swift
//  Map
//
//  Created by Paul Kraft on 23.04.22.
//

import MapKit
import SwiftUI

extension Map {

    // MARK: Nested Types

    public class Coordinator: NSObject, MKMapViewDelegate {

        // MARK: Stored Properties

        private var view: Map?

        private var annotationContentByObject = [ObjectIdentifier: MapAnnotation]()
        private var annotationContentByID = [AnnotationItems.Element.ID: MapAnnotation]()

        private var overlayContentByObject = [ObjectIdentifier: MapOverlay]()
        private var overlayContentByID = [OverlayItems.Element.ID: MapOverlay]()

        private var previousBoundary: MKMapView.CameraBoundary?
        private var previousZoomRange: MKMapView.CameraZoomRange?

        private var registeredAnnotationTypes = Set<ObjectIdentifier>()
        private var regionIsChanging = false
        private var isInitialRegionChange = true

        // MARK: Initialization

        override init() {}

        deinit {
            MapRegistry.clean()
        }

        // MARK: Methods

        func update(_ mapView: MKMapView, from newView: Map, context: Context) {
            defer { view = newView }
            let animation = context.transaction.animation
            updateAnnotations(on: mapView, from: view, to: newView)
            updateSelectedItem(on: mapView, from: view, to: newView)
            updateCamera(on: mapView, context: context, animated: animation != nil)
            updateOverlays(on: mapView, from: view, to: newView)
            updateRegion(on: mapView, from: view, to: newView, animated: animation != nil)
            updateUserTracking(on: mapView, from: view, to: newView)

            if let key = context.environment.mapKey {
                MapRegistry[key] = mapView
            }
        }

        // MARK: Helpers

        private func registerAnnotationViewIfNeeded(on mapView: MKMapView, for content: MapAnnotation) {
            let contentType = type(of: content)
            let contentTypeKey = ObjectIdentifier(contentType)
            if !registeredAnnotationTypes.contains(contentTypeKey) {
                registeredAnnotationTypes.insert(contentTypeKey)
                contentType.registerView(on: mapView)
            }
        }

        private func updateAnnotations(on mapView: MKMapView, from previousView: Map?, to newView: Map) {
            let changes: CollectionDifference<AnnotationItems.Element>
            if let previousView = previousView {
                changes = newView.annotationItems.difference(from: previousView.annotationItems) { $0.id == $1.id }
            } else {
                changes = newView.annotationItems.difference(from: []) { $0.id == $1.id }
            }

            for change in changes {
                switch change {
                case let .insert(_, item, _):
                    guard !annotationContentByID.keys.contains(item.id) else {
                        assertionFailure("Duplicate annotation item id \(item.id) of \(item) found.")
                        continue
                    }
                    let content = newView.annotationContent(item)
                    let objectKey = ObjectIdentifier(content.annotation)
                    guard !annotationContentByObject.keys.contains(objectKey) else {
                        assertionFailure("Duplicate annotation for content \(content) found!")
                        continue
                    }
                    annotationContentByID[item.id] = content
                    annotationContentByObject[objectKey] = content
                    registerAnnotationViewIfNeeded(on: mapView, for: content)
                    mapView.addAnnotation(content.annotation)
                case let .remove(_, item, _):
                    guard let content = annotationContentByID[item.id] else {
                        assertionFailure("Missing annotation content for item \(item) encountered.")
                        continue
                    }
                    mapView.removeAnnotation(content.annotation)
                    annotationContentByObject.removeValue(forKey: ObjectIdentifier(content.annotation))
                    annotationContentByID.removeValue(forKey: item.id)
                }
            }
        }

        private func updateCamera(on mapView: MKMapView, context: Context, animated: Bool) {
            let newBoundary = context.environment.mapBoundary
            if previousBoundary != newBoundary && mapView.cameraBoundary != newBoundary {
                mapView.setCameraBoundary(newBoundary, animated: animated)
                previousBoundary = newBoundary
            }

            let newZoomRange = context.environment.mapZoomRange
            if previousZoomRange != newZoomRange && mapView.cameraZoomRange != newZoomRange {
                mapView.setCameraZoomRange(newZoomRange, animated: animated)
                previousZoomRange = newZoomRange
            }
        }


        private func updateOverlays(on mapView: MKMapView, from previousView: Map?, to newView: Map) {
            let changes: CollectionDifference<OverlayItems.Element>
            if let previousView = previousView {
                changes = newView.overlayItems.difference(from: previousView.overlayItems) { $0.id == $1.id }
            } else {
                changes = newView.overlayItems.difference(from: []) { $0.id == $1.id }
            }

            for change in changes {
                switch change {
                case let .insert(index, item, _):
                    guard !overlayContentByID.keys.contains(item.id) else {
                        assertionFailure("Duplicate overlay item id \(item.id) of \(item) found.")
                        continue
                    }
                    let content = newView.overlayContent(item)
                    let objectKey = ObjectIdentifier(content.overlay)
                    guard !overlayContentByObject.keys.contains(objectKey) else {
                        assertionFailure("Duplicate overlay for content \(content) found!")
                        continue
                    }
                    overlayContentByObject[objectKey] = content
                    overlayContentByID[item.id] = content
                    if let level = content.level {
                        mapView.insertOverlay(content.overlay, at: index, level: level)
                    } else {
                        mapView.insertOverlay(content.overlay, at: index)
                    }
                case let .remove(_, item, _):
                    guard let content = overlayContentByID[item.id] else {
                        assertionFailure("Missing overlay content for item \(item) encountered.")
                        continue
                    }
                    overlayContentByObject.removeValue(forKey: ObjectIdentifier(content.overlay))
                    overlayContentByID.removeValue(forKey: item.id)
                    mapView.removeOverlay(content.overlay)
                }
            }
        }
        
        private func updateSelectedItem(on mapView: MKMapView, from previousView: Map?, to newView: Map) {
            // Make sure the selectedItem is changed
            guard newView.selectedItem != previousView?.selectedItem else { return }
            
            // New item is selected
            if let newSelectedItem = newView.selectedItem,
               let mapAnnotation = annotationContentByID[newSelectedItem] {
                mapView.selectAnnotation(mapAnnotation.annotation, animated: false)
            } else {
                // No item is selected
                mapView.selectedAnnotations = []
            }
        }
        
        public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // Find the item ID of the selected annotation
            guard let id = annotationContentByID.first(where: { $0.value.annotation === view.annotation })?.key else {
                return
            }
            // Assing the selected item ID to the selectedItem binding
            self.view?.selectedItem = id
        }
        
        public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            self.view?.selectedItem = nil
        }
        
        private func updateRegion(on mapView: MKMapView, from previousView: Map?, to newView: Map, animated: Bool) {
            guard !regionIsChanging else {
                return
            }

            if newView.usesRegion {
                let newRegion = newView.coordinateRegion
                guard !(previousView?.coordinateRegion.equals(to: newRegion) ?? false)
                        && !mapView.region.equals(to: newRegion) else {
                    return
                }
                DispatchQueue.main.async {
                    mapView.setRegion(newRegion, animated: animated)
                }
            } else {
                let newRect = newView.mapRect
                guard !(previousView?.mapRect.equals(to: newRect) ?? false)
                        && !mapView.visibleMapRect.equals(to: newRect) else {
                    return
                }
                DispatchQueue.main.async {
                    mapView.setVisibleMapRect(newRect, animated: animated)
                }
            }
        }
        
        private func updateUserTracking(on mapView: MKMapView, from previousView: Map?, to newView: Map) {
            let newTrackingMode = newView.userTrackingMode
            if newView.usesUserTrackingMode, mapView.userTrackingMode != newTrackingMode {
                mapView.userTrackingMode = newTrackingMode
            }
        }

        // MARK: MKMapViewDelegate

        public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            guard !regionIsChanging else {
                return
            }
            view?.coordinateRegion = mapView.region
            view?.mapRect = mapView.visibleMapRect
        }

        public func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            guard let view = view, view.usesUserTrackingMode else {
                return
            }
            switch mode {
            case .none:
                view.userTrackingMode = .none
            case .follow:
                view.userTrackingMode = .follow
            case .followWithHeading:
                view.userTrackingMode = .followWithHeading
            @unknown default:
                assertionFailure("Encountered unknown user tracking mode")
            }
        }

        public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            regionIsChanging = true
        }

        public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            regionIsChanging = false
            if isInitialRegionChange {
                isInitialRegionChange = false
            } else {
                mapViewDidChangeVisibleRegion(mapView)
            }
        }

        public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let content = overlayContentByObject[ObjectIdentifier(overlay)] else {
                assertionFailure("Somehow an unknown overlay appeared.")
                return MKOverlayRenderer(overlay: overlay)
            }
            return content.renderer(for: mapView)
        }

        public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let content = annotationContentByObject[ObjectIdentifier(annotation)] else {
                return nil
            }
            return content.view(for: mapView)
        }

    }

    // MARK: Methods

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

}
