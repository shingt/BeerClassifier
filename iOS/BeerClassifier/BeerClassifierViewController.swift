import UIKit
import AVFoundation

final class BeerClassifierViewController: UIViewController {
    private let classificationService = ClassificationService()

    // MARK: - AVFoundation
    private var session: AVCaptureSession?
    private lazy var device: AVCaptureDevice? = {
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        return device
    }()
    private lazy var deviceInput: AVCaptureDeviceInput? = {
        guard let device = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: device)
        } catch {
            print("Failed to initialize AVCaptureDeviceInput." ); return nil
        }
    }()
    private lazy var videoDataOutput: AVCaptureVideoDataOutput = {
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
        return videoDataOutput
    }()
    private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer? = {
        guard let session = session else { return nil }
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.frame = view.frame
        layer.connection?.videoOrientation = .portrait
        layer.videoGravity = .resizeAspect
        return layer
    }()
    private lazy var sampleBufferQueue: DispatchQueue = {
        return DispatchQueue(label: "sample.queue")
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setup()
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                guard granted else { print("You need to authorize camera access in this app."); return }
                DispatchQueue.main.async {
                    self?.setup()
                    self?.startSession()
                }
            })
        default:
            print("You need to authorize camera access in this app."); break
        }
    }

    private func setup() {
        setupSession()
        do {
            try setupClassification()
        } catch let error {
            print(error)
        }
        setupViews()
    }

    private func setupSession() {
        guard let deviceInput = deviceInput else { return }
        let session = AVCaptureSession()
        session.addInput(deviceInput)
        session.addOutput(videoDataOutput)
        self.session = session
    }

    private func setupClassification() throws {
        try classificationService.setup()
        classificationService.classficationCompletion = { [weak self] classifications in
            guard let topClassification = classifications.first else {
                print("no top classification!"); return
            }
            print("topClassification identifier: \(topClassification.identifier), confidence: \(topClassification.confidence)")

            DispatchQueue.main.async {
                self?.resultLabel.text = topClassification.identifier.replacingCharacter(at: 2, with: "*")
                self?.confidenceLabel.text = "\(topClassification.confidence * 100)%"
            }
        }
    }

    private func setupViews() {
        if let videoPreviewLayer = videoPreviewLayer {
            view.layer.addSublayer(videoPreviewLayer)
        }

        [
            changeModelButton,
            resultLabel,
            confidenceLabel,
            downloadingIndicatorView
            ].forEach { view.addSubview($0) }
        view.setNeedsUpdateConstraints()
    }

    private func startSession() {
        session?.startRunning()
    }

    @objc func changeModelButtonTapped() {
        downloadingIndicatorView.startAnimating()
        do {
            try classificationService.updateModel(to: .beer4, completion: {
                DispatchQueue.main.async {
                    self.downloadingIndicatorView.stopAnimating()
                }
            })
        } catch let error {
            print(error)
            DispatchQueue.main.async {
                self.downloadingIndicatorView.stopAnimating()
            }
        }
    }

    // MARK: - UI

    private let textBackgroundColor = UIColor(white: 0.0, alpha: 0.6)
    private lazy var changeModelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Download\nNew Model", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = textBackgroundColor
        button.sizeToFit()
        button.addTarget(self, action: #selector(changeModelButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 40)
        label.textColor = .white
        label.backgroundColor = textBackgroundColor
        label.text = "Test"
        label.sizeToFit()
        return label
    }()
    private lazy var confidenceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .white
        label.backgroundColor = textBackgroundColor
        label.text = "100%"
        label.sizeToFit()
        return label
    }()
    private lazy var downloadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .whiteLarge)
        indicatorView.backgroundColor = textBackgroundColor
        indicatorView.isHidden = true
        return indicatorView
    }()

    private var didSetupConstraints = false
    override func updateViewConstraints() {
        func setupConstraints() {
            [
                changeModelButton,
                resultLabel,
                confidenceLabel,
                downloadingIndicatorView
                ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
            [
                changeModelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40.0),
                changeModelButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40.0),
                resultLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100.0),
                resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                confidenceLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 16.0),
                confidenceLabel.centerXAnchor.constraint(equalTo: resultLabel.centerXAnchor),
                downloadingIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                downloadingIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ].forEach { $0.isActive = true }
        }
        if !didSetupConstraints {
            setupConstraints()
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate
extension BeerClassifierViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cvImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard !classificationService.processing else { return }

        classificationService.classify(cvPixelBuffer: cvImageBuffer)
    }
}

extension String {
    func replacingCharacter(at index: Int, with replacement: String) -> String {
        guard count > index else { return self }
        return String(prefix(index)) + replacement + String(dropFirst(index + 1))
    }
}

