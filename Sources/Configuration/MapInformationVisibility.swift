//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.04.22.
//

public struct MapInformationVisibility: OptionSet {

    // MARK: Static Properties

    @available(watchOS, unavailable)
    public static let buildings = MapInformationVisibility(rawValue: 1 << 0)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public static let compass = MapInformationVisibility(rawValue: 1 << 1)

    @available(iOS, unavailable)
    @available(macOS 11, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public static let pitchControl = MapInformationVisibility(rawValue: 1 << 2)

    @available(watchOS, unavailable)
    public static let scale = MapInformationVisibility(rawValue: 1 << 3)

    @available(watchOS, unavailable)
    public static let traffic = MapInformationVisibility(rawValue: 1 << 4)

    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS 6.1, *)
    public static let userHeading = MapInformationVisibility(rawValue: 1 << 5)

    @available(watchOS 6.1, *)
    public static let userLocation = MapInformationVisibility(rawValue: 1 << 6)

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public static let zoomControls = MapInformationVisibility(rawValue: 1 << 7)

    public static let `default`: MapInformationVisibility = {
        return MapInformationVisibility(arrayLiteral: .buildings)
    }()

    public static let all: MapInformationVisibility = {
        return MapInformationVisibility(
            arrayLiteral: .buildings, .compass, .scale, .traffic, .userLocation
        )
    }()

    // MARK: Stored Properties

    public let rawValue: Int

    // MARK: Initialization

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

}
