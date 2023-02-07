//
//  Map.swift
//  Map
//
//  Created by Paul Kraft on 22.04.22.
//

import MapKit
import SwiftUI

public struct Map<AnnotationItems: RandomAccessCollection, OverlayItems: RandomAccessCollection>
    where AnnotationItems.Element: Identifiable, OverlayItems.Element: Identifiable {

    // MARK: Stored Properties

    @Binding var coordinateRegion: MKCoordinateRegion
    @Binding var mapRect: MKMapRect

    let usesRegion: Bool

    let mapType: MKMapType
    let pointOfInterestFilter: MKPointOfInterestFilter?

    let informationVisibility: MapInformationVisibility
    let interactionModes: MapInteractionModes

    let usesUserTrackingMode: Bool

    @available(macOS 11, *)
    @Binding var userTrackingMode: MKUserTrackingMode
    @Binding var selectedItem: AnnotationItems.Element.ID?

    let annotationItems: AnnotationItems
    let annotationContent: (AnnotationItems.Element) -> MapAnnotation

    let overlayItems: OverlayItems
    let overlayContent: (OverlayItems.Element) -> MapOverlay

}

// MARK: - Initialization

extension Map {

    public init(
        coordinateRegion: Binding<MKCoordinateRegion>,
        type mapType: MKMapType = .standard,
        pointOfInterestFilter: MKPointOfInterestFilter? = nil,
        informationVisibility: MapInformationVisibility = .default,
        interactionModes: MapInteractionModes = .all,
        userTrackingMode: Binding<MKUserTrackingMode>? = nil,
        annotationItems: AnnotationItems,
        selectedItem: Binding<AnnotationItems.Element.ID?> = .constant(.none),
        @MapAnnotationBuilder annotationContent: @escaping (AnnotationItems.Element) -> MapAnnotation,
        overlayItems: OverlayItems,
        @MapOverlayBuilder overlayContent: @escaping (OverlayItems.Element) -> MapOverlay
    ) {
        self.usesRegion = true
        self._coordinateRegion = coordinateRegion
        self._mapRect = .constant(.init())
        self.mapType = mapType
        self.pointOfInterestFilter = pointOfInterestFilter
        self.informationVisibility = informationVisibility
        self.interactionModes = interactionModes
        if let userTrackingMode = userTrackingMode {
            self.usesUserTrackingMode = true
            self._userTrackingMode = userTrackingMode
        } else {
            self.usesUserTrackingMode = false
            self._userTrackingMode = .constant(.none)
        }
        self.annotationItems = annotationItems
        self._selectedItem = selectedItem
        self.annotationContent = annotationContent
        self.overlayItems = overlayItems
        self.overlayContent = overlayContent
    }

    public init(
        mapRect: Binding<MKMapRect>,
        type mapType: MKMapType = .standard,
        pointOfInterestFilter: MKPointOfInterestFilter? = nil,
        informationVisibility: MapInformationVisibility = .default,
        interactionModes: MapInteractionModes = .all,
        userTrackingMode: Binding<MKUserTrackingMode>? = nil,
        annotationItems: AnnotationItems,
        selectedItem: Binding<AnnotationItems.Element.ID?> = .constant(.none),
        @MapAnnotationBuilder annotationContent: @escaping (AnnotationItems.Element) -> MapAnnotation,
        overlayItems: OverlayItems,
        @MapOverlayBuilder overlayContent: @escaping (OverlayItems.Element) -> MapOverlay
    ) {
        self.usesRegion = false
        self._coordinateRegion = .constant(.init())
        self._mapRect = mapRect
        self.mapType = mapType
        self.pointOfInterestFilter = pointOfInterestFilter
        self.informationVisibility = informationVisibility
        self.interactionModes = interactionModes
        if let userTrackingMode = userTrackingMode {
            self.usesUserTrackingMode = true
            self._userTrackingMode = userTrackingMode
        } else {
            self.usesUserTrackingMode = false
            self._userTrackingMode = .constant(.none)
        }
        self.annotationItems = annotationItems
        self.annotationContent = annotationContent
        self.overlayItems = overlayItems
        self.overlayContent = overlayContent
        self._selectedItem = selectedItem
    }

}


// MARK: - AnnotationItems == [IdentifiableObject<MKAnnotation>]

// The following initializers are most useful for either bridging with old MapKit code for annotations
// or to actually not use annotations entirely.

extension Map where AnnotationItems == [IdentifiableObject<MKAnnotation>] {

    public init(
        coordinateRegion: Binding<MKCoordinateRegion>,
        type mapType: MKMapType = .standard,
        pointOfInterestFilter: MKPointOfInterestFilter? = nil,
        informationVisibility: MapInformationVisibility = .default,
        interactionModes: MapInteractionModes = .all,
        userTrackingMode: Binding<MKUserTrackingMode>? = nil,
        annotations: [MKAnnotation] = [],
        @MapAnnotationBuilder annotationContent: @escaping (MKAnnotation) -> MapAnnotation = { annotation in
            assertionFailure("Please provide an `annotationContent` closure for the values in `annotations`.")
            return ViewMapAnnotation(annotation: annotation) {}
        },
        overlayItems: OverlayItems,
        @MapOverlayBuilder overlayContent: @escaping (OverlayItems.Element) -> MapOverlay
    ) {
        self.init(
            coordinateRegion: coordinateRegion,
            type: mapType,
            pointOfInterestFilter: pointOfInterestFilter,
            informationVisibility: informationVisibility,
            interactionModes: interactionModes,
            userTrackingMode: userTrackingMode,
            annotationItems: annotations.map(IdentifiableObject.init),
            selectedItem: .constant(.none),
            annotationContent: { annotationContent($0.object) },
            overlayItems: overlayItems,
            overlayContent: overlayContent
        )
    }

    public init(
        mapRect: Binding<MKMapRect>,
        type mapType: MKMapType = .standard,
        pointOfInterestFilter: MKPointOfInterestFilter? = nil,
        informationVisibility: MapInformationVisibility = .default,
        interactionModes: MapInteractionModes = .all,
        userTrackingMode: Binding<MKUserTrackingMode>? = nil,
        annotations: [MKAnnotation] = [],
        @MapAnnotationBuilder annotationContent: @escaping (MKAnnotation) -> MapAnnotation = { annotation in
            assertionFailure("Please provide an `annotationContent` closure for the values in `annotations`.")
            return ViewMapAnnotation(annotation: annotation) {}
        },
        overlayItems: OverlayItems,
        @MapOverlayBuilder overlayContent: @escaping (OverlayItems.Element) -> MapOverlay
    ) {
        self.init(
            mapRect: mapRect,
            type: mapType,
            pointOfInterestFilter: pointOfInterestFilter,
            informationVisibility: informationVisibility,
            interactionModes: interactionModes,
            userTrackingMode: userTrackingMode,
            annotationItems: annotations.map(IdentifiableObject.init),
            annotationContent: { annotationContent($0.object) },
            overlayItems: overlayItems,
            overlayContent: overlayContent
        )

    }

}

// MARK: - OverlayItems == [IdentifiableObject<MKOverlay>]

// The following initializers are most useful for either bridging with old MapKit code for overlays
// or to actually not use overlays entirely.

extension Map where OverlayItems == [IdentifiableObject<MKOverlay>] {

    public init(
        coordinateRegion: Binding<MKCoordinateRegion>,
        type mapType: MKMapType = .standard,
        pointOfInterestFilter: MKPointOfInterestFilter? = nil,
        informationVisibility: MapInformationVisibility = .default,
        interactionModes: MapInteractionModes = .all,
        userTrackingMode: Binding<MKUserTrackingMode>? = nil,
        annotationItems: AnnotationItems,
        selectedItem: Binding<AnnotationItems.Element.ID?>,
        @MapAnnotationBuilder annotationContent: @escaping (AnnotationItems.Element) -> MapAnnotation,
        overlays: [MKOverlay] = [],
        @MapOverlayBuilder overlayContent: @escaping (MKOverlay) -> MapOverlay = { overlay in
            assertionFailure("Please provide an `overlayContent` closure for the values in `overlays`.")
            return RendererMapOverlay(overlay: overlay) { _, overlay in
                MKOverlayRenderer(overlay: overlay)
            }
        }
    ) {
        self.init(
            coordinateRegion: coordinateRegion,
            type: mapType,
            pointOfInterestFilter: pointOfInterestFilter,
            informationVisibility: informationVisibility,
            interactionModes: interactionModes,
            userTrackingMode: userTrackingMode,
            annotationItems: annotationItems,
            selectedItem: selectedItem,
            annotationContent: annotationContent,
            overlayItems: overlays.map(IdentifiableObject.init),
            overlayContent: { overlayContent($0.object) }
        )
    }

    public init(
        mapRect: Binding<MKMapRect>,
        type mapType: MKMapType = .standard,
        pointOfInterestFilter: MKPointOfInterestFilter? = nil,
        informationVisibility: MapInformationVisibility = .default,
        interactionModes: MapInteractionModes = .all,
        userTrackingMode: Binding<MKUserTrackingMode>? = nil,
        annotationItems: AnnotationItems,
        @MapAnnotationBuilder annotationContent: @escaping (AnnotationItems.Element) -> MapAnnotation,
        overlays: [MKOverlay] = [],
        @MapOverlayBuilder overlayContent: @escaping (MKOverlay) -> MapOverlay = { overlay in
            assertionFailure("Please provide an `overlayContent` closure for the values in `overlays`.")
            return RendererMapOverlay(overlay: overlay) { _, overlay in
                MKOverlayRenderer(overlay: overlay)
            }
        }
    ) {
        self.init(
            mapRect: mapRect,
            type: mapType,
            pointOfInterestFilter: pointOfInterestFilter,
            informationVisibility: informationVisibility,
            interactionModes: interactionModes,
            userTrackingMode: userTrackingMode,
            annotationItems: annotationItems,
            annotationContent: annotationContent,
            overlayItems: overlays.map(IdentifiableObject.init),
            overlayContent: { overlayContent($0.object) }
        )
    }

}

// MARK: - AnnotationItems == [IdentifiableObject<MKAnnotation>], OverlayItems == [IdentifiableObject<MKOverlay>]

// The following initializers are most useful for either bridging with old MapKit code
// or to actually not use annotations/overlays entirely.

extension Map
    where AnnotationItems == [IdentifiableObject<MKAnnotation>],
          OverlayItems == [IdentifiableObject<MKOverlay>] {

    public init(
        coordinateRegion: Binding<MKCoordinateRegion>,
        type mapType: MKMapType = .standard,
        pointOfInterestFilter: MKPointOfInterestFilter? = nil,
        informationVisibility: MapInformationVisibility = .default,
        interactionModes: MapInteractionModes = .all,
        userTrackingMode: Binding<MKUserTrackingMode>? = nil,
        annotations: [MKAnnotation] = [],
        selectedItem: Binding<AnnotationItems.Element.ID?>,
        @MapAnnotationBuilder annotationContent: @escaping (MKAnnotation) -> MapAnnotation = { annotation in
            assertionFailure("Please provide an `annotationContent` closure for the values in `annotations`.")
            return ViewMapAnnotation(annotation: annotation) {}
        },
        overlays: [MKOverlay] = [],
        @MapOverlayBuilder overlayContent: @escaping (MKOverlay) -> MapOverlay = { overlay in
            assertionFailure("Please provide an `overlayContent` closure for the values in `overlays`.")
            return RendererMapOverlay(overlay: overlay) { _, overlay in
                MKOverlayRenderer(overlay: overlay)
            }
        }
    ) {
        self.init(
            coordinateRegion: coordinateRegion,
            type: mapType,
            pointOfInterestFilter: pointOfInterestFilter,
            informationVisibility: informationVisibility,
            interactionModes: interactionModes,
            userTrackingMode: userTrackingMode,
            annotationItems: annotations.map(IdentifiableObject.init),
            selectedItem: selectedItem,
            annotationContent: { annotationContent($0.object) },
            overlayItems: overlays.map(IdentifiableObject.init),
            overlayContent: { overlayContent($0.object) }
        )
    }

    public init(
        mapRect: Binding<MKMapRect>,
        type mapType: MKMapType = .standard,
        pointOfInterestFilter: MKPointOfInterestFilter? = nil,
        informationVisibility: MapInformationVisibility = .default,
        interactionModes: MapInteractionModes = .all,
        userTrackingMode: Binding<MKUserTrackingMode>? = nil,
        annotations: [MKAnnotation] = [],
        @MapAnnotationBuilder annotationContent: @escaping (MKAnnotation) -> MapAnnotation = { annotation in
            assertionFailure("Please provide an `annotationContent` closure for the values in `annotations`.")
            return ViewMapAnnotation(annotation: annotation) {}
        },
        overlays: [MKOverlay] = [],
        @MapOverlayBuilder overlayContent: @escaping (MKOverlay) -> MapOverlay = { overlay in
            assertionFailure("Please provide an `overlayContent` closure for the values in `overlays`.")
            return RendererMapOverlay(overlay: overlay) { _, overlay in
                MKOverlayRenderer(overlay: overlay)
            }
        }
    ) {
        self.init(
            mapRect: mapRect,
            type: mapType,
            pointOfInterestFilter: pointOfInterestFilter,
            informationVisibility: informationVisibility,
            interactionModes: interactionModes,
            userTrackingMode: userTrackingMode,
            annotationItems: annotations.map(IdentifiableObject.init),
            annotationContent: { annotationContent($0.object) },
            overlayItems: overlays.map(IdentifiableObject.init),
            overlayContent: { overlayContent($0.object) }
        )
    }

}
