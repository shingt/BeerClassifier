import Foundation
import CoreML
import Vision

private let beerModelUrlString = "https://s3-ap-northeast-1.amazonaws.com/coreml/BeerClassifier2.mlmodel"
private let filename = "BeerClassifier.mlmodel"

enum ClassificationType {
    case beer3
    case beer4
}

final class ClassificationService {
    var classficationCompletion: (([VNClassificationObservation]) -> ())? = nil

    // MARK: - Core ML / Vision
    private var classificationRequest: VNCoreMLRequest? = nil

    private lazy var filePathUrl: URL = {
        var path: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let filePathUrl = URL(fileURLWithPath: "\(path)/\(filename)")
        return filePathUrl
    }()

    func setup() throws {
        try setupClassification()
    }

    func updateModel(to classificationType: ClassificationType, completion: (() -> ())? = nil) throws {
        try loadModel(classificationType: classificationType, completion: { [weak self] model in
            do {
                try self?.updateClassificationRequest(model: model)
                completion?()
            } catch let error {
                print(error)
            }
        })
    }

    func classify(cvPixelBuffer: CVPixelBuffer) {
        guard let classificationRequest = classificationRequest else { return }

        //        let cgImageOrientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
        let cgImageOrientation = CGImagePropertyOrientation(rawValue: 3)!
        let handler = VNImageRequestHandler(cvPixelBuffer: cvPixelBuffer, orientation: cgImageOrientation, options: [:])
        DispatchQueue.global(qos: .background).async {
            do {
                try handler.perform([classificationRequest])
            } catch let error {
                print(error)
            }
        }
    }

    // MARK: - Private

    private func setupClassification() throws {
        let model = loadLocal()
        try updateClassificationRequest(model: model)
    }

    private func loadModel(classificationType: ClassificationType, completion: ((MLModel) -> ())? = nil) throws {
        switch classificationType {
        case .beer3:
            let model = loadLocal()
            completion?(model)
        case .beer4:
            DispatchQueue.global(qos: .userInitiated).async {
                // For this sample app model isn't reused on purpose,
                // but in real app avoid downloading model again and again.
                do {
                    print("=== Start fetching / compiling model ===")
                    try self.fetchAndWrite()
                    let compiledUrl = try MLModel.compileModel(at: self.filePathUrl)
                    let model = try MLModel(contentsOf: compiledUrl)
                    print("=== Finish model preparation ===")
                    completion?(model)
                } catch let error {
                    print(error)
                }
            }
        }
    }

    private func fetchAndWrite() throws {
        let url = URL(string: beerModelUrlString)!
        let data = try Data(contentsOf: url)
        try data.write(to: filePathUrl)
    }

    private func loadLocal() -> MLModel {
        let model = BeerClassifier()
        return model.model
    }

    private func updateClassificationRequest(model: MLModel) throws {
        let visionCoreMLModel = try VNCoreMLModel(for: model)
        let request = VNCoreMLRequest(model: visionCoreMLModel, completionHandler: { [weak self] (request, error) in
            if let error = error {
                print(error); return
            }
            guard let classifications = request.results as? [VNClassificationObservation] else {
                return
            }

            self?.classficationCompletion?(classifications)
        })

        request.imageCropAndScaleOption = .centerCrop
        classificationRequest = request
    }
}
