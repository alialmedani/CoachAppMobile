part of 'document_cubit.dart';

@immutable
sealed class DocumentState {}

final class DocumentInitial extends DocumentState {}

final class DocumentImagesChanged extends DocumentState {
  final List<File> selectedImages;

  DocumentImagesChanged(this.selectedImages);
}

final class DocumentUploading extends DocumentState {}

final class DocumentUploadSuccess extends DocumentState {}

final class DocumentUploadError extends DocumentState {
  final String message;

  DocumentUploadError(this.message);
}
