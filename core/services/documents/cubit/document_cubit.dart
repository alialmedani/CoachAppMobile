import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:extended_image/extended_image.dart';
 import 'package:meta/meta.dart';
import '../../../results/result.dart';
import '../data/repository/repo.dart';
import '../data/usecase/delete_document_usecase.dart';
import '../data/usecase/upload_current_user_document_usecase.dart';
import '../data/usecase/upload_many_document_usecase.dart';
import '../data/usecase/upload_one_document_usecase.dart';
part 'document_state.dart';

class DocumentCubit extends Cubit<DocumentState> {
  DocumentCubit() : super(DocumentInitial());

  List<File> _selectedImages = [];
  List<File> get selectedImages => List.unmodifiable(_selectedImages);

  UploadCurrentUserDocumentParams uploadCurrentUserDocumentParams =
      UploadCurrentUserDocumentParams(photo: [], masterType: "");

  UploadManyDocumentParams uploadManyDocumentParams = UploadManyDocumentParams(
    photos: [],
    masterType: "",
    masterId: "",
    entityType: 0,
  );

  UploadOneDocumentParams uploadDocumentParams = UploadOneDocumentParams(
    photo: File(""),
    masterType: "complaint",
    masterId: "",
    entityType: 12,
  );

  void addImage(File image) {
    _selectedImages.add(image);
    emit(DocumentImagesChanged(_selectedImages));
    _updateCubitParameters();
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      emit(DocumentImagesChanged(_selectedImages));
      _updateCubitParameters();
    }
  }

  void clearImages() {
    _selectedImages.clear();
    emit(DocumentImagesChanged(_selectedImages));
    _updateCubitParameters();
  }

  void setImages(List<File> images) {
    _selectedImages = List.from(images);
    emit(DocumentImagesChanged(_selectedImages));
    _updateCubitParameters();
  }

  void _updateCubitParameters() {
    uploadCurrentUserDocumentParams.photo = _selectedImages;
    uploadManyDocumentParams.photos = _selectedImages;
    if (_selectedImages.isNotEmpty) {
      uploadDocumentParams.photo = _selectedImages.first;
    }
  }

  void setUploadParameters({
    int? entityType,
    String? masterId,
    String? masterType,
  }) {
    if (entityType != null) {
      uploadManyDocumentParams.entityType = entityType;
      uploadDocumentParams.entityType = entityType;
    }
    if (masterId != null) {
      uploadManyDocumentParams.masterId = masterId;
      uploadDocumentParams.masterId = masterId;
    }
    if (masterType != null) {
      uploadManyDocumentParams.masterType = masterType;
      uploadDocumentParams.masterType = masterType;
      uploadCurrentUserDocumentParams.masterType = masterType;
    }
  }

  Future<Result> deleteDocument(String id) async {
    return await DeleteDocumentUseCase(
      DocumentRepository(),
    ).call(params: DeleteDocumentParams(id: id));
  }

  Future<Result> uploadCurrentUserDocument() async {
    emit(DocumentUploading());
    try {
      final result = await UploadCurrentUserDocumentUseCase(
        DocumentRepository(),
      ).call(params: uploadCurrentUserDocumentParams);

      if (result.hasDataOnly) {
        emit(DocumentUploadSuccess());
        clearImages();
      } else {
        emit(DocumentUploadError(result.error ?? 'Upload failed'));
      }
      return result;
    } catch (e) {
      emit(DocumentUploadError(e.toString()));
      return Result(error: e.toString());
    }
  }

  Future<Result> uploadManyDocument() async {
    emit(DocumentUploading());
    try {
      final result = await UploadManyDocumentUseCase(
        DocumentRepository(),
      ).call(params: uploadManyDocumentParams);

      if (result.hasDataOnly) {
        emit(DocumentUploadSuccess());
        clearImages();
      } else {
        emit(DocumentUploadError(result.error ?? 'Upload failed'));
      }
      return result;
    } catch (e) {
      emit(DocumentUploadError(e.toString()));
      return Result(error: e.toString());
    }
  }

  Future<Result> uploadDocument() async {
    emit(DocumentUploading());
    try {
      final result = await UploadOneDocumentUseCase(
        DocumentRepository(),
      ).call(params: uploadDocumentParams);

      if (result.hasDataOnly) {
        emit(DocumentUploadSuccess());
        clearImages();
      } else {
        emit(DocumentUploadError(result.error ?? 'Upload failed'));
      }
      return result;
    } catch (e) {
      emit(DocumentUploadError(e.toString()));
      return Result(error: e.toString());
    }
  }

  Future<void> purgeImageCache(String url, {String? cacheKey}) async {
    clearMemoryImageCache();
    await clearDiskCachedImage(url, cacheKey: cacheKey);
  }
}
