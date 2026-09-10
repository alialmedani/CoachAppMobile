# API Integration Guide - Noon Express

This guide documents the architectural pattern for integrating API endpoints in the Noon Express application. Follow this structure when adding new API features.

## Architecture Overview

```
Screen (UI)
    ↓
Widget Wrapper (GetModel/CreateModel/PaginationList)
    ↓ useCaseCallBack
Cubit (State Management)
    ↓ method call (e.g., cubit.fetchData())
UseCase (Business Logic)
    ↓ call(params: params)
Repository (Data Layer)
    ↓ requestMethod(params: params)
RemoteDataSource (HTTP Client)
    ↓ request<T>(url, method, data, converter)
ApiProvider (Dio Client)
    ↓
API Response
    ↓
Result<T> (Success/Error)
    ↓
Cubit State (Loading/Success/Error)
    ↓
Widget Builder/Listener
```

---

## File Structure

For a feature called `{feature}` with entity `{Entity}`:

```
lib/features/{module}/{feature}/
├── cubit/
│   ├── {feature}_cubit.dart
│   └── {feature}_state.dart
├── data/
│   ├── model/
│   │   └── {entity}_model.dart
│   ├── repository/
│   │   └── {feature}_repository.dart
│   └── usecase/
│       ├── create_{entity}_usecase.dart
│       ├── get_{entity}_usecase.dart
│       ├── update_{entity}_usecase.dart
│       └── delete_{entity}_usecase.dart
└── screen/
    └── {feature}_screen.dart
```

---

## Step-by-Step Implementation

When given a CURL request, implement in this order:

### 1. Model Layer

**File**: `lib/features/{module}/{feature}/data/model/{entity}_model.dart`

```dart
class {Entity}Model {
  final String? id;
  final String? name;
  final String? description;
  final DateTime? createdAt;

  {Entity}Model({
    this.id,
    this.name,
    this.description,
    this.createdAt,
  });

  // From JSON - Parse API response
  factory {Entity}Model.fromJson(Map<String, dynamic> json) {
    return {Entity}Model(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  // To JSON - Send to API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
```

**Important Notes**:
- Use nullable fields (`String?`, `int?`) for optional API fields
- Handle date parsing with `DateTime.parse()`
- Use `toIso8601String()` when sending dates to API
- Match JSON keys exactly as they appear in the API response

---

### 2. Params Layer

**File**: `lib/features/{module}/{feature}/data/usecase/{operation}_{entity}_usecase.dart`

#### For GET requests (read operations):

```dart
import '../../../../../../core/params/base_params.dart';
import '../../../../../../core/boilerplate/pagination/models/get_list_request.dart';

class Get{Entity}Params extends BaseParams {
  final GetListRequest? request;  // For pagination
  final String? id;               // For getting single item
  final String? filterField;      // For filtering

  Get{Entity}Params({
    this.request,
    this.id,
    this.filterField,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    
    if (request != null) {
      map['SkipCount'] = request!.skip;  // Note: API uses SkipCount, not skip
      map['MaxResultCount'] = request!.take;  // Note: API uses MaxResultCount, not take
    }
    
    if (id != null) {
      map['Id'] = id;
    }
    
    if (filterField != null) {
      map['Filter'] = filterField;  // Most APIs use 'Filter' for search
    }
    
    return map;
  }
}
```

#### For POST/PUT requests (write operations):

```dart
import '../../../../../../core/params/base_params.dart';

class Create{Entity}Params extends BaseParams {
  String name;
  String description;
  int quantity;
  double price;
  bool isActive;

  Create{Entity}Params({
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'isActive': isActive,
    };
  } 
}
```

**Important**: 
- For params used in Cubit with `onChanged` callbacks, fields must be **non-final** (mutable).
- Import paths from `lib/features/Express/user/{feature}/data/usecase/` to `lib/core/` require **7 levels** of `../` (e.g., `../../../../../../core/`)
- GetListRequest uses fields `skip` and `take` (not `skipCount`/`maxResultCount`), but API expects `SkipCount` and `MaxResultCount`

---

## Prefer Cubit/State over setState

This guide emphasizes using the Cubit/Bloc state management pattern instead of directly calling `setState` in screens. Manage mutable UI state inside Cubits and expose changes via states; use `BlocBuilder` / `BlocListener` in widgets to react to those states. This keeps business logic and UI state separated and simplifies testing.

**IMPORTANT: Do NOT manually call `emit()` in your Cubit methods.** The boilerplate widgets (`CreateModel`, `GetModel`, `PaginationList`) automatically handle all state emissions (Loading, Success, Error states) based on the Result returned from your UseCase. Your Cubit methods should only return `Future<Result<T>>` - the widgets will manage the state lifecycle.

Guidelines:
- Update UI state from Cubit methods (e.g., `selectProvince()`, `toggleCOD()`), not `setState`.
- **DO NOT call `emit()` manually** - the boilerplate widgets handle all state emissions automatically.
- Your Cubit methods should return `Future<Result<T>>` - that's all the boilerplate needs.
- Use `BlocBuilder<Cubit, State>` only if you need custom state beyond what the boilerplate provides.
- Use callbacks (`onSuccess`/`onError` in CreateModel/GetModel) for side effects like navigation or snackbars.
- Keep form field `onChanged` handlers updating the Cubit's params directly (e.g., `context.read<MyCubit>().params.name = value`).

Example: replace this pattern using `setState`:

```dart
// Avoid in-screen state mutation
onTap: () {
  setState(() { _selectedPackageSize = 2; });
}
```

With Cubit (correct pattern):

```dart
// In Cubit - NO emit() needed, just update internal state
void selectPackageSize(int size) { 
  selectedPackageSize = size; 
  // NO emit() - boilerplate widgets handle state automatically
}

// In UI
InkWell(onTap: () => context.read<OrderCubit>().selectPackageSize(2));

// For API calls, return Future<Result> and let boilerplate handle states
Future<Result<OrderModel>> createOrder() async {
  return await CreateOrderUsecase(repository).call(params: createOrderParams);
  // NO emit() - CreateModel widget will emit Loading/Success/Error states
}
```

Rationale: The boilerplate widgets (`CreateModel`, `GetModel`, `PaginationList`) automatically manage Loading → Success/Error state transitions based on the `Future<Result<T>>` returned from your Cubit methods. Manual `emit()` calls are unnecessary and can cause state conflicts.


---

### 3. UseCase Layer

**File**: `lib/features/{module}/{feature}/data/usecase/{operation}_{entity}_usecase.dart`

#### Single Item UseCase:

```dart
import '../../../../../../core/results/result.dart';
import '../../../../../../core/usecase/usecase.dart';
import '../model/{entity}_model.dart';
import '../repository/{feature}_repository.dart';

class Create{Entity}Usecase extends UseCase<{Entity}Model, Create{Entity}Params> {
  final {Feature}Repository repository;

  Create{Entity}Usecase(this.repository);

  @override
  Future<Result<{Entity}Model>> call({
    required Create{Entity}Params params,
  }) {
    return repository.create{Entity}Request(params: params);
  }
}
```

#### List UseCase:

```dart
import '../../../../../../core/results/result.dart';
import '../../../../../../core/usecase/usecase.dart';
import '../model/{entity}_model.dart';
import '../repository/{feature}_repository.dart';

class Get{Entity}ListUsecase extends UseCase<List<{Entity}Model>, Get{Entity}Params> {
  final {Feature}Repository repository;

  Get{Entity}ListUsecase(this.repository);

  @override
  Future<Result<List<{Entity}Model>>> call({
    required Get{Entity}Params params,
  }) {
    return repository.get{Entity}ListRequest(params: params);
  }
}
```

---

### 4. Repository Layer

**File**: `lib/features/{module}/{feature}/data/repository/{feature}_repository.dart`

```dart
import '../../../../../../core/data_source/remote_data_source.dart';
import '../../../../../../core/http/http_method.dart';
import '../../../../../../core/repository/core_repository.dart';
import '../../../../../../core/results/result.dart';
import '../model/{entity}_model.dart';
import '../usecase/create_{entity}_usecase.dart';
import '../usecase/get_{entity}_usecase.dart';

// Define API URLs (usually at the top of the file or in a constants file)
const String create{Entity}Url = '/api/v1/{entities}';
const String get{Entity}ListUrl = '/api/v1/{entities}';
const String get{Entity}ByIdUrl = '/api/v1/{entities}'; // /{id} appended dynamically

class {Feature}Repository extends CoreRepository {

  // CREATE - POST request
  Future<Result<{Entity}Model>> create{Entity}Request({
    required Create{Entity}Params params,
  }) async {
    final result = await RemoteDataSource.request<{Entity}Model>(
      withAuthentication: true,  // Set to true if requires auth token
      url: create{Entity}Url,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => {Entity}Model.fromJson(json),
    );

    return call(result: result);
  }

  // READ LIST - GET request with pagination
  Future<Result<List<{Entity}Model>>> get{Entity}ListRequest({
    required Get{Entity}Params params,
  }) async {
    final result = await RemoteDataSource.request<List<{Entity}Model>>(
      withAuthentication: true,
      url: get{Entity}ListUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),  // Query params for GET
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data.map((item) => {Entity}Model.fromJson(item)).toList();
      },
    );

    return paginatedCall(result: result);  // Use paginatedCall for lists
  }

  // READ SINGLE - GET by ID
  Future<Result<{Entity}Model>> get{Entity}ByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<{Entity}Model>(
      withAuthentication: true,
      url: '$get{Entity}ByIdUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => {Entity}Model.fromJson(json),
    );

    return call(result: result);
  }

  // UPDATE - PUT/PATCH request
  Future<Result<{Entity}Model>> update{Entity}Request({
    required Update{Entity}Params params,
    required String id,
  }) async {
    final result = await RemoteDataSource.request<{Entity}Model>(
      withAuthentication: true,
      url: '$create{Entity}Url/$id',
      method: HttpMethod.PUT,  // or HttpMethod.PATCH
      data: params.toJson(),
      converter: (json) => {Entity}Model.fromJson(json),
    );

    return call(result: result);
  }

  // DELETE - DELETE request
  Future<Result<{Entity}Model>> delete{Entity}Request({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<{Entity}Model>(
      withAuthentication: true,
      url: '$create{Entity}Url/$id',
      method: HttpMethod.DELETE,
      converter: (json) => {Entity}Model.fromJson(json),
    );

    return call(result: result);
  }
}
```

**Important**:
- Use `call(result: result)` for single model responses
- Use `paginatedCall(result: result)` for list responses
- `data` parameter for POST/PUT/PATCH (request body)
- `queryParameters` parameter for GET requests (URL query params)
- `withAuthentication: true` adds Bearer token to headers
- HttpMethod enum values are **UPPERCASE**: `HttpMethod.GET`, `HttpMethod.POST`, `HttpMethod.PUT`, `HttpMethod.DELETE` (not lowercase)

---

### 5. Cubit Layer

**File**: `lib/features/{module}/{feature}/cubit/{feature}_cubit.dart`

```dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../core/results/result.dart';
import '../../../../../core/boilerplate/pagination/cubits/pagination_cubit.dart';
import '../data/repository/{feature}_repository.dart';
import '../data/usecase/create_{entity}_usecase.dart';
import '../data/usecase/get_{entity}_usecase.dart';

part '{feature}_state.dart';

class {Feature}Cubit extends Cubit<{Feature}State> {
  {Feature}Cubit() : super({Feature}Initial());

  // Pagination cubit instance (for lists)
  PaginationCubit? {entity}Pagination;

  // Params for create/update operations
  Create{Entity}Params create{Entity}Params = Create{Entity}Params(
    name: '',
    description: '',
    quantity: 0,
    price: 0.0,
    isActive: false,
  );

  // Create operation
  Future<Result> create{Entity}() async {
    return await Create{Entity}Usecase(
      {Feature}Repository(),
    ).call(params: create{Entity}Params);
  }

  // Get list operation
  Future<Result> fetch{Entity}List(data) async {
    return await Get{Entity}ListUsecase(
      {Feature}Repository(),
    ).call(params: Get{Entity}Params(request: data));
  }

  // Get single item
  Future<Result> fetch{Entity}ById(String id) async {
    return await Get{Entity}ByIdUsecase(
      {Feature}Repository(),
    ).call(params: Get{Entity}Params(id: id));
  }
}
```

**File**: `lib/features/{module}/{feature}/cubit/{feature}_state.dart`

```dart
part of '{feature}_cubit.dart';

@immutable
abstract class {Feature}State {}

class {Feature}Initial extends {Feature}State {}

class {Feature}Loading extends {Feature}State {}

class {Feature}Success extends {Feature}State {}

class {Feature}Error extends {Feature}State {
  final String message;
  {Feature}Error(this.message);
}
```

---

### 6. Screen Layer

#### Option A: CreateModel (for POST/PUT requests)

**File**: `lib/features/{module}/{feature}/screen/create_{entity}_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/boilerplate/create_model/widgets/create_model.dart';
import '../../../../../core/constant/app_colors/app_colors.dart';
import '../cubit/{feature}_cubit.dart';
import '../data/model/{entity}_model.dart';

class Create{Entity}Screen extends StatefulWidget {
  const Create{Entity}Screen({super.key});

  @override
  State<Create{Entity}Screen> createState() => _Create{Entity}ScreenState();
}

class _Create{Entity}ScreenState extends State<Create{Entity}Screen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for form fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isActive = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create {Entity}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter name',
              ),
              onChanged: (value) {
                context.read<{Feature}Cubit>().create{Entity}Params.name = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description',
              ),
              maxLines: 3,
              onChanged: (value) {
                context.read<{Feature}Cubit>().create{Entity}Params.description = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Quantity field
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter quantity',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                context.read<{Feature}Cubit>().create{Entity}Params.quantity =
                    int.tryParse(value) ?? 0;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Price field
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                hintText: 'Enter price',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                context.read<{Feature}Cubit>().create{Entity}Params.price =
                    double.tryParse(value) ?? 0.0;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter price';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Active checkbox (Cubit-based)
            BlocBuilder<{Feature}Cubit, {Feature}State>(
              builder: (context, state) {
                final cubit = context.read<{Feature}Cubit>();
                final isActive = cubit.create{Entity}Params.isActive;

                return CheckboxListTile(
                  title: const Text('Is Active'),
                  value: isActive,
                  onChanged: (bool? value) {
                    final newVal = value ?? false;
                    // Update params on the cubit and notify listeners via a cubit method
                    cubit.create{Entity}Params.isActive = newVal;
                    // Implement `setIsActive(bool)` in your cubit to emit a new state
                    // e.g. void setIsActive(bool v) { create{Entity}Params.isActive = v; emit({Feature}State()); }
                    if (cubit is dynamic) {
                      try {
                        cubit.setIsActive(newVal);
                      } catch (_) {}
                    }
                  },
                );
              },
            ),
            SizedBox(height: 24.h),

            // Submit button
            CreateModel<{Entity}Model>(
              withValidation: true,
              onTap: () async {
                return _formKey.currentState?.validate() ?? false;
              },
              useCaseCallBack: (data) {
                return context.read<{Feature}Cubit>().create{Entity}();
              },
              onSuccess: ({entity}) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('{Entity} created successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context, {entity});
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              },
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    'Create {Entity}',
                    
                    style: AppTextStyle.getSemiBoldStyle(
                      color: AppColors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**CreateModel Properties**:
- `useCaseCallBack`: Returns the cubit method that calls the UseCase
- `withValidation`: Set to `true` to enable validation
- `onTap`: Returns `Future<bool>` - form validation logic
- `onSuccess`: Callback when API call succeeds
- `onError`: Callback when API call fails
- `child`: The button widget to display

---

#### Option B: PaginationList (for GET list with pagination)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/boilerplate/pagination/widgets/pagination_list.dart';
import '../../../../../core/constant/app_colors/app_colors.dart';
import '../cubit/{feature}_cubit.dart';
import '../data/model/{entity}_model.dart';

class {Entity}ListScreen extends StatelessWidget {
  const {Entity}ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{Entity} List'),
      ),
      body: PaginationList<{Entity}Model>(
        withPagination: true,
        onCubitCreated: (cubit) {
          // Optional: Store reference to pagination cubit for manual refresh
          // _paginationCubit = cubit as PaginationCubit<{Entity}Model>;
        },
        repositoryCallBack: (data) {
          return context.read<{Feature}Cubit>().fetch{Entity}List(data);
        },
        listBuilder: (list) {
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final {entity} = list[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      {entity}.name?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                  title: Text(
                    {entity}.name ?? 'No name',
                    
                    style: AppTextStyle.getSemiBoldStyle(
                      color: Colors.grey[900]!,
                    ),
                  ),
                  subtitle: Text(
                    {entity}.description ?? 'No description',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.neutral400,
                  ),
                  onTap: () {
                    // Navigate to detail screen
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**PaginationList Properties**:
- `withPagination`: Set to `true` to enable pagination
- `repositoryCallBack`: Returns the cubit method that fetches data
- `listBuilder`: Builder function that receives the list and returns a widget

---

#### Option C: GetModel (for single item GET request)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/boilerplate/get_model/widgets/get_model.dart';
import '../../../../../core/constant/app_colors/app_colors.dart';
import '../cubit/{feature}_cubit.dart';
import '../data/model/{entity}_model.dart';

class {Entity}DetailScreen extends StatelessWidget {
  final String {entity}Id;

  const {Entity}DetailScreen({
    super.key,
    required this.{entity}Id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{Entity} Details'),
      ),
      body: GetModel<{Entity}Model>(
        useCaseCallBack: (data) {
          return context.read<{Feature}Cubit>().fetch{Entity}ById({entity}Id);
        },
        modelBuilder: ({entity}) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name',
                  
                  style: AppTextStyle.getSemiBoldStyle(
                    color: AppColors.neutral600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  {entity}.name ?? 'N/A',
                  
                  style: AppTextStyle.getSemiBoldStyle(
                    color: Colors.grey[900]!,
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  'Description',
                  style: AppTextStyle.getSemiBoldStyle(
                    color: AppColors.neutral600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  {entity}.description ?? 'N/A',
                  style: AppTextStyle.getSemiBoldStyle(
                    color: Colors.grey[900]!,
                  ),
                ),
                SizedBox(height: 16.h),

                // More fields...
              ],
            ),
          );
        },
      ),
    );
  }
}
```

**GetModel Properties**:
- `useCaseCallBack`: Returns the cubit method that fetches the single item
- `modelBuilder`: Builder function that receives the model and returns a widget

---

## CURL to Implementation Workflow

Given a CURL request like:

```bash
curl -X POST https://api.example.com/api/v1/products \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Product Name",
    "description": "Product Description",
    "price": 29.99,
    "quantity": 100,
    "categoryId": "cat-123",
    "isActive": true
  }'
```

### Implementation Steps:

1. **Identify the operation**: POST = Create
2. **Extract entity**: `products` → `Product`
3. **Extract fields from request body** → Model properties
4. **Create Model** (`product_model.dart`):
   ```dart
   class ProductModel {
     final String? id;
     final String? name;
     final String? description;
     final double? price;
     final int? quantity;
     final String? categoryId;
     final bool? isActive;

     ProductModel({...});

     factory ProductModel.fromJson(Map<String, dynamic> json) {...}
     Map<String, dynamic> toJson() {...}
   }
   ```

5. **Create Params** (`create_product_usecase.dart`):
   ```dart
   class CreateProductParams extends BaseParams {
     String name;
     String description;
     double price;
     int quantity;
     String categoryId;
     bool isActive;

     CreateProductParams({...});
     Map<String, dynamic> toJson() {...}
   }  
   ```

6. **Create UseCase** (`create_product_usecase.dart`):
   ```dart
   class CreateProductUsecase extends UseCase<ProductModel, CreateProductParams> {
     final ProductRepository repository;
     CreateProductUsecase(this.repository);

     @override
     Future<Result<ProductModel>> call({required CreateProductParams params}) {
       return repository.createProductRequest(params: params);
     }
   }
   ```

7. **Create Repository** (`product_repository.dart`):
   ```dart
   const String createProductUrl = '/api/v1/products';

   class ProductRepository extends CoreRepository {
     Future<Result<ProductModel>> createProductRequest({
       required CreateProductParams params,
     }) async {
       final result = await RemoteDataSource.request<ProductModel>(
         withAuthentication: true,  // Because CURL has Authorization header
         url: createProductUrl,
         method: HttpMethod.POST,
         data: params.toJson(),
         converter: (json) => ProductModel.fromJson(json),
       );
       return call(result: result);
     }
   }
   ```

8. **Update Cubit** (`product_cubit.dart`):
   ```dart
   class ProductCubit extends Cubit<ProductState> {
     CreateProductParams createProductParams = CreateProductParams(
       name: '',
       description: '',
       price: 0.0,
       quantity: 0,
       categoryId: '',
       isActive: false,
     );

     Future<Result> createProduct() async {
       return await CreateProductUsecase(ProductRepository())
           .call(params: createProductParams);
     }
   }
   ```

9. **Create Screen** (`create_product_screen.dart`):
   - Add TextFormFields for each param
   - Each field has `onChanged: (value) => context.read<ProductCubit>().createProductParams.{field} = value`
   - Submit button uses `CreateModel<ProductModel>` widget
   - `useCaseCallBack: (data) => context.read<ProductCubit>().createProduct()`

---

## Common Patterns

### HTTP Methods Mapping

| Operation | HTTP Method | Widget | Repository Method |
|-----------|-------------|---------|------------------|
| Create | POST | CreateModel | `call(result: result)` |
| Read (single) | GET | GetModel | `call(result: result)` |
| Read (list) | GET | PaginationList | `paginatedCall(result: result)` |
| Update | PUT/PATCH | CreateModel | `call(result: result)` |
| Delete | DELETE | CreateModel | `call(result: result)` |

### Request Body vs Query Parameters

```dart
// POST/PUT/PATCH - use `data` parameter
await RemoteDataSource.request<T>(
  url: url,
  method: HttpMethod.POST,
  data: params.toJson(),  // Request body
  converter: converter,
);

// GET - use `queryParameters` parameter
await RemoteDataSource.request<T>(
  url: url,
  method: HttpMethod.GET,  // Note: UPPERCASE
  queryParameters: params.toJson(),  // URL query params
  converter: converter,
);
```

### Authentication

```dart
// With authentication (adds Bearer token)
withAuthentication: true,

// Without authentication
withAuthentication: false,
```

### Response Converters

```dart
// Single model
converter: (json) => ProductModel.fromJson(json),

// List of models (when API returns array directly)
converter: (json) {
  final List<dynamic> data = json as List;
  return data.map((item) => ProductModel.fromJson(item)).toList();
},

// List of models (when API returns object with array inside)
converter: (json) {
  final List<dynamic> data = json['items'] ?? json['data'] ?? [];
  return data.map((item) => ProductModel.fromJson(item)).toList();
},
```

---

## Checklist for New API Integration

When implementing a new API endpoint, use this checklist:

- [ ] **Model**: Create `{entity}_model.dart` with `fromJson()` and `toJson()`
- [ ] **Params**: Create `{operation}_{entity}_usecase.dart` with params class
- [ ] **UseCase**: Add UseCase class extending `UseCase<T, Params>`
- [ ] **Repository**: Add method in `{feature}_repository.dart`
  - [ ] Define API URL constant
  - [ ] Use correct HTTP method
  - [ ] Use `data` for POST/PUT/PATCH or `queryParameters` for GET
  - [ ] Set `withAuthentication` correctly
  - [ ] Use correct converter (single model vs list)
  - [ ] Return `call()` for single item or `paginatedCall()` for lists
- [ ] **Cubit**: Add params field and method in `{feature}_cubit.dart`
- [ ] **Screen**: Create screen with appropriate widget
  - [ ] **CreateModel** for create/update/delete
  - [ ] **GetModel** for single item fetch
  - [ ] **PaginationList** for list with pagination
- [ ] **Text Fields**: Add `onChanged` callbacks to update cubit params
- [ ] **Validation**: Add form validation in `onTap` callback
- [ ] **Success/Error Handling**: Add callbacks for success and error cases

---

## Adding Search to PaginationList

When you need to add search functionality to a paginated list screen, follow this pattern:

### 1. Add Search Parameter to Params

In your `Get{Entity}Params` class:

```dart
class Get{Entity}Params extends BaseParams {
  final GetListRequest? request;
  final String? searchTerm;  // Add search parameter
  
  Get{Entity}Params({
    this.request,
    this.searchTerm,
  });

  Map<String, dynamic> toJson() {
    return {
      if (searchTerm != null && searchTerm!.isNotEmpty) 'SearchTerm': searchTerm,
      if (request != null) ...{
        'SkipCount': request!.skip,
        'MaxResultCount': request!.take,
      },
    };
  }
}
```

### 2. Add Search State Management to Cubit

```dart
class {Feature}Cubit extends Cubit<{Feature}State> {
  {Feature}Cubit() : super({Feature}Initial());

  // Search term field
  String searchTerm = '';

  // Method to update search term and emit state
  void setSearchTerm(String value) {
    searchTerm = value;
    emit({Feature}SearchChanged());  // Emit state to trigger UI rebuild
  }

  // Pass searchTerm to repository
  Future<Result> fetch{Entity}List(data) async {
    return await Get{Entity}ListUsecase(
      {Feature}Repository(),
    ).call(
      params: Get{Entity}Params(
        request: data,
        searchTerm: searchTerm.isNotEmpty ? searchTerm : null,
      ),
    );
  }
}
```

### 3. Add Search State Class

In `{feature}_state.dart`:

```dart
class {Feature}SearchChanged extends {Feature}State {}
```

### 4. Add Search UI with BlocBuilder

```dart
class {Entity}ListScreen extends StatefulWidget {
  const {Entity}ListScreen({super.key});

  @override
  State<{Entity}ListScreen> createState() => _{Entity}ListScreenState();
}

class _{Entity}ListScreenState extends State<{Entity}ListScreen> {
  final TextEditingController _searchController = TextEditingController();
  PaginationCubit? _paginationCubit;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final cubit = context.read<{Feature}Cubit>();
    cubit.setSearchTerm(value);  // Update cubit
    _paginationCubit?.getList();  // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('{Entity} List')),
      body: Column(
        children: [
          // Search Field wrapped in BlocBuilder
          BlocBuilder<{Feature}Cubit, {Feature}State>(
            builder: (context, state) {
              final cubit = context.read<{Feature}Cubit>();
              return Container(
                padding: EdgeInsets.all(16.w),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search_{Entity}'.tr(),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    // Clear button (shows when search has text)
                    suffixIcon: cubit.searchTerm.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              );
            },
          ),
          // PaginationList
          Expanded(
            child: PaginationList<{Entity}Model>(
              withPagination: true,
              withRefresh: true,
              onCubitCreated: (cubit) {
                _paginationCubit = cubit;  // Store reference for refresh
              },
              repositoryCallBack: (data) {
                return context.read<{Feature}Cubit>().fetch{Entity}List(data);
              },
              listBuilder: (list) {
                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildCard(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5. Add Translation Keys

In `en.json` and `ar.json`:

```json
"Search_{Entity}": "Search {entities}...",
```

### Key Points:

1. **Use `setSearchTerm()` method** - Don't assign `searchTerm` directly; use the method to emit state
2. **Wrap search field in BlocBuilder** - Rebuilds when `{Feature}SearchChanged` state is emitted
3. **Store `PaginationCubit` reference** - Use `onCubitCreated` callback to access `getList()` method
4. **Clear button visibility** - Controlled by `cubit.searchTerm.isNotEmpty`, not controller text
5. **Refresh on search** - Call `_paginationCubit?.getList()` to trigger new API call with search term
6. **Pass searchTerm to API** - Only include if not empty: `searchTerm.isNotEmpty ? searchTerm : null`

**Exception to "No emit()" Rule**: Search functionality is a special case where you **DO call `emit()`** manually in the `setSearchTerm()` method. This is because:
- Search is UI state that needs to trigger BlocBuilder rebuilds
- It's not an API call, so boilerplate widgets don't handle it
- You need to show/hide the clear button reactively

This pattern avoids `setState` and maintains clean separation of concerns.

---

## Example: Complete Feature (Order Management)

See reference implementations:
- **Model**: `lib/features/user/merchant address/data/model/address_model.dart`
- **Params**: `lib/features/user/merchant address/data/usecase/create_merchant_address_usecase.dart`
- **UseCase**: Same file as params
- **Repository**: `lib/features/user/merchant address/data/repository/merchant_address_repository.dart`
- **Cubit**: `lib/features/user/merchant address/cubit/merchant_address_cubit.dart`
- **Screen (CreateModel)**: `lib/features/user/merchant address/screen/create_address_screen.dart`
- **Screen (PaginationList)**: Lines 178-255 in `create_address_screen.dart` (region selector modal)
- **Search Implementation**: `lib/features/Express/user/home/screen/merchant_returns_screen.dart`

---

## Common Pitfalls & Solutions

### Import Path Issues
- **Problem**: `Target of URI doesn't exist` errors
- **Solution**: Count directory levels carefully. From `lib/features/Express/user/{feature}/data/` to `lib/core/` requires **7 levels** (`../../../../../../core/`)

### GetListRequest Field Names
- **Problem**: `GetListRequest` doesn't have `skipCount`/`maxResultCount`
- **Solution**: Use `request!.skip` and `request!.take`, but map to `SkipCount` and `MaxResultCount` in `toJson()`

### HttpMethod Enum
- **Problem**: `There's no constant named 'get'`
- **Solution**: Use UPPERCASE: `HttpMethod.GET`, `HttpMethod.POST`, `HttpMethod.PUT`, `HttpMethod.DELETE`

### AppColors
- **Problem**: `The getter 'grey' isn't defined for AppColors`
- **Solution**: Use specific color names: `AppColors.grey72`, `AppColors.greyA9`, `AppColors.black23`, etc. Check the AppColors class for available constants

### PaginationList Type Safety
- **Problem**: Type mismatch in `onCubitCreated` callback
- **Solution**: Cast the cubit: `_paginationCubit = cubit as PaginationCubit<{Entity}Model>;`

### ListView in PaginationList
- **Problem**: ListView not scrolling properly
- **Solution**: Return ListView directly in `listBuilder`, don't wrap with additional padding/separators at PaginationList level

## Notes

1. **Always read existing files first** before creating new ones
2. **Follow naming conventions** exactly as shown
3. **Fields in Params must be non-final** when used with cubit pattern
4. **Use `context.read<Cubit>()` in `onChanged` callbacks** to update params
5. **Validation happens in `onTap` callback**, not in `useCaseCallBack`
6. **Success/Error callbacks are optional** but recommended for user feedback
7. **Check HttpMethod enum values** - they are UPPERCASE
8. **Verify import paths** - count directory levels carefully

---

*Last Updated: 2025-01-29*
*Architecture Version: 1.0*
