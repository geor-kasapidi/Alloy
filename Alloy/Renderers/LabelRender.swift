import Metal

final public class LabelsRender {

    final public class LabelDescriptor {
        let textDescriptor: TextRender.TextMeshDescriptor
        let rectDescriptor: RectangleRender.RectangleDescriptor
        public init(textDescriptor: TextRender.TextMeshDescriptor,
                    rectDescriptor: RectangleRender.RectangleDescriptor) {
            self.textDescriptor = textDescriptor
            self.rectDescriptor = rectDescriptor
        }

        public convenience init(text: String,
                                textColor: CGColor,
                                labelColor: CGColor,
                                normalizedRect: CGRect) {
            self.init(textDescriptor: .init(text: text,
                                            normalizedRect: normalizedRect,
                                            color: textColor),
                      rectDescriptor: .init(color: labelColor,
                                            normalizedRect: normalizedRect))
        }
    }

    // MARK: - Properties

    public var descriptors: [LabelDescriptor] = [] {
        didSet {
            self.rectangleRender
                .descriptors = self.descriptors
                                   .map { $0.rectDescriptor }
            self.textRender
                .descriptors = self.descriptors
                                   .map { $0.textDescriptor }
        }
    }
    public var renderTargetSize: MTLSize = .zero {
        didSet {
            self.textRender.renderTargetSize = self.renderTargetSize
        }
    }

    private let textRender: TextRender
    private let rectangleRender: RectangleRender

    // MARK: - Life Cicle

    public convenience init(context: MTLContext,
                            fontAtlas: MTLFontAtlas) throws {
        try self.init(library: context.library(for: Self.self),
                      fontAtlas: fontAtlas)
    }

    public init(library: MTLLibrary,
                fontAtlas: MTLFontAtlas) throws {
        self.textRender = try .init(library: library,
                                    fontAtlas: fontAtlas)
        self.rectangleRender = try .init(library: library)
    }

    // MARK: - Helpers
    

    // MARK: - Rendering

    public func render(renderPassDescriptor: MTLRenderPassDescriptor,
                       commandBuffer: MTLCommandBuffer) throws {
        self.renderTargetSize = renderPassDescriptor.colorAttachments[0].texture?.size ?? .zero
        commandBuffer.render(descriptor: renderPassDescriptor,
                             self.render(using:))
    }

    public func render(using renderEncoder: MTLRenderCommandEncoder) {
        #if DEBUG
        renderEncoder.pushDebugGroup("Draw Labels Geometry")
        #endif
        self.rectangleRender.render(using: renderEncoder)
        self.textRender.render(using: renderEncoder)
        #if DEBUG
        renderEncoder.popDebugGroup()
        #endif
    }

    public static let vertexFunctionName = "textVertex"
    public static let fragmentFunctionName = "textFragment"
}