# 📱 JasimExpress Mobile - AI Integration Guide

> **Purpose**: This guide provides comprehensive documentation for AI assistants to understand the codebase structure and create new features following established patterns.

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture & Design Patterns](#architecture--design-patterns)
3. [Project Structure](#project-structure)
4. [Feature Development Pattern](#feature-development-pattern)
5. [Data Layer](#data-layer)
6. [State Management](#state-management)
7. [UI Layer](#ui-layer)
8. [Core Components](#core-components)
9. [Design System](#design-system)
10. [API Integration](#api-integration)
11. [Navigation](#navigation)
12. [Step-by-Step: Creating New Features](#step-by-step-creating-new-features)
13. [Code Examples](#code-examples)
14. [Best Practices](#best-practices)

---

## 🎯 Project Overview

### Technology Stack
- **Framework**: Flutter (Dart)
- **State Management**: BLoC/Cubit (flutter_bloc)
- **Dependency Injection**: GetIt
- **Local Storage**: Hive
- **API Communication**: Dio (via ApiProvider)
- **Localization**: EasyLocalization (AR/EN)
- **UI Scaling**: ScreenUtil
- **Functional Programming**: Dartz (Either, Result)

### Application Type
**JasimExpress** is an ERP-based Express Delivery & E-commerce mobile application with multiple user roles:

- 🛍️ **Merchant**: Create products, manage orders, track deliveries, handle settlements
- 🚗 **Driver**: Accept orders, deliver packages, manage delivery sessions
- 📦 **Employee**: Package management, hub operations, inventory control
- 👤 **Admin**: System management (implied)

---

## 🏗️ Architecture & Design Patterns

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│   (Screens, Widgets, Cubits)       │
├─────────────────────────────────────┤
│         Domain Layer                │
│   (Use Cases, Business Logic)       │
├─────────────────────────────────────┤
│         Data Layer                  │
│   (Models, Repositories, API)       │
└─────────────────────────────────────┘
```

### Design Patterns Used

1. **Repository Pattern**: Abstracts data sources
2. **Use Case Pattern**: Single responsibility business logic
3. **BLoC/Cubit Pattern**: State management
4. **Dependency Injection**: GetIt for loose coupling
5. **Result Pattern**: Either<Error, Success> for error handling
6. **Factory Pattern**: Model converters

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point, BlocProviders, DI setup
├── firebase_options.dart              # Firebase configuration
│
├── core/                              # Shared/reusable components
│   ├── boilerplate/                   # Generic patterns
│   │   ├── create_model/              # Generic CRUD create
│   │   ├── get_model/                 # Generic CRUD read
│   │   └── pagination/                # Pagination logic
│   │       ├── cubits/
│   │       │   ├── pagination_cubit.dart
│   │       │   └── pagination_state.dart
│   │       └── models/
│   │           └── get_list_request.dart
│   │
│   ├── classes/                       # Core utilities
│   │   ├── cashe_helper.dart          # Hive storage wrapper
│   │   ├── keys.dart                  # Global keys
│   │   └── notification.dart          # Firebase notifications
│   │
│   ├── constant/                      # App constants
│   │   ├── app_colors/
│   │   ├── app_design_system.dart     # Design tokens
│   │   ├── app_icons/
│   │   ├── app_images/
│   │   ├── app_responsive/
│   │   ├── app_size/
│   │   ├── app_theme/
│   │   ├── end_points/
│   │   │   ├── api_url.dart           # API endpoints
│   │   │   └── cashe_helper_constant.dart
│   │   ├── enum/
│   │   └── text_styles/
│   │
│   ├── data_source/
│   │   └── remote_data_source.dart    # HTTP request wrapper
│   │
│   ├── di/
│   │   └── injection.dart             # GetIt DI configuration
│   │
│   ├── enums/                         # Global enums
│   ├── http/
│   │   ├── api_provider.dart          # Dio wrapper
│   │   └── http_method.dart           # GET, POST, PUT, DELETE
│   │
│   ├── models/                        # Shared models
│   ├── params/
│   │   └── base_params.dart           # Base class for use case params
│   │
│   ├── repository/
│   │   └── core_repository.dart       # Abstract repository
│   │
│   ├── results/
│   │   └── result.dart                # Result wrapper classes
│   │
│   ├── services/                      # Core services
│   │   ├── documents/
│   │   └── excel_export_service.dart
│   │
│   ├── theme/                         # Theme configuration
│   ├── ui/                            # Reusable UI components
│   │   ├── dialogs/
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── service_selection_screen.dart
│   │   │   └── base_hens_state_screen.dart
│   │   └── widgets/
│   │       ├── animated_notch_navigation_bar.dart
│   │       ├── cached_image.dart
│   │       ├── custom_button.dart
│   │       ├── custom_text_form_field.dart
│   │       ├── loading.dart
│   │       ├── no_data_screen.dart
│   │       └── modern/                # Modern design components
│   │           ├── app_badge.dart
│   │           ├── app_button.dart
│   │           ├── app_card.dart
│   │           ├── app_empty_state.dart
│   │           ├── app_form_components.dart
│   │           ├── app_loading.dart
│   │           ├── app_text_field.dart
│   │           ├── app_top_bar.dart
│   │           └── modern_components.dart
│   │
│   ├── usecase/
│   │   └── usecase.dart               # Abstract UseCase class
│   │
│   ├── utils/                         # Utility functions
│   │   ├── functions/
│   │   │   ├── app_logo_provider.dart
│   │   │   ├── app_validators.dart
│   │   │   ├── location.dart
│   │   │   ├── reg_exp.dart
│   │   │   └── token_validator.dart
│   │   └── Navigation/
│   │
│   └── variables/                     # Global variables
│
└── features/                          # Feature modules
    └── Express/                       # Main app features
        ├── app_info/                  # App version & updates
        │   ├── data/
        │   │   ├── model/
        │   │   ├── repository/
        │   │   └── usecase/
        │   └── screen/
        │
        ├── auth/                      # Authentication
        │   ├── cubit/
        │   │   ├── auth_cubit.dart
        │   │   └── auth_state.dart
        │   ├── data/
        │   │   ├── model/
        │   │   │   ├── login_model.dart
        │   │   │   ├── current_user_model.dart
        │   │   │   ├── send_otp_model.dart
        │   │   │   ├── verify_otp_model.dart
        │   │   │   ├── register_merchant_model.dart
        │   │   │   └── register_driver_model.dart
        │   │   ├── repository/
        │   │   │   └── auth_repository.dart
        │   │   └── usecase/
        │   │       ├── login_usecase.dart
        │   │       ├── send_otp_usecase.dart
        │   │       ├── verify_otp_usecase.dart
        │   │       ├── register_merchant_usecase.dart
        │   │       ├── change_password_usecase.dart
        │   │       └── get_app_config_usecase.dart
        │   └── screen/
        │       ├── login_screen.dart
        │       ├── register_phone_screen.dart
        │       ├── register_otp_screen.dart
        │       ├── register_merchant_screen.dart
        │       ├── forgot_password_phone_screen.dart
        │       ├── forgot_password_otp_screen.dart
        │       ├── forgot_password_new_password_screen.dart
        │       ├── force_change_password_screen.dart
        │       └── change_password_screen.dart
        │
        ├── delivery/                  # Delivery management
        │   ├── cubit/
        │   ├── data/
        │   └── screen/
        │       ├── delivery_home_screen.dart
        │       ├── delivery_my_orders_screen.dart
        │       ├── delivery_sessions_list_screen.dart
        │       ├── delivery_settlements_screen.dart
        │       ├── delivery_batch_qr_scan_screen.dart
        │       └── my_returns_screen.dart
        │
        ├── driver/                    # Driver operations
        │   ├── cubit/
        │   │   ├── driver_cubit.dart
        │   │   └── driver_state.dart
        │   ├── data/
        │   │   ├── model/
        │   │   │   ├── driver_profile_model.dart
        │   │   │   ├── driver_dashboard_model.dart
        │   │   │   ├── driver_assignment_model.dart
        │   │   │   ├── delivery_model.dart
        │   │   │   └── batch_qr_update_model.dart
        │   │   ├── repository/
        │   │   └── usecase/
        │   └── screen/
        │       ├── driver_home_screen.dart
        │       ├── my_orders_screen.dart
        │       ├── driver_order_actions_screen.dart
        │       ├── driver_settlements_screen.dart
        │       ├── batch_qr_scan_screen.dart
        │       └── my_returns_screen.dart
        │
        ├── employee/                  # Hub employee operations
        │   ├── cubit/
        │   │   ├── package_management_cubit.dart
        │   │   └── package_management_state.dart
        │   ├── data/
        │   │   ├── model/
        │   │   │   ├── employee_profile_model.dart
        │   │   │   ├── hub_model.dart
        │   │   │   ├── receive_package_model.dart
        │   │   │   └── release_package_model.dart
        │   │   ├── repository/
        │   │   └── usecase/
        │   └── screen/
        │       ├── package_management_home_screen.dart
        │       ├── receive_package_screen.dart
        │       ├── release_package_screen.dart
        │       ├── hub_list_screen.dart
        │       ├── hub_details_screen.dart
        │       ├── hub_inventory_screen.dart
        │       ├── order_returns_list_screen.dart
        │       └── scan_qr_screen.dart
        │
        ├── orders_returns/            # Order returns
        │   ├── cubit/
        │   ├── data/
        │   └── screen/
        │       └── create_order_return_screen.dart
        │
        ├── region/                    # Geographic regions
        │   ├── cubit/
        │   ├── data/
        │   └── screen/
        │
        └── user/                      # Merchant/user features
            ├── home/                  # Dashboard
            │   ├── cubit/
            │   │   ├── merchant_home_cubit.dart
            │   │   └── merchant_home_state.dart
            │   ├── data/
            │   └── screen/
            │       ├── merchant_home_screen.dart
            │       ├── store_dashboard_screen.dart
            │       └── merchant_returns_screen.dart
            │
            ├── merchant address/      # Address management
            │   ├── cubit/
            │   ├── data/
            │   └── screen/
            │       ├── merchant_addresses_list_screen.dart
            │       ├── create_address_screen.dart
            │       ├── update_address_screen.dart
            │       ├── address_map_screen.dart
            │       └── merchant_address_details_screen.dart
            │
            ├── merchant orders/       # View orders
            │   ├── cubit/
            │   ├── data/
            │   └── screen/
            │       └── merchant_orders_screen.dart
            │
            ├── order/                 # Create orders
            │   ├── cubit/
            │   │   ├── order_cubit.dart
            │   │   └── order_state.dart
            │   ├── data/
            │   └── screen/
            │       ├── create_order_screen.dart
            │       ├── order_screen.dart
            │       └── order_details_screen.dart
            │
            ├── product/               # Product management
            │   ├── cubit/
            │   │   ├── product_cubit.dart
            │   │   └── product_state.dart
            │   ├── data/
            │   │   ├── model/
            │   │   │   ├── product_model.dart
            │   │   │   ├── product_variant_model.dart
            │   │   │   ├── category_model.dart
            │   │   │   ├── option_group_model.dart
            │   │   │   ├── property_model.dart
            │   │   │   └── media_model.dart
            │   │   ├── repository/
            │   │   │   └── product_repository.dart
            │   │   └── usecase/
            │   │       ├── create_product_usecase.dart
            │   │       ├── get_my_products_usecase.dart
            │   │       ├── get_categories_usecase.dart
            │   │       ├── get_product_variants_usecase.dart
            │   │       ├── update_product_usecase.dart
            │   │       ├── publish_product_usecase.dart
            │   │       └── upload_media_usecase.dart
            │   └── screen/
            │       ├── my_products_screen.dart
            │       ├── create_product_screen.dart
            │       ├── edit_product_screen.dart
            │       ├── product_details_screen.dart
            │       └── product_variants_screen.dart
            │
            ├── profile/               # User profile
            │   ├── cubit/
            │   ├── data/
            │   └── screen/
            │       └── profile_screen.dart
            │
            ├── settlement/            # Financial settlements
            │   ├── cubit/
            │   ├── data/
            │   └── screen/
            │       ├── settlement_requests_screen.dart
            │       ├── create_withdrawal_screen.dart
            │       └── scan_qr_screen.dart
            │
            └── user_device/           # Device registration
                ├── cubit/
                ├── data/
                └── screen/
                    └── register_user_device_screen.dart
```

---

## 🔄 Feature Development Pattern

### Standard Feature Structure

Every feature follows this structure:

```
feature_name/
├── cubit/
│   ├── feature_cubit.dart       # Business logic & state management
│   └── feature_state.dart       # State classes
├── data/
│   ├── model/
│   │   └── model_name.dart      # Data models with fromJson/toJson
│   ├── repository/
│   │   └── feature_repository.dart    # API calls
│   └── usecase/
│       └── action_usecase.dart        # Single responsibility actions
└── screen/
    ├── main_screen.dart         # Primary screen
    └── widgets/                 # Feature-specific widgets
        └── custom_widget.dart
```

---

## 📊 Data Layer

### 1. Models

**Location**: `features/{feature}/data/model/`

**Pattern**:
```dart
class ProductModel {
  final String id;
  final String name;
  final String nameAr;
  final double price;
  final int stockQuantity;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.price,
    required this.stockQuantity,
    required this.isActive,
  });

  // From JSON (API response)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      price: (json['basePrice'] ?? 0.0).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }

  // To JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'basePrice': price,
      'stockQuantity': stockQuantity,
      'isActive': isActive,
    };
  }

  // CopyWith for immutability
  ProductModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    double? price,
    int? stockQuantity,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isActive: isActive ?? this.isActive,
    );
  }
}
```

### 2. Use Cases

**Location**: `features/{feature}/data/usecase/`

**Pattern**:
```dart
import '../../../../../../core/params/base_params.dart';
import '../../../../../../core/results/result.dart';
import '../../../../../../core/usecase/usecase.dart';
import '../model/product_model.dart';
import '../repository/product_repository.dart';

// Params class (extends BaseParams)
class CreateProductParams extends BaseParams {
  final String categoryId;
  final String name;
  final String nameAr;
  final double basePrice;
  final int stockQuantity;
  
  CreateProductParams({
    required this.categoryId,
    required this.name,
    required this.nameAr,
    required this.basePrice,
    required this.stockQuantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'nameAr': nameAr,
      'basePrice': basePrice,
      'stockQuantity': stockQuantity,
    };
  }
}

// UseCase class
class CreateProductUsecase extends UseCase<ProductModel, CreateProductParams> {
  final ProductRepository repository;

  CreateProductUsecase(this.repository);

  @override
  Future<Result<ProductModel>> call({required CreateProductParams params}) {
    return repository.createProductRequest(params: params);
  }
}
```

### 3. Repositories

**Location**: `features/{feature}/data/repository/`

**Pattern**:
```dart
import '../../../../../../core/data_source/remote_data_source.dart';
import '../../../../../../core/http/http_method.dart';
import '../../../../../../core/repository/core_repository.dart';
import '../../../../../../core/results/result.dart';
import '../model/product_model.dart';
import '../usecase/create_product_usecase.dart';
import '../usecase/get_my_products_usecase.dart';

// Define API URLs
const String createProductUrl = '/api/products';
const String getMyProductsUrl = '/api/products/my-products';
const String getProductByIdUrl = '/api/products/detail';

class ProductRepository extends CoreRepository {
  
  // CREATE - POST request
  Future<Result<ProductModel>> createProductRequest({
    required CreateProductParams params,
  }) async {
    final result = await RemoteDataSource.request<ProductModel>(
      withAuthentication: true,
      url: createProductUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => ProductModel.fromJson(json),
    );

    return call(result: result);
  }

  // READ LIST - GET with pagination
  Future<Result<List<ProductModel>>> getMyProductsRequest({
    required GetMyProductsParams params,
  }) async {
    final result = await RemoteDataSource.request<List<ProductModel>>(
      withAuthentication: true,
      url: getMyProductsUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? [];
        return data.map((item) => ProductModel.fromJson(item)).toList();
      },
    );

    return paginatedCall(result: result);
  }

  // READ SINGLE - GET by ID
  Future<Result<ProductModel>> getProductByIdRequest({
    required String productId,
  }) async {
    final url = '$getProductByIdUrl/$productId';

    final result = await RemoteDataSource.request<ProductModel>(
      withAuthentication: true,
      url: url,
      method: HttpMethod.GET,
      converter: (json) => ProductModel.fromJson(json),
    );

    return call(result: result);
  }

  // UPDATE - PUT request
  Future<Result<ProductModel>> updateProductRequest({
    required String productId,
    required UpdateProductParams params,
  }) async {
    final url = '/api/products/$productId';

    final result = await RemoteDataSource.request<ProductModel>(
      withAuthentication: true,
      url: url,
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => ProductModel.fromJson(json),
    );

    return call(result: result);
  }

  // DELETE - DELETE request
  Future<Result<String>> deleteProductRequest({
    required String productId,
  }) async {
    final url = '/api/products/$productId';

    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: url,
      method: HttpMethod.DELETE,
    );

    return noModelCall(result: result);
  }
}
```

---

## 🎛️ State Management

### Cubit Structure

**Location**: `features/{feature}/cubit/`

**Cubit File** (`product_cubit.dart`):

```dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/model/product_model.dart';
import '../data/repository/product_repository.dart';
import '../data/usecase/create_product_usecase.dart';
import '../data/usecase/get_my_products_usecase.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());

  final ProductRepository _repository = ProductRepository();

  // Params objects
  late CreateProductParams createProductParams = CreateProductParams(
    categoryId: '',
    name: '',
    nameAr: '',
    basePrice: 0.0,
    stockQuantity: 0,
  );

  // Local state
  List<ProductModel> products = [];
  ProductModel? selectedProduct;

  // CREATE
  Future<void> createProduct() async {
    emit(ProductLoading());

    final result = await CreateProductUsecase(_repository).call(
      params: createProductParams,
    );

    if (result.hasDataOnly) {
      emit(ProductCreated(product: result.data!));
    } else if (result.hasErrorOnly) {
      emit(ProductError(message: result.error ?? 'Failed to create product'));
    }
  }

  // READ LIST
  Future<void> getMyProducts() async {
    emit(ProductLoading());

    final params = GetMyProductsParams(skip: 0, take: 10);
    final result = await GetMyProductsUsecase(_repository).call(params: params);

    if (result.hasDataOnly) {
      products = result.data ?? [];
      emit(ProductsLoaded(products: products));
    } else if (result.hasErrorOnly) {
      emit(ProductError(message: result.error ?? 'Failed to load products'));
    }
  }

  // UPDATE
  Future<void> updateProduct(String productId) async {
    emit(ProductLoading());

    final params = UpdateProductParams(
      name: createProductParams.name,
      nameAr: createProductParams.nameAr,
      basePrice: createProductParams.basePrice,
    );

    final result = await UpdateProductUsecase(_repository).call(
      params: params,
      productId: productId,
    );

    if (result.hasDataOnly) {
      emit(ProductUpdated(product: result.data!));
    } else {
      emit(ProductError(message: result.error ?? 'Failed to update product'));
    }
  }

  // Helper methods
  void selectProduct(ProductModel product) {
    selectedProduct = product;
    emit(ProductSelected(product: product));
  }

  void resetState() {
    emit(ProductInitial());
  }
}
```

**State File** (`product_state.dart`):

```dart
part of 'product_cubit.dart';

@immutable
abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductCreated extends ProductState {
  final ProductModel product;
  ProductCreated({required this.product});
}

class ProductsLoaded extends ProductState {
  final List<ProductModel> products;
  ProductsLoaded({required this.products});
}

class ProductUpdated extends ProductState {
  final ProductModel product;
  ProductUpdated({required this.product});
}

class ProductSelected extends ProductState {
  final ProductModel product;
  ProductSelected({required this.product});
}

class ProductError extends ProductState {
  final String message;
  ProductError({required this.message});
}
```

### Pagination Cubit

For list screens with pagination, use the generic `PaginationCubit`:

```dart
import 'package:noon_express/core/boilerplate/pagination/cubits/pagination_cubit.dart';

// In your cubit
PaginationCubit<ProductModel>? paginationCubit;

void initializePagination() {
  paginationCubit = PaginationCubit<ProductModel>(
    (data) {
      final params = GetMyProductsParams(
        skip: data.skip,
        take: data.take,
      );
      return GetMyProductsUsecase(_repository).call(params: params);
    },
  );
}

// Call in screen
await cubit.paginationCubit?.getList(); // Initial load
await cubit.paginationCubit?.getList(loadMore: true); // Load more
```

---

## 🎨 UI Layer

### Screen Structure

**Location**: `features/{feature}/screen/`

**Pattern**:

```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constant/app_design_system.dart';
import '../../../../../core/ui/widgets/modern/modern_components.dart';
import '../cubit/product_cubit.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(
        title: 'add_new_product'.tr(),
        subtitle: 'fill_details'.tr(),
      ),
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('product_created_successfully'.tr()),
                backgroundColor: AppDesignSystem.successColor,
              ),
            );
            Navigator.pop(context);
          } else if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppDesignSystem.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<ProductCubit>();

          if (state is ProductLoading) {
            return const Center(child: AppLoading());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppDesignSystem.spacingSM.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Form sections
                        AppFormSection(
                          title: 'basic_information'.tr(),
                          children: [
                            AppTextField(
                              label: 'product_name_en'.tr(),
                              hint: 'enter_product_name'.tr(),
                              isRequired: true,
                              onChanged: (value) {
                                cubit.createProductParams.name = value;
                              },
                            ),
                            SizedBox(height: AppDesignSystem.spacingXS.h),
                            AppTextField(
                              label: 'product_name_ar'.tr(),
                              hint: 'enter_product_name_ar'.tr(),
                              isRequired: true,
                              onChanged: (value) {
                                cubit.createProductParams.nameAr = value;
                              },
                            ),
                          ],
                        ),
                        
                        SizedBox(height: AppDesignSystem.spacingSM.h),

                        // Pricing section
                        AppFormSection(
                          title: 'pricing'.tr(),
                          children: [
                            AppTextField(
                              label: 'base_price'.tr(),
                              hint: '0.00',
                              keyboardType: TextInputType.number,
                              isRequired: true,
                              onChanged: (value) {
                                cubit.createProductParams.basePrice = 
                                  double.tryParse(value) ?? 0.0;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom button
              Container(
                padding: EdgeInsets.all(AppDesignSystem.spacingSM.w),
                decoration: BoxDecoration(
                  color: AppDesignSystem.surfaceWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: AppButton(
                  text: 'create_product'.tr(),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await cubit.createProduct();
                    }
                  },
                  isLoading: state is ProductLoading,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### List Screen with Pagination

```dart
class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProductCubit>();
    
    // Initialize pagination
    cubit.initializePagination();
    cubit.paginationCubit?.getList();

    // Setup infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final paginationState = cubit.paginationCubit?.state;
        if (paginationState is GetListSuccessfully && 
            !paginationState.noMoreData) {
          cubit.paginationCubit?.getList(loadMore: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductCubit>();

    return Scaffold(
      appBar: AppTopBar(title: 'my_products'.tr()),
      body: BlocBuilder<PaginationCubit<ProductModel>, PaginationState>(
        bloc: cubit.paginationCubit,
        builder: (context, state) {
          if (state is Loading) {
            return const Center(child: AppLoading());
          }

          if (state is GetListSuccessfully<ProductModel>) {
            final products = state.list;

            if (products.isEmpty) {
              return AppEmptyState(
                title: 'no_products'.tr(),
                message: 'no_products_message'.tr(),
                icon: Icons.inventory_2_outlined,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await cubit.paginationCubit?.getList();
              },
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.all(AppDesignSystem.spacingSM.w),
                itemCount: products.length + (state.noMoreData ? 0 : 1),
                separatorBuilder: (context, index) => 
                  SizedBox(height: AppDesignSystem.spacingXS.h),
                itemBuilder: (context, index) {
                  if (index == products.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final product = products[index];
                  return ProductCard(product: product);
                },
              ),
            );
          }

          if (state is Error) {
            return Center(
              child: Text(
                state.message,
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: AppDesignSystem.errorColor,
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const CreateProductScreen(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text('add_product'.tr()),
      ),
    );
  }
}
```

---

## 🧩 Core Components

### Modern UI Components

**Location**: `lib/core/ui/widgets/modern/`

All screens should use these consistent components:

#### 1. AppTopBar
```dart
AppTopBar(
  title: 'Screen Title'.tr(),
  subtitle: 'Optional subtitle'.tr(),
  leading: IconButton(...), // Optional custom back button
)
```

#### 2. AppButton
```dart
AppButton(
  text: 'Submit'.tr(),
  onPressed: () {},
  isLoading: state is Loading,
  variant: ButtonVariant.primary, // primary, secondary, text
  size: ButtonSize.large, // small, medium, large
)
```

#### 3. AppTextField
```dart
AppTextField(
  label: 'Email Address'.tr(),
  hint: 'Enter your email'.tr(),
  isRequired: true,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr();
    }
    return null;
  },
  onChanged: (value) {
    // Handle change
  },
)
```

#### 4. AppFormSection
```dart
AppFormSection(
  title: 'Personal Information'.tr(),
  children: [
    AppTextField(...),
    SizedBox(height: AppDesignSystem.spacingXS.h),
    AppTextField(...),
  ],
)
```

#### 5. AppCard
```dart
AppCard(
  child: Column(
    children: [
      Text('Card content'),
    ],
  ),
)
```

#### 6. AppBadge
```dart
AppBadge(
  label: 'Active',
  type: BadgeType.success, // success, error, warning, info, neutral
)
```

#### 7. AppEmptyState
```dart
AppEmptyState(
  title: 'No Data'.tr(),
  message: 'No items found'.tr(),
  icon: Icons.inbox_outlined,
)
```

#### 8. AppLoading
```dart
const AppLoading() // Centered loading indicator
```

### Navigation

Navigation uses `Keys.navigatorKey` for global access:

```dart
// Import
import 'package:noon_express/core/classes/keys.dart';

// Push
Keys.navigatorKey.currentState?.push(
  MaterialPageRoute(builder: (_) => NewScreen()),
);

// Push with BLoC
Keys.navigatorKey.currentState?.push(
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: context.read<ProductCubit>(),
      child: const ProductDetailsScreen(),
    ),
  ),
);

// Pop
Keys.navigatorKey.currentState?.pop();

// Pop with result
Keys.navigatorKey.currentState?.pop(result);
```

---

## 🎨 Design System

### AppDesignSystem

**Location**: `lib/core/constant/app_design_system.dart`

#### Colors

```dart
// Primary
AppDesignSystem.primaryColor       // #0F766E - Main brand color
AppDesignSystem.primaryLight       // #14B8A6
AppDesignSystem.primaryDark        // #0D5B52
AppDesignSystem.primarySurface     // #CCFBF1

// Accent
AppDesignSystem.accentColor        // #F97316 - CTAs
AppDesignSystem.accentLight        // #FB923C
AppDesignSystem.accentDark         // #EA580C

// Neutrals
AppDesignSystem.neutral50 to neutral900

// Status
AppDesignSystem.successColor       // #10B981
AppDesignSystem.errorColor         // #EF4444
AppDesignSystem.warningColor       // #F59E0B
AppDesignSystem.infoColor          // #3B82F6

// Surfaces
AppDesignSystem.surfaceWhite
AppDesignSystem.surfaceLight
AppDesignSystem.surfaceCard
```

#### Typography

```dart
// Text Styles
AppDesignSystem.h1               // 32sp, bold
AppDesignSystem.h2               // 28sp, bold
AppDesignSystem.h3               // 24sp, semiBold
AppDesignSystem.h4               // 20sp, semiBold
AppDesignSystem.h5               // 18sp, semiBold
AppDesignSystem.h6               // 16sp, semiBold

AppDesignSystem.bodyLarge        // 16sp, regular
AppDesignSystem.bodyMedium       // 14sp, regular
AppDesignSystem.bodySmall        // 12sp, regular

AppDesignSystem.labelLarge       // 16sp, medium
AppDesignSystem.labelMedium      // 14sp, medium
AppDesignSystem.labelSmall       // 12sp, medium
```

#### Spacing

```dart
AppDesignSystem.spacingXXS       // 4
AppDesignSystem.spacingXS        // 8
AppDesignSystem.spacingSM        // 12
AppDesignSystem.spacingMD        // 16
AppDesignSystem.spacingLG        // 20
AppDesignSystem.spacingXL        // 24
AppDesignSystem.spacing2XL       // 32
AppDesignSystem.spacing3XL       // 40

// Usage with ScreenUtil
SizedBox(height: AppDesignSystem.spacingSM.h)
EdgeInsets.all(AppDesignSystem.spacingMD.w)
```

#### Border Radius

```dart
AppDesignSystem.radiusXS         // 4
AppDesignSystem.radiusSM         // 8
AppDesignSystem.radiusMD         // 12
AppDesignSystem.radiusLG         // 16
AppDesignSystem.radiusXL         // 20
AppDesignSystem.radius2XL        // 24

// Usage
BorderRadius.circular(AppDesignSystem.radiusMD.r)
```

---

## 🌐 API Integration

### RemoteDataSource

All API calls go through `RemoteDataSource.request()`:

**Location**: `lib/core/data_source/remote_data_source.dart`

#### Headers Automatically Added:
- `Content-Type`: application/json
- `Accept-Language`: ar or en (from CacheHelper)
- `JasimTenant`: Tenant name (from CacheHelper)
- `Authorization`: Bearer {token} (if `withAuthentication: true`)

#### Request Types:

**1. Simple Request (Single Model)**
```dart
final result = await RemoteDataSource.request<ProductModel>(
  withAuthentication: true,
  url: '/api/products',
  method: HttpMethod.POST,
  data: params.toJson(),
  converter: (json) => ProductModel.fromJson(json),
);
```

**2. List Request**
```dart
final result = await RemoteDataSource.request<List<ProductModel>>(
  withAuthentication: true,
  url: '/api/products',
  method: HttpMethod.GET,
  queryParameters: {'skip': 0, 'take': 10},
  converter: (json) {
    final List<dynamic> items = json['items'] ?? [];
    return items.map((item) => ProductModel.fromJson(item)).toList();
  },
);
```

**3. File Upload**
```dart
final result = await RemoteDataSource.request<MediaModel>(
  withAuthentication: true,
  url: '/api/media/upload',
  method: HttpMethod.POST,
  file: imageFile,
  fileKey: 'file',
  converter: (json) => MediaModel.fromJson(json),
);
```

**4. Multiple Files Upload**
```dart
final result = await RemoteDataSource.request<List<MediaModel>>(
  withAuthentication: true,
  url: '/api/media/upload-many',
  method: HttpMethod.POST,
  files: imageFiles,
  converter2: (json) {
    return (json as List).map((item) => MediaModel.fromJson(item)).toList();
  },
);
```

**5. No Model Request (DELETE, etc.)**
```dart
final result = await RemoteDataSource.noModelRequest(
  withAuthentication: true,
  url: '/api/products/$productId',
  method: HttpMethod.DELETE,
);
```

### API URLs

**Location**: `lib/core/constant/end_points/api_url.dart`

```dart
const baseUrl = 'https://api.demo.bakeet.shop/';

// Define endpoints as constants
const String createProductUrl = '${baseUrl}api/products';
const String getMyProductsUrl = '${baseUrl}api/products/my-products';

// Dynamic URLs
String getProductByIdUrl(String id) => '${baseUrl}api/products/$id';
```

---

## 🔐 Authentication & Storage

### CacheHelper

**Location**: `lib/core/classes/cashe_helper.dart`

Uses **Hive** for local storage.

#### Common Usage:

```dart
// Token management
String? token = CacheHelper.token;
await CacheHelper.setToken(newToken);

// User data
String? userId = CacheHelper.userId;
await CacheHelper.setUserId(userId);

// Language
String lang = CacheHelper.lang; // 'ar' or 'en'
await CacheHelper.setLang('ar');

// Tenant
String tenant = CacheHelper.tenant;
await CacheHelper.setTenant('JasimTenant');

// Custom values
String? value = CacheHelper.box.get('key');
await CacheHelper.box.put('key', 'value');
```

### Token Management

Token validation is automatic via `checkToken()` in RemoteDataSource:

**Location**: `lib/core/utils/functions/token_validator.dart`

---

## 🌍 Localization

### EasyLocalization Setup

**Main.dart**:
```dart
EasyLocalization(
  supportedLocales: const [Locale('ar'), Locale('en')],
  path: 'assets/translations',
  fallbackLocale: const Locale('ar'),
  startLocale: const Locale('ar'),
  child: const MyApp(),
)
```

### Translation Files

**Location**: `assets/translations/`
- `ar.json`
- `en.json`

**Usage**:
```dart
import 'package:easy_localization/easy_localization.dart';

Text('product_name'.tr())
Text('hello_user'.tr(args: ['Ahmed']))
Text('items_count'.plural(count))
```

---

## 📦 Dependency Injection

### GetIt Setup

**Location**: `lib/core/di/injection.dart`

```dart
final getIt = GetIt.instance;

Future<void> setUp() async {
  // Register Cubits
  getIt.registerLazySingleton(() => AuthCubit());
  getIt.registerLazySingleton(() => ProductCubit());
  getIt.registerLazySingleton(() => OrderCubit(getIt<AuthCubit>()));
  
  // Repositories can be registered if needed
  // getIt.registerLazySingleton(() => ProductRepository());
}
```

### Usage in main.dart

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => getIt<AuthCubit>()),
    BlocProvider(create: (context) => getIt<ProductCubit>()),
    BlocProvider(create: (context) => getIt<OrderCubit>()),
  ],
  child: MaterialApp(...),
)
```

---

## 🚀 Step-by-Step: Creating New Features

### Example: Create "Reviews" Feature

#### Step 1: Create Folder Structure

```
lib/features/Express/user/reviews/
├── cubit/
│   ├── review_cubit.dart
│   └── review_state.dart
├── data/
│   ├── model/
│   │   └── review_model.dart
│   ├── repository/
│   │   └── review_repository.dart
│   └── usecase/
│       ├── create_review_usecase.dart
│       ├── get_reviews_usecase.dart
│       └── delete_review_usecase.dart
└── screen/
    ├── reviews_list_screen.dart
    └── create_review_screen.dart
```

#### Step 2: Create Model

`review_model.dart`:
```dart
class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      userId: json['userId'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
```

#### Step 3: Create Use Cases

`create_review_usecase.dart`:
```dart
import '../../../../../../core/params/base_params.dart';
import '../../../../../../core/results/result.dart';
import '../../../../../../core/usecase/usecase.dart';
import '../model/review_model.dart';
import '../repository/review_repository.dart';

class CreateReviewParams extends BaseParams {
  final String productId;
  final int rating;
  final String comment;

  CreateReviewParams({
    required this.productId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'rating': rating,
      'comment': comment,
    };
  }
}

class CreateReviewUsecase extends UseCase<ReviewModel, CreateReviewParams> {
  final ReviewRepository repository;

  CreateReviewUsecase(this.repository);

  @override
  Future<Result<ReviewModel>> call({required CreateReviewParams params}) {
    return repository.createReviewRequest(params: params);
  }
}
```

`get_reviews_usecase.dart`:
```dart
import '../../../../../../core/params/base_params.dart';
import '../../../../../../core/results/result.dart';
import '../../../../../../core/usecase/usecase.dart';
import '../model/review_model.dart';
import '../repository/review_repository.dart';

class GetReviewsParams extends BaseParams {
  final String productId;
  final int skip;
  final int take;

  GetReviewsParams({
    required this.productId,
    this.skip = 0,
    this.take = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'skip': skip,
      'take': take,
    };
  }
}

class GetReviewsUsecase extends UseCase<List<ReviewModel>, GetReviewsParams> {
  final ReviewRepository repository;

  GetReviewsUsecase(this.repository);

  @override
  Future<Result<List<ReviewModel>>> call({required GetReviewsParams params}) {
    return repository.getReviewsRequest(params: params);
  }
}
```

#### Step 4: Create Repository

`review_repository.dart`:
```dart
import '../../../../../../core/data_source/remote_data_source.dart';
import '../../../../../../core/http/http_method.dart';
import '../../../../../../core/repository/core_repository.dart';
import '../../../../../../core/results/result.dart';
import '../model/review_model.dart';
import '../usecase/create_review_usecase.dart';
import '../usecase/get_reviews_usecase.dart';

const String createReviewUrl = '/api/reviews';
const String getReviewsUrl = '/api/reviews';

class ReviewRepository extends CoreRepository {
  
  Future<Result<ReviewModel>> createReviewRequest({
    required CreateReviewParams params,
  }) async {
    final result = await RemoteDataSource.request<ReviewModel>(
      withAuthentication: true,
      url: createReviewUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => ReviewModel.fromJson(json),
    );

    return call(result: result);
  }

  Future<Result<List<ReviewModel>>> getReviewsRequest({
    required GetReviewsParams params,
  }) async {
    final result = await RemoteDataSource.request<List<ReviewModel>>(
      withAuthentication: true,
      url: getReviewsUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? [];
        return data.map((item) => ReviewModel.fromJson(item)).toList();
      },
    );

    return paginatedCall(result: result);
  }

  Future<Result<String>> deleteReviewRequest({
    required String reviewId,
  }) async {
    final url = '$createReviewUrl/$reviewId';

    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: url,
      method: HttpMethod.DELETE,
    );

    return noModelCall(result: result);
  }
}
```

#### Step 5: Create Cubit & State

`review_state.dart`:
```dart
part of 'review_cubit.dart';

@immutable
abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewCreated extends ReviewState {
  final ReviewModel review;
  ReviewCreated({required this.review});
}

class ReviewsLoaded extends ReviewState {
  final List<ReviewModel> reviews;
  ReviewsLoaded({required this.reviews});
}

class ReviewDeleted extends ReviewState {}

class ReviewError extends ReviewState {
  final String message;
  ReviewError({required this.message});
}
```

`review_cubit.dart`:
```dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/model/review_model.dart';
import '../data/repository/review_repository.dart';
import '../data/usecase/create_review_usecase.dart';
import '../data/usecase/get_reviews_usecase.dart';

part 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit() : super(ReviewInitial());

  final ReviewRepository _repository = ReviewRepository();

  late CreateReviewParams createReviewParams = CreateReviewParams(
    productId: '',
    rating: 5,
    comment: '',
  );

  List<ReviewModel> reviews = [];

  Future<void> createReview() async {
    emit(ReviewLoading());

    final result = await CreateReviewUsecase(_repository).call(
      params: createReviewParams,
    );

    if (result.hasDataOnly) {
      emit(ReviewCreated(review: result.data!));
    } else if (result.hasErrorOnly) {
      emit(ReviewError(message: result.error ?? 'Failed to create review'));
    }
  }

  Future<void> getReviews(String productId) async {
    emit(ReviewLoading());

    final params = GetReviewsParams(productId: productId);
    final result = await GetReviewsUsecase(_repository).call(params: params);

    if (result.hasDataOnly) {
      reviews = result.data ?? [];
      emit(ReviewsLoaded(reviews: reviews));
    } else if (result.hasErrorOnly) {
      emit(ReviewError(message: result.error ?? 'Failed to load reviews'));
    }
  }

  Future<void> deleteReview(String reviewId) async {
    emit(ReviewLoading());

    final result = await _repository.deleteReviewRequest(reviewId: reviewId);

    if (result.hasDataOnly) {
      reviews.removeWhere((r) => r.id == reviewId);
      emit(ReviewDeleted());
      emit(ReviewsLoaded(reviews: reviews));
    } else {
      emit(ReviewError(message: result.error ?? 'Failed to delete review'));
    }
  }
}
```

#### Step 6: Create Screens

`create_review_screen.dart`:
```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constant/app_design_system.dart';
import '../../../../../core/ui/widgets/modern/modern_components.dart';
import '../cubit/review_cubit.dart';

class CreateReviewScreen extends StatefulWidget {
  final String productId;

  const CreateReviewScreen({
    super.key,
    required this.productId,
  });

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(
        title: 'write_review'.tr(),
      ),
      body: BlocConsumer<ReviewCubit, ReviewState>(
        listener: (context, state) {
          if (state is ReviewCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('review_submitted'.tr()),
                backgroundColor: AppDesignSystem.successColor,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppDesignSystem.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<ReviewCubit>();
          cubit.createReviewParams.productId = widget.productId;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppDesignSystem.spacingSM.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'your_rating'.tr(),
                          style: AppDesignSystem.labelMedium,
                        ),
                        SizedBox(height: AppDesignSystem.spacingXS.h),
                        Row(
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < _rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppDesignSystem.warningColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _rating = index + 1;
                                  cubit.createReviewParams.rating = _rating;
                                });
                              },
                            );
                          }),
                        ),
                        SizedBox(height: AppDesignSystem.spacingSM.h),
                        AppTextField(
                          label: 'your_review'.tr(),
                          hint: 'write_your_thoughts'.tr(),
                          maxLines: 5,
                          isRequired: true,
                          onChanged: (value) {
                            cubit.createReviewParams.comment = value;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(AppDesignSystem.spacingSM.w),
                decoration: BoxDecoration(
                  color: AppDesignSystem.surfaceWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: AppButton(
                  text: 'submit_review'.tr(),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await cubit.createReview();
                    }
                  },
                  isLoading: state is ReviewLoading,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

`reviews_list_screen.dart`:
```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constant/app_design_system.dart';
import '../../../../../core/ui/widgets/modern/modern_components.dart';
import '../cubit/review_cubit.dart';
import 'create_review_screen.dart';

class ReviewsListScreen extends StatefulWidget {
  final String productId;

  const ReviewsListScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewCubit>().getReviews(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(
        title: 'reviews'.tr(),
      ),
      body: BlocBuilder<ReviewCubit, ReviewState>(
        builder: (context, state) {
          if (state is ReviewLoading) {
            return const Center(child: AppLoading());
          }

          if (state is ReviewsLoaded) {
            final reviews = state.reviews;

            if (reviews.isEmpty) {
              return AppEmptyState(
                title: 'no_reviews'.tr(),
                message: 'be_first_to_review'.tr(),
                icon: Icons.rate_review_outlined,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<ReviewCubit>().getReviews(widget.productId);
              },
              child: ListView.separated(
                padding: EdgeInsets.all(AppDesignSystem.spacingSM.w),
                itemCount: reviews.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: AppDesignSystem.spacingXS.h),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < review.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppDesignSystem.warningColor,
                                size: 16.sp,
                              );
                            }),
                            const Spacer(),
                            Text(
                              DateFormat('MMM dd, yyyy').format(review.createdAt),
                              style: AppDesignSystem.bodySmall.copyWith(
                                color: AppDesignSystem.neutral500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDesignSystem.spacingXS.h),
                        Text(
                          review.comment,
                          style: AppDesignSystem.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          if (state is ReviewError) {
            return Center(
              child: Text(
                state.message,
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: AppDesignSystem.errorColor,
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ReviewCubit>(),
                child: CreateReviewScreen(productId: widget.productId),
              ),
            ),
          );

          if (result == true && mounted) {
            context.read<ReviewCubit>().getReviews(widget.productId);
          }
        },
        icon: const Icon(Icons.add),
        label: Text('write_review'.tr()),
      ),
    );
  }
}
```

#### Step 7: Register in Dependency Injection

`lib/core/di/injection.dart`:
```dart
import 'package:noon_express/features/Express/user/reviews/cubit/review_cubit.dart';

Future<void> setUp() async {
  // ... existing registrations
  getIt.registerLazySingleton(() => ReviewCubit());
}
```

#### Step 8: Add to BlocProviders in main.dart

`main.dart`:
```dart
MultiBlocProvider(
  providers: [
    // ... existing providers
    BlocProvider(create: (context) => getIt<ReviewCubit>()),
  ],
  child: ...,
)
```

#### Step 9: Add Translations

`assets/translations/en.json`:
```json
{
  "reviews": "Reviews",
  "write_review": "Write a Review",
  "your_rating": "Your Rating",
  "your_review": "Your Review",
  "write_your_thoughts": "Write your thoughts here...",
  "submit_review": "Submit Review",
  "review_submitted": "Review submitted successfully",
  "no_reviews": "No Reviews Yet",
  "be_first_to_review": "Be the first to review this product"
}
```

`assets/translations/ar.json`:
```json
{
  "reviews": "التقييمات",
  "write_review": "كتابة تقييم",
  "your_rating": "تقييمك",
  "your_review": "تقييمك",
  "write_your_thoughts": "اكتب أفكارك هنا...",
  "submit_review": "إرسال التقييم",
  "review_submitted": "تم إرسال التقييم بنجاح",
  "no_reviews": "لا توجد تقييمات",
  "be_first_to_review": "كن أول من يقيم هذا المنتج"
}
```

---

## ✅ Best Practices

### 1. **Always Use AppDesignSystem**
- Never hardcode colors, spacing, or text styles
- Use `.w`, `.h`, `.sp`, `.r` from ScreenUtil for responsive design

### 2. **Follow Clean Architecture**
- Keep business logic in Cubits
- Keep API calls in Repositories
- Keep single-purpose actions in UseCases
- Keep UI dumb (just display state)

### 3. **Error Handling**
- Always check `result.hasDataOnly` and `result.hasErrorOnly`
- Show user-friendly error messages using SnackBar
- Use `AppDesignSystem.errorColor` for error states

### 4. **State Management**
- Emit loading state before async operations
- Emit success/error states after operations
- Use BlocConsumer when you need both listener and builder
- Use BlocBuilder when you only need to rebuild UI
- Use BlocListener when you only need side effects

### 5. **Navigation**
- Use `Keys.navigatorKey.currentState?.push()` for navigation
- Pass BLoC with `BlocProvider.value()` when navigating
- Return results from screens using `Navigator.pop(context, result)`

### 6. **Localization**
- Always use `.tr()` for user-facing strings
- Keep translation keys in snake_case
- Add translations for both `en.json` and `ar.json`

### 7. **Forms**
- Use `Form` with `GlobalKey<FormState>`
- Validate with `.validate()` before submission
- Use AppTextField with proper validators

### 8. **Lists & Pagination**
- Use `PaginationCubit` for paginated lists
- Implement pull-to-refresh with `RefreshIndicator`
- Implement infinite scroll with `ScrollController`
- Show empty state with `AppEmptyState`

### 9. **Loading States**
- Show loading indicator during operations
- Disable buttons during loading
- Use `isLoading` parameter in `AppButton`

### 10. **Code Organization**
- Keep files small and focused
- Extract reusable widgets to separate files
- Group related functionality together
- Follow the existing folder structure exactly

### 11. **Naming Conventions**
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables: `camelCase`
- Constants: `camelCase` or `SCREAMING_SNAKE_CASE`
- Cubits: `{Feature}Cubit`
- States: `{Feature}State`
- Models: `{Feature}Model`
- Repositories: `{Feature}Repository`
- UseCases: `{Action}{Feature}Usecase`

### 12. **Comments & Documentation**
- Add comments for complex business logic
- Document public APIs
- Explain "why" not "what"

---

## 📝 Quick Reference Checklist

When creating a new feature, ensure:

- [ ] Folder structure follows pattern: `cubit/`, `data/`, `screen/`
- [ ] Model has `fromJson()`, `toJson()`, `copyWith()`
- [ ] Use cases extend `UseCase<T, Params>`
- [ ] Params extend `BaseParams`
- [ ] Repository extends `CoreRepository`
- [ ] Repository uses `RemoteDataSource.request()`
- [ ] Cubit extends `Cubit<State>` with proper states
- [ ] Screens use AppDesignSystem constants
- [ ] Screens use Modern UI components (AppButton, AppTextField, etc.)
- [ ] BlocConsumer/BlocBuilder used correctly
- [ ] Error handling implemented
- [ ] Loading states handled
- [ ] Translations added for EN and AR
- [ ] Cubit registered in GetIt DI
- [ ] BlocProvider added in main.dart
- [ ] Navigation uses Keys.navigatorKey
- [ ] Forms validated before submission
- [ ] Empty states handled
- [ ] Pull-to-refresh implemented for lists

---

## 🎯 Summary

This guide covers the complete architecture and patterns used in the JasimExpress mobile application. When implementing new features:

1. **Analyze existing features** with similar functionality
2. **Follow the established patterns** exactly
3. **Use the design system** consistently
4. **Test thoroughly** on both languages (AR/EN)
5. **Handle all states** (loading, success, error, empty)

By following this guide, you'll create features that seamlessly integrate with the existing codebase and maintain consistency across the application.

---

**Happy Coding! 🚀**
