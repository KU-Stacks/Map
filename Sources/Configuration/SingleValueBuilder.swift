//
//  SingleValueBuilder.swift
//  Map
//
//  Created by Paul Kraft on 25.04.22.
//

public typealias MapAnnotationBuilder = SingleValueBuilder<MapAnnotation>

public typealias MapOverlayBuilder = SingleValueBuilder<MapOverlay>

@resultBuilder
public enum SingleValueBuilder<Component> {

    public static func buildBlock(_ component: Component) -> Component {
        component
    }

    public static func buildEither(first component: Component) -> Component {
        component
    }

    public static func buildEither(second component: Component) -> Component {
        component
    }

    public static func buildLimitedAvailability(_ component: Component) -> Component {
        component
    }

}
