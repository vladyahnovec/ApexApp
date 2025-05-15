import AVFoundation
import Vision
import CoreML
import UIKit

class VideoProcessor {
    private let model: ExerciseClassifier21
    private let sequenceLength = 60
    private let keypointCount = 18
    private let coordinateCount = 3
    
    private let visionQueue = DispatchQueue(label: "com.videoProcessor.vision")

    init() {
        print("VideoProcessor: Инициализация начата")
        guard let coreMLModel = try? ExerciseClassifier21(configuration: .init()) else {
            fatalError("VideoProcessor: Не удалось загрузить модель ExerciseClassifier21")
        }
        self.model = coreMLModel
        print("VideoProcessor: Модель ExerciseClassifier21 успешно загружена")
    }

    func processVideo(url: URL, completion: @escaping (String) -> Void) {
        print("processVideo: Начало обработки видео с URL: \(url)")
        let asset = AVAsset(url: url)
        
        do {
            print("processVideo: Создание AVAssetReader")
            let reader = try AVAssetReader(asset: asset)
            
            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                print("processVideo: Ошибка: Видео не содержит видеотрека")
                completion("Ошибка: Видео не содержит видеотрека")
                return
            }
            
            let fps = videoTrack.nominalFrameRate
            print("processVideo: Частота кадров: \(fps) FPS")

            let outputSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            print("processVideo: Настройка AVAssetReaderTrackOutput")
            let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
            readerOutput.alwaysCopiesSampleData = false
            reader.add(readerOutput)
            print("processVideo: Начало чтения видео")
            reader.startReading()

            var frameKeypoints: [[(x: Float, y: Float, confidence: Float)]] = []
            var frameCount = 0
            var segmentResults: [String] = []
            var segmentIndex = 1

            while reader.status == .reading {
                guard let sampleBuffer = readerOutput.copyNextSampleBuffer(),
                      let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                    print("processVideo: Пропущен кадр (нет sampleBuffer или pixelBuffer)")
                    continue
                }

                print("processVideo: Обработка кадра #\(frameCount + 1)")
                let poseRequest = VNDetectHumanBodyPoseRequest { [weak self] request, error in
                    guard let self = self else {
                        print("processVideo: Ошибка: self недоступен в замыкании")
                        return
                    }
                    if let error = error {
                        print("processVideo: Ошибка в VNDetectHumanBodyPoseRequest: \(error.localizedDescription)")
                        return
                    }
                    guard let observations = request.results as? [VNHumanBodyPoseObservation],
                          let observation = observations.first else {
                        print("processVideo: Нет наблюдений позы для кадра #\(frameCount + 1)")
                        return
                    }
                    print("processVideo: Извлечение ключевых точек для кадра #\(frameCount + 1)")
                    let keypoints = self.extractKeypoints(from: observation)
                    frameKeypoints.append(keypoints)
                }

                print("processVideo: Выполнение VNImageRequestHandler для кадра #\(frameCount + 1)")
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                do {
                    try handler.perform([poseRequest])
                } catch {
                    print("processVideo: Ошибка выполнения VNImageRequestHandler: \(error.localizedDescription)")
                }
                frameCount += 1

                if frameKeypoints.count >= self.sequenceLength {
                    print("processVideo: Классификация сегмента \(segmentIndex) с \(self.sequenceLength) кадрами")
                    let result = self.classifySequence(Array(frameKeypoints.prefix(self.sequenceLength)))
                    segmentResults.append("Сегмент \(segmentIndex) (\(Float(self.sequenceLength) / Float(fps)) сек): \(result)")
                    print("processVideo: Результат сегмента \(segmentIndex): \(result)")
                    segmentIndex += 1
                    frameKeypoints.removeFirst(self.sequenceLength)
                    print("processVideo: Удалено \(self.sequenceLength) кадров из frameKeypoints, осталось: \(frameKeypoints.count)")
                }
            }

            print("processVideo: Завершено чтение видео, обработано \(frameCount) кадров")
            if !frameKeypoints.isEmpty {
                let paddingFrames = self.sequenceLength - frameKeypoints.count
                print("processVideo: Обработка оставшихся \(frameKeypoints.count) кадров, требуется padding: \(paddingFrames)")
                if paddingFrames > 0 {
                    let padding = Array(repeating: (x: Float(0.0), y: Float(0.0), confidence: Float(0.0)), count: self.keypointCount)
                    let paddingArray = Array(repeating: padding, count: paddingFrames)
                    frameKeypoints.append(contentsOf: paddingArray)
                    print("processVideo: Добавлено \(paddingFrames) кадров padding")
                }
                print("processVideo: Классификация финального сегмента \(segmentIndex)")
                let result = self.classifySequence(frameKeypoints)
                segmentResults.append("Сегмент \(segmentIndex) (\(Float(frameKeypoints.count) / Float(fps)) сек): \(result)")
                print("processVideo: Результат финального сегмента \(segmentIndex): \(result)")
            }

            let finalResult = segmentResults.isEmpty ? "Обработано \(frameCount) кадров, но недостаточно данных" : segmentResults.joined(separator: "\n")
            print("processVideo: Завершение обработки, результат:\n\(finalResult)")
            completion(finalResult)
            
        } catch {
            print("processVideo: Ошибка создания AVAssetReader: \(error.localizedDescription)")
            completion("Ошибка создания AVAssetReader: \(error.localizedDescription)")
            return
        }
    }

    private func extractKeypoints(from observation: VNHumanBodyPoseObservation) -> [(x: Float, y: Float, confidence: Float)] {
        print("extractKeypoints: Начало извлечения ключевых точек")
        let recognizedPoints = try? observation.recognizedPoints(.all)
        let keypointNames: [VNHumanBodyPoseObservation.JointName] = [
            .leftShoulder, .leftElbow, .leftWrist,
            .rightShoulder, .rightElbow, .rightWrist,
            .leftHip, .leftKnee, .leftAnkle,
            .rightHip, .rightKnee, .rightAnkle,
            .neck, .root, .nose, .leftEye, .rightEye, .leftEar
        ]

        var keypoints: [(x: Float, y: Float, confidence: Float)] = []
        for (index, name) in keypointNames.prefix(keypointCount).enumerated() {
            if let point = recognizedPoints?[name], point.confidence > 0 {
                let keypoint = (x: Float(point.location.x), y: Float(point.location.y), confidence: Float(point.confidence))
                keypoints.append(keypoint)
                print("extractKeypoints: Точка \(name.rawValue) (#\(index + 1)): x=\(keypoint.x), y=\(keypoint.y), confidence=\(keypoint.confidence)")
            } else {
                keypoints.append((x: Float(0.0), y: Float(0.0), confidence: Float(0.0)))
                print("extractKeypoints: Точка \(name.rawValue) (#\(index + 1)): не обнаружена, используется (0.0, 0.0, 0.0)")
            }
        }
        print("extractKeypoints: Извлечено \(keypoints.count) ключевых точек")
        return keypoints
    }

    private func classifySequence(_ keypoints: [[(x: Float, y: Float, confidence: Float)]]) -> String {
        print("classifySequence: Начало классификации последовательности, кадров: \(keypoints.count)")
        guard keypoints.count == sequenceLength else {
            let error = "Ошибка: Недостаточно кадров (\(keypoints.count) вместо \(sequenceLength))"
            print("classifySequence: \(error)")
            return error
        }
        for (index, frame) in keypoints.enumerated() {
            guard frame.count == keypointCount else {
                let error = "Ошибка: Недостаточно ключевых точек (\(frame.count) вместо \(keypointCount)) в кадре \(index + 1)"
                print("classifySequence: \(error)")
                return error
            }
        }

        print("classifySequence: Создание MLMultiArray")
        guard let multiArray = try? MLMultiArray(shape: [sequenceLength as NSNumber, coordinateCount as NSNumber, keypointCount as NSNumber], dataType: .float32) else {
            let error = "Ошибка: Не удалось создать MLMultiArray"
            print("classifySequence: \(error)")
            return error
        }

        print("classifySequence: Заполнение MLMultiArray")
        for t in 0..<sequenceLength {
            for k in 0..<keypointCount {
                let point = keypoints[t][k]
                multiArray[[t, 0, k] as [NSNumber]] = NSNumber(value: point.x)
                multiArray[[t, 1, k] as [NSNumber]] = NSNumber(value: point.y)
                multiArray[[t, 2, k] as [NSNumber]] = NSNumber(value: point.confidence)
            }
        }

        print("classifySequence: Создание входных данных для модели")
        guard let input = try? ExerciseClassifier21Input(poses: multiArray) else {
            let error = "Ошибка: Не удалось создать входные данные для модели"
            print("classifySequence: \(error)")
            return error
        }

        print("classifySequence: Выполнение предсказания")
        do {
            let prediction = try model.prediction(input: input)
            print("classifySequence: Предсказание успешно, результат: \(prediction.label)")
            return prediction.label
        } catch {
            let error = "Ошибка выполнения предсказания: \(error.localizedDescription)"
            print("classifySequence: \(error)")
            return error
        }
    }
}
