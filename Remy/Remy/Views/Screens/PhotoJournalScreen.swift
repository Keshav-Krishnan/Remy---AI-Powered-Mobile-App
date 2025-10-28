//
//  PhotoJournalScreen.swift
//  Remy
//
//  Created by Claude Code on 10/18/25.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct PhotoJournalScreen: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: JournalViewModel

    @State private var caption = ""
    @State private var selectedMood: MoodTag?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var showPermissionAlert = false
    @State private var permissionAlertMessage = ""
    @FocusState private var isCaptionFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                // Warm background
                Color(hex: "#F7F1E3")
                    .ignoresSafeArea()

                // Decorative corner
                CornerEngraving(pattern: .flower, corner: .topRight, opacity: 0.05)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Decorative header
                        DecorativeHeader(
                            title: "Photo Journal",
                            subtitle: "Capture your memories",
                            pattern: .star
                        )
                        .padding(.top, 8)

                        // Photo Selection Area
                        VStack(spacing: 20) {
                            if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                                // Display selected photo
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                                    .cornerRadius(24)
                                    .clipped()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color(hex: "#E8DCD1"), lineWidth: 2)
                                    )
                                    .shadow(color: Color(hex: "#6B4F3B").opacity(0.15), radius: 20, x: 0, y: 8)
                            } else if let capturedImage = capturedImage {
                                // Display captured photo
                                Image(uiImage: capturedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                                    .cornerRadius(24)
                                    .clipped()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color(hex: "#E8DCD1"), lineWidth: 2)
                                    )
                                    .shadow(color: Color(hex: "#6B4F3B").opacity(0.15), radius: 20, x: 0, y: 8)
                            } else {
                                // Placeholder
                                VStack(spacing: 16) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 50, weight: .medium))
                                        .foregroundColor(Color(hex: "#8B6F4B").opacity(0.4))

                                    Text("Add a photo to your journal")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "#8B6F4B"))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                                .background(Color.white)
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color(hex: "#E8DCD1"), lineWidth: 2)
                                )
                            }

                            // Photo action buttons
                            HStack(spacing: 12) {
                                PhotosPickerButton(selectedItem: $selectedPhoto)
                                CameraButton(action: { checkCameraPermissionAndOpen() })
                            }
                        }
                        .padding(.horizontal, 24)

                        // Caption
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Caption")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "#4A2C1A"))

                            TextEditor(text: $caption)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color(hex: "#2C2C2C"))
                                .frame(height: 120)
                                .scrollContentBackground(.hidden)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(hex: "#E8DCD1"), lineWidth: 1.5)
                                )
                                .shadow(color: Color(hex: "#6B4F3B").opacity(0.06), radius: 12, x: 0, y: 4)
                                .focused($isCaptionFocused)

                            if caption.isEmpty {
                                Text("What's the story behind this photo?")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(hex: "#8E8E93"))
                                    .padding(.top, -132)
                                    .padding(.leading, 32)
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(.horizontal, 24)

                        // Mood Selector
                        MoodSelectorSection(selectedMood: $selectedMood)
                            .padding(.horizontal, 24)

                        // Save Button
                        SavePhotoJournalButton(
                            caption: caption,
                            hasPhoto: selectedImageData != nil || capturedImage != nil
                        ) {
                            savePhotoJournal()
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#8B6F4B"))
                    }
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(image: $capturedImage)
            }
            .alert("Camera Permission Required", isPresented: $showPermissionAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Open Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            } message: {
                Text(permissionAlertMessage)
            }
        }
    }

    private func checkCameraPermissionAndOpen() {
        // First check if camera is available
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            permissionAlertMessage = "Camera is not available on this device. Please use the Photo Library option instead."
            showPermissionAlert = true
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Permission already granted
            showCamera = true

        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showCamera = true
                    } else {
                        permissionAlertMessage = "Camera access is required to take photos for your journal. Please grant permission in Settings."
                        showPermissionAlert = true
                    }
                }
            }

        case .denied, .restricted:
            // Permission denied or restricted
            permissionAlertMessage = "Camera access was denied. Please enable it in Settings to take photos for your journal."
            showPermissionAlert = true

        @unknown default:
            break
        }
    }

    private func savePhotoJournal() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        Task {
            let entry = JournalEntry(
                content: caption,
                journalType: .photo,
                moodTag: selectedMood
            )

            // Check if we have photo data to upload
            if let imageData = selectedImageData {
                // Upload photo with entry
                await viewModel.createEntryWithPhoto(entry, photoData: imageData)
            } else if let capturedImage = capturedImage,
                      let jpegData = capturedImage.jpegData(compressionQuality: 0.8) {
                // Upload captured photo
                await viewModel.createEntryWithPhoto(entry, photoData: jpegData)
            } else {
                // No photo - just save text entry
                await viewModel.createEntry(entry)
            }

            isPresented = false
        }
    }
}

// MARK: - PhotosPicker Button
struct PhotosPickerButton: View {
    @Binding var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            HStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 16, weight: .medium))
                Text("Photo Library")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#6B4F3B"), Color(hex: "#8B6F4B")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color(hex: "#6B4F3B").opacity(0.25), radius: 12, x: 0, y: 4)
        }
    }
}

// MARK: - Camera Button
struct CameraButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 16, weight: .medium))
                Text("Take Photo")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundColor(Color(hex: "#6B4F3B"))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#6B4F3B"), lineWidth: 2)
            )
            .shadow(color: Color(hex: "#6B4F3B").opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Camera View (UIImagePickerController wrapper)
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIViewController {
        // Check if camera is available
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            // Return a view controller with an error message
            let errorVC = UIViewController()
            let label = UILabel()
            label.text = "Camera not available"
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            errorVC.view.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: errorVC.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: errorVC.view.centerYAnchor)
            ])

            // Dismiss automatically after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }

            return errorVC
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Mood Selector Section
struct MoodSelectorSection: View {
    @Binding var selectedMood: MoodTag?

    let moods: [MoodTag] = [.happy, .grateful, .excited, .neutral, .sad, .anxious]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How are you feeling?")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "#4A2C1A"))

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(moods, id: \.self) { mood in
                    MoodButton(mood: mood, isSelected: selectedMood == mood) {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        selectedMood = mood
                    }
                }
            }
        }
    }
}

// MARK: - Save Button
struct SavePhotoJournalButton: View {
    let caption: String
    let hasPhoto: Bool
    let action: () -> Void

    private var isEnabled: Bool {
        !caption.isEmpty && hasPhoto
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                Text("Save Photo Journal")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: isEnabled
                        ? [Color(hex: "#6B4F3B"), Color(hex: "#8B6F4B")]
                        : [Color(hex: "#E8DCD1"), Color(hex: "#E8DCD1")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(28)
            .shadow(
                color: isEnabled ? Color(hex: "#6B4F3B").opacity(0.3) : Color.clear,
                radius: 15,
                x: 0,
                y: 8
            )
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    PhotoJournalScreen(isPresented: .constant(true))
        .environmentObject(JournalViewModel())
}
