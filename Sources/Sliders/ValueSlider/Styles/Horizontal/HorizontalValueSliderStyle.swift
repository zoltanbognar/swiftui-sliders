import SwiftUI

@MainActor
public struct HorizontalValueSliderStyle<Track: View, Thumb: View>: ValueSliderStyle {
    private let track: Track
    private let thumb: Thumb
    private let thumbSize: CGSize
    private let thumbInteractiveSize: CGSize
    private let options: ValueSliderOptions
    private let isRightToLeft: Bool

     public func makeBody(configuration: Self.Configuration) -> some View {
        let track = self.track
            .environment(\.trackValue, configuration.value.wrappedValue)
            .environment(\.valueTrackConfiguration, ValueTrackConfiguration(
                bounds: configuration.bounds,
                leadingOffset: self.thumbSize.width / 2,
                trailingOffset: self.thumbSize.width / 2)
            )
            .accentColor(Color.accentColor)

        return GeometryReader { geometry in
            ZStack {
                if self.options.contains(.interactiveTrack) {
                    track.gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gestureValue in
                                configuration.onEditingChanged(true)
                                let computedValue = valueFrom(
                                    distance: gestureValue.location.x,
                                    availableDistance: geometry.size.width,
                                    bounds: configuration.bounds,
                                    step: configuration.step,
                                    leadingOffset: self.thumbSize.width / 2,
                                    trailingOffset: self.thumbSize.width / 2,
                                    isRightToLeft: isRightToLeft
                                )
                                configuration.value.wrappedValue = computedValue
                            }
                            .onEnded { _ in
                                configuration.onEditingChanged(false)
                            }
                    )
                } else {
                    track
                }

                ZStack {
                    self.thumb
                        .frame(width: self.thumbSize.width, height: self.thumbSize.height)
                }
                .frame(minWidth: self.thumbInteractiveSize.width, minHeight: self.thumbInteractiveSize.height)
                .position(
                    x: distanceFrom(
                        value: configuration.value.wrappedValue,
                        availableDistance: geometry.size.width,
                        bounds: configuration.bounds,
                        leadingOffset: self.thumbSize.width / 2,
                        trailingOffset: self.thumbSize.width / 2
                    ),
                    y: geometry.size.height / 2
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gestureValue in
                            configuration.onEditingChanged(true)

                            if configuration.dragOffset.wrappedValue == nil {
                                configuration.dragOffset.wrappedValue = gestureValue.startLocation.x - distanceFrom(
                                    value: configuration.value.wrappedValue,
                                    availableDistance: geometry.size.width,
                                    bounds: configuration.bounds,
                                    leadingOffset: self.thumbSize.width / 2,
                                    trailingOffset: self.thumbSize.width / 2,
                                    isRightToLeft: isRightToLeft
                                )
                            }

                            let computedValue = valueFrom(
                                distance: gestureValue.location.x - (configuration.dragOffset.wrappedValue ?? 0),
                                availableDistance: geometry.size.width,
                                bounds: configuration.bounds,
                                step: configuration.step,
                                leadingOffset: self.thumbSize.width / 2,
                                trailingOffset: self.thumbSize.width / 2,
                                isRightToLeft: isRightToLeft
                            )

                            configuration.value.wrappedValue = computedValue
                        }
                        .onEnded { _ in
                            configuration.dragOffset.wrappedValue = nil
                            configuration.onEditingChanged(false)
                        }
                )
            }
            .frame(height: geometry.size.height)
        }
        .frame(minHeight: self.thumbInteractiveSize.height)
    }

    public init(track: Track, thumb: Thumb, thumbSize: CGSize = CGSize(width: 27, height: 27), thumbInteractiveSize: CGSize = CGSize(width: 44, height: 44), options: ValueSliderOptions = .defaultOptions, isRightToLeft: Bool = false) {
        self.track = track
        self.thumb = thumb
        self.thumbSize = thumbSize
        self.thumbInteractiveSize = thumbInteractiveSize
        self.options = options
        self.isRightToLeft = isRightToLeft
    }
}

extension HorizontalValueSliderStyle where Track == DefaultHorizontalValueTrack {
    
    /// Creates a `HorizontalValueSliderStyle` with a custom thumb and default horizontal track.
    ///
    /// - Parameters:
    ///   - thumb: A custom view representing the thumb.
    ///   - thumbSize: The visual size of the thumb. Default is `27x27`.
    ///   - thumbInteractiveSize: The tappable area around the thumb for user interaction. Default is `44x44`.
    ///   - options: Slider options to customize behavior (e.g., stepping, animations). Default is `.defaultOptions`.
    ///   - isRightToLeft: Whether the slider should be drawn right-to-left. Default is `false`.
    public init(
        thumb: Thumb,
        thumbSize: CGSize = CGSize(width: 27, height: 27),
        thumbInteractiveSize: CGSize = CGSize(width: 44, height: 44),
        options: ValueSliderOptions = .defaultOptions,
        isRightToLeft: Bool = false
    ) {
        self.track = DefaultHorizontalValueTrack()
        self.thumb = thumb
        self.thumbSize = thumbSize
        self.thumbInteractiveSize = thumbInteractiveSize
        self.options = options
        self.isRightToLeft = isRightToLeft
    }
}

extension HorizontalValueSliderStyle where Thumb == DefaultThumb {
    
    /// Creates a `HorizontalValueSliderStyle` with a custom track and default thumb.
    ///
    /// - Parameters:
    ///   - track: A custom view representing the slider's track.
    ///   - thumbSize: The visual size of the default thumb. Default is `27x27`.
    ///   - thumbInteractiveSize: The tappable area around the thumb for user interaction. Default is `44x44`.
    ///   - options: Slider options to customize behavior (e.g., stepping, animations). Default is `.defaultOptions`.
    ///   - isRightToLeft: Whether the slider should be drawn right-to-left. Default is `false`.
    public init(
        track: Track,
        thumbSize: CGSize = CGSize(width: 27, height: 27),
        thumbInteractiveSize: CGSize = CGSize(width: 44, height: 44),
        options: ValueSliderOptions = .defaultOptions,
        isRightToLeft: Bool = false
    ) {
        self.track = track
        self.thumb = DefaultThumb()
        self.thumbSize = thumbSize
        self.thumbInteractiveSize = thumbInteractiveSize
        self.options = options
        self.isRightToLeft = isRightToLeft
    }
}

extension HorizontalValueSliderStyle where Thumb == DefaultThumb, Track == DefaultHorizontalValueTrack {
    
    /// Creates a `HorizontalValueSliderStyle` with the default thumb and default horizontal track.
    ///
    /// - Parameters:
    ///   - thumbSize: The visual size of the thumb. Default is `27x27`.
    ///   - thumbInteractiveSize: The tappable area around the thumb for user interaction. Default is `44x44`.
    ///   - options: Slider options to customize behavior (e.g., stepping, animations). Default is `.defaultOptions`.
    ///   - isRightToLeft: Whether the slider should be drawn right-to-left. Default is `false`.
    public init(
        thumbSize: CGSize = CGSize(width: 27, height: 27),
        thumbInteractiveSize: CGSize = CGSize(width: 44, height: 44),
        options: ValueSliderOptions = .defaultOptions,
        isRightToLeft: Bool = false
    ) {
        self.track = DefaultHorizontalValueTrack()
        self.thumb = DefaultThumb()
        self.thumbSize = thumbSize
        self.thumbInteractiveSize = thumbInteractiveSize
        self.options = options
        self.isRightToLeft = isRightToLeft
    }
}


public struct DefaultHorizontalValueTrack: View {
    public init() {}
    public var body: some View {
        HorizontalTrack()
            .frame(height: 3)
            .background(Color.secondary.opacity(0.25))
            .cornerRadius(1.5)
    }
}
