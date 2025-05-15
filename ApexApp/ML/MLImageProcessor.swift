import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

class MLImageProcessor {
    func processImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard let resizedImage = self.resizeImage(image, to: CGSize(width: 299, height: 299)),
                      let ciImage = CIImage(image: resizedImage) else {
                    DispatchQueue.main.async {
                        completion("Ошибка обработки изображения")
                    }
                    return
                }
                
                guard let model = try? exerciseClassifier1(configuration: MLModelConfiguration()),
                      let vnModel = try? VNCoreMLModel(for: model.model) else {
                    DispatchQueue.main.async {
                        completion("Ошибка загрузки модели")
                    }
                    return
                }
                
                let request = VNCoreMLRequest(model: vnModel) { request, error in
                    if let results = request.results as? [VNClassificationObservation],
                       let topResult = results.first {
                        DispatchQueue.main.async {
                            completion(topResult.identifier)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion("Неизвестно")
                        }
                    }
                }
                
                let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    DispatchQueue.main.async {
                        completion("Ошибка обработки изображения")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion("Ошибка обработки изображения")
                }
            }
        }
    }
    
    // функция сжатия изображения
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        let context = CIContext()
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let filter = CIFilter.lanczosScaleTransform()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        let targetScale = min(size.width / ciImage.extent.width, size.height / ciImage.extent.height)
        filter.setValue(targetScale, forKey: kCIInputScaleKey)
        filter.setValue(1.0, forKey: kCIInputAspectRatioKey)
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
}
