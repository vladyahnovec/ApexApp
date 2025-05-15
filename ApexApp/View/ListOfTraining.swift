import SwiftUI
import PhotosUI
import UIKit

struct ListOfTraining: View {
    @ObservedObject var vm: ViewModel
    @State private var showingSourceTypeSelection = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingVideoPicker = false
    @State private var selectedVideoURL: URL?
    @State private var detectedExercise: String = ""
    
    private let mlProcessor = MLImageProcessor()
    private let videoProcessor = VideoProcessor()
    
    private func mapMLResultToDisplayName(_ result: String) -> String {
        let lowercasedResult = result.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch lowercasedResult {
        case "pushup", "pushups", "отжимания":
            return "Отжимания"
        case "squat", "squats", "приседания":
            return "Приседания"
        case "biceps", "подъем на бицепс":
            return "Подъем на бицепс"
        case "deadlift", "становая тяга":
            return "Становая тяга"
        case "pullup", "подтягивания широким хватом":
            return "Подтягивания широким хватом"
        default:
            print("Unknown exercise detected: \(result)")
            return result
        }
    }

    var body: some View {
        VStack {
            // MARK: - шапка
            HeaderView(vm: vm, backTo: "Home")
                .padding(.top, 50)
            
            VStack {
                HStack {
                    Text("Список категорий")
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Medium", size: 18))
                    
                    Spacer()
                    
                    Button(action: {
                        selectedImage = nil
                        selectedVideoURL = nil
                        detectedExercise = ""
                        showingSourceTypeSelection = true
                    }) {
                        Image(systemName: "camera")
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                    }
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(vm.categories, id: \.self) { category in
                            Button(action: {
                                vm.filterExercisesByCategory(categoryID: category.id ?? "")
                                vm.currentView = "ListOfTrainingDetails"
                            }) {
                                VStack {
                                    Text(category.name)
                                        .font(.custom("Montserrat-Light", size: 25))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 20)
                                }
                                .frame(width: 350, height: 120)
                                .background(Color.darkBlueColor.opacity(0.5))
                                .background(
                                    Image(category.img)
                                        .resizable()
                                        .scaledToFill()
                                        .opacity(0.4)
                                )
                                .cornerRadius(20)
                                .foregroundStyle(Color.white)
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                
                // Отображение результата классификации
                if !detectedExercise.isEmpty {
                    Text("Распознано: \(detectedExercise)")
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Regular", size: 14))
                        .padding(.top, 10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            // MARK: - Tab Bar
            TabBarView(vm: vm)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(Color.darkBlueColorBG)
        .onAppear {
            FirebaseManager.shared.getAllCategories { result in
                switch result {
                case .success(let categories):
                    DispatchQueue.main.async {
                        vm.categories = categories
                    }
                case .failure(let error):
                    print("Error fetching categories: \(error.localizedDescription)")
                }
            }
        }
        .actionSheet(isPresented: $showingSourceTypeSelection) {
            ActionSheet(
                title: Text("Выберите источник"),
                buttons: [
                    .default(Text("Камера")) {
                        imagePickerSourceType = .camera
                        showingImagePicker = true
                    },
                    .default(Text("Галерея (фото)")) {
                        imagePickerSourceType = .photoLibrary
                        showingImagePicker = true
                    },
                    .default(Text("Галерея (видео)")) {
                        showingVideoPicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: imagePickerSourceType, selectedImage: $selectedImage)
                .onDisappear {
                    if let image = selectedImage {
                        detectedExercise = ""
                        mlProcessor.processImage(image) { result in
                            DispatchQueue.main.async {
                                detectedExercise = result
                                if !detectedExercise.isEmpty {
                                    let exerciseName = mapMLResultToDisplayName(detectedExercise)
                                    vm.getExerciseByName(name: exerciseName)
                                    vm.currentView = "ExerciseDetails"
                                }
                                selectedImage = nil
                            }
                        }
                    } else {
                        detectedExercise = ""
                    }
                }
        }
        .sheet(isPresented: $showingVideoPicker) {
            VideoPicker(selectedVideoURL: $selectedVideoURL)
                .onDisappear {
                    if let videoURL = selectedVideoURL {
                        detectedExercise = ""
                        videoProcessor.processVideo(url: videoURL) { result in
                            DispatchQueue.main.async {
                                let lines = result.split(separator: "\n")
                                if let firstLine = lines.first, let exercise = firstLine.split(separator: ":").last {
                                    detectedExercise = String(exercise.trimmingCharacters(in: .whitespaces))
                                    if !detectedExercise.isEmpty {
                                        let exerciseName = mapMLResultToDisplayName(detectedExercise)
                                        vm.getExerciseByName(name: exerciseName)
                                        vm.currentView = "ExerciseDetails"
                                    }
                                } else {
                                    detectedExercise = "Не удалось распознать упражнение"
                                }
                                selectedVideoURL = nil
                            }
                        }
                    } else {
                        detectedExercise = ""
                    }
                }
        }
    }
}

// Видеопикер для выбора видео из галереи
struct VideoPicker: UIViewControllerRepresentable {
    @Binding var selectedVideoURL: URL?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: VideoPicker

        init(_ parent: VideoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }

            provider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                if let url = url, error == nil {
                    // Копируем файл во временную директорию
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString + ".mov")
                    try? FileManager.default.copyItem(at: url, to: tempURL)
                    DispatchQueue.main.async {
                        self.parent.selectedVideoURL = tempURL
                    }
                }
            }
        }
    }
}

#Preview {
    ListOfTraining(vm: ViewModel())
}
