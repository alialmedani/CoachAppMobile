import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';

/// Component showcase screen to demonstrate all modern UI components
/// This is a reference/example screen for developers
class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() =>
      _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  bool _checkboxValue = false;
  String? _radioValue = 'option1';
  String? _dropdownValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: const AppTopBar(
        title: 'Component Showcase',
        subtitle: 'Modern UI Components Demo',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Buttons', 'Different button variants and sizes', [
              // Primary buttons
              AppButton(
                text: 'Primary Large',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.large,
                fullWidth: true,
                onPressed: () {},
              ),
              SizedBox(height: AppDesignSystem.spacingXS.h),
              AppButton(
                text: 'Primary Medium',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.medium,
                fullWidth: true,
                onPressed: () {},
              ),
              SizedBox(height: AppDesignSystem.spacingXS.h),
              AppButton(
                text: 'Primary Small',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.small,
                onPressed: () {},
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),

              // With icons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'With Icon',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.add_rounded,
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(width: AppDesignSystem.spacingXS.w),
                  Expanded(
                    child: AppButton(
                      text: 'Icon Right',
                      variant: AppButtonVariant.outline,
                      icon: Icons.arrow_forward_rounded,
                      iconRight: true,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),

              // Loading and disabled
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Loading',
                      variant: AppButtonVariant.primary,
                      isLoading: true,
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(width: AppDesignSystem.spacingXS.w),
                  Expanded(
                    child: AppButton(
                      text: 'Disabled',
                      variant: AppButtonVariant.primary,
                      onPressed: null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),

              // All variants
              AppButton(
                text: 'Secondary',
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () {},
              ),
              SizedBox(height: AppDesignSystem.spacingXS.h),
              AppButton(
                text: 'Outline',
                variant: AppButtonVariant.outline,
                fullWidth: true,
                onPressed: () {},
              ),
              SizedBox(height: AppDesignSystem.spacingXS.h),
              AppButton(
                text: 'Ghost',
                variant: AppButtonVariant.ghost,
                fullWidth: true,
                onPressed: () {},
              ),
              SizedBox(height: AppDesignSystem.spacingXS.h),
              AppButton(
                text: 'Danger',
                variant: AppButtonVariant.danger,
                fullWidth: true,
                icon: Icons.delete_outline_rounded,
                onPressed: () {},
              ),
            ]),

            _buildSection('Badges', 'Status indicators and labels', [
              Wrap(
                spacing: AppDesignSystem.spacingXS.w,
                runSpacing: AppDesignSystem.spacingXS.h,
                children: [
                  const AppBadge(
                    text: 'Primary',
                    variant: AppBadgeVariant.primary,
                  ),
                  const AppBadge(
                    text: 'Success',
                    variant: AppBadgeVariant.success,
                  ),
                  const AppBadge(text: 'Error', variant: AppBadgeVariant.error),
                  const AppBadge(
                    text: 'Warning',
                    variant: AppBadgeVariant.warning,
                  ),
                  const AppBadge(text: 'Info', variant: AppBadgeVariant.info),
                  const AppBadge(
                    text: 'Neutral',
                    variant: AppBadgeVariant.neutral,
                  ),
                ],
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              Text('With Icons:', style: AppDesignSystem.labelMedium),
              SizedBox(height: AppDesignSystem.spacingXS.h),
              Wrap(
                spacing: AppDesignSystem.spacingXS.w,
                runSpacing: AppDesignSystem.spacingXS.h,
                children: const [
                  AppBadge(
                    text: 'Active',
                    variant: AppBadgeVariant.success,
                    icon: Icons.check_circle_rounded,
                  ),
                  AppBadge(
                    text: 'Pending',
                    variant: AppBadgeVariant.warning,
                    icon: Icons.schedule_rounded,
                  ),
                  AppBadge(
                    text: 'Failed',
                    variant: AppBadgeVariant.error,
                    icon: Icons.error_rounded,
                  ),
                ],
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              Text('With Dot:', style: AppDesignSystem.labelMedium),
              SizedBox(height: AppDesignSystem.spacingXS.h),
              Wrap(
                spacing: AppDesignSystem.spacingXS.w,
                runSpacing: AppDesignSystem.spacingXS.h,
                children: const [
                  AppBadge(
                    text: 'Online',
                    variant: AppBadgeVariant.success,
                    dot: true,
                  ),
                  AppBadge(
                    text: 'Away',
                    variant: AppBadgeVariant.warning,
                    dot: true,
                  ),
                  AppBadge(
                    text: 'Offline',
                    variant: AppBadgeVariant.neutral,
                    dot: true,
                  ),
                ],
              ),
            ]),

            _buildSection('Cards', 'Different card variants', [
              AppCard(
                variant: AppCardVariant.elevated,
                child: Column(
                  children: [
                    Text('Elevated Card', style: AppDesignSystem.h5),
                    SizedBox(height: AppDesignSystem.spacingXS.h),
                    Text(
                      'This card has a shadow for depth',
                      style: AppDesignSystem.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              AppCard(
                variant: AppCardVariant.outlined,
                child: Column(
                  children: [
                    Text('Outlined Card', style: AppDesignSystem.h5),
                    SizedBox(height: AppDesignSystem.spacingXS.h),
                    Text(
                      'This card has a border instead of shadow',
                      style: AppDesignSystem.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              AppCard(
                variant: AppCardVariant.elevated,
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Card tapped!')));
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: AppDesignSystem.primaryColor,
                    ),
                    SizedBox(width: AppDesignSystem.spacingSM.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tappable Card', style: AppDesignSystem.h5),
                          Text(
                            'This card has an onTap handler',
                            style: AppDesignSystem.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppDesignSystem.neutral400,
                    ),
                  ],
                ),
              ),
            ]),

            _buildSection('Text Fields', 'Form input fields', [
              const AppTextField(
                label: 'Product Name',
                hint: 'Enter product name',
                helperText: 'This field is required',
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              AppTextField(
                label: 'Price',
                hint: 'Enter price',
                keyboardType: TextInputType.number,
                prefixIcon: Icon(
                  Icons.attach_money_rounded,
                  size: AppDesignSystem.iconSizeSM.sp,
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              const AppTextField(
                label: 'Description',
                hint: 'Enter description',
                maxLines: 4,
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              const AppTextField(
                label: 'Error Example',
                hint: 'This has an error',
                errorText: 'This field is required',
              ),
            ]),

            _buildSection(
              'Form Components',
              'Checkboxes, radios, and dropdowns',
              [
                AppCheckboxField(
                  label: 'Featured Product',
                  subtitle: 'Show this product in featured section',
                  value: _checkboxValue,
                  onChanged: (value) {
                    setState(() {
                      _checkboxValue = value ?? false;
                    });
                  },
                ),
                SizedBox(height: AppDesignSystem.spacingMD.h),
                AppRadioField<String>(
                  label: 'Option 1',
                  subtitle: 'This is the first option',
                  value: 'option1',
                  groupValue: _radioValue,
                  onChanged: (value) {
                    setState(() {
                      _radioValue = value;
                    });
                  },
                ),
                SizedBox(height: AppDesignSystem.spacingXS.h),
                AppRadioField<String>(
                  label: 'Option 2',
                  subtitle: 'This is the second option',
                  value: 'option2',
                  groupValue: _radioValue,
                  onChanged: (value) {
                    setState(() {
                      _radioValue = value;
                    });
                  },
                ),
                SizedBox(height: AppDesignSystem.spacingMD.h),
                AppDropdownField<String>(
                  label: 'Category',
                  hint: 'Select a category',
                  value: _dropdownValue,
                  items: const [
                    DropdownMenuItem(
                      value: 'electronics',
                      child: Text('Electronics'),
                    ),
                    DropdownMenuItem(
                      value: 'clothing',
                      child: Text('Clothing'),
                    ),
                    DropdownMenuItem(value: 'food', child: Text('Food')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _dropdownValue = value;
                    });
                  },
                  prefixIcon: Icon(
                    Icons.category_rounded,
                    size: AppDesignSystem.iconSizeSM.sp,
                  ),
                ),
              ],
            ),

            _buildSection('Empty State', 'When there\'s no data to show', [
              SizedBox(
                height: 300.h,
                child: AppEmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'No products yet',
                  subtitle: 'Start adding products to your catalog',
                  iconColor: AppDesignSystem.primaryLight,
                  action: AppButton(
                    text: 'Add Product',
                    variant: AppButtonVariant.primary,
                    icon: Icons.add_rounded,
                    onPressed: () {},
                  ),
                ),
              ),
            ]),

            _buildSection('Loading States', 'Different loading indicators', [
              SizedBox(
                height: 150.h,
                child: const AppLoadingIndicator(
                  message: 'Loading products...',
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              SizedBox(
                height: 60.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        AppLoadingIndicator(
                          size: 24,
                          color: AppDesignSystem.primaryColor,
                        ),
                        SizedBox(height: AppDesignSystem.spacingXS.h),
                        Text('Primary', style: AppDesignSystem.bodySmall),
                      ],
                    ),
                    Column(
                      children: [
                        AppLoadingIndicator(
                          size: 24,
                          color: AppDesignSystem.accentColor,
                        ),
                        SizedBox(height: AppDesignSystem.spacingXS.h),
                        Text('Accent', style: AppDesignSystem.bodySmall),
                      ],
                    ),
                    Column(
                      children: [
                        AppLoadingIndicator(
                          size: 24,
                          color: AppDesignSystem.successColor,
                        ),
                        SizedBox(height: AppDesignSystem.spacingXS.h),
                        Text('Success', style: AppDesignSystem.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ]),

            _buildSection('Typography', 'Text styles demonstration', [
              Text('Heading 1', style: AppDesignSystem.h1),
              Text('Heading 2', style: AppDesignSystem.h2),
              Text('Heading 3', style: AppDesignSystem.h3),
              Text('Heading 4', style: AppDesignSystem.h4),
              Text('Heading 5', style: AppDesignSystem.h5),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              Text('Body Large', style: AppDesignSystem.bodyLarge),
              Text('Body Medium', style: AppDesignSystem.bodyMedium),
              Text('Body Small', style: AppDesignSystem.bodySmall),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              Text('Label Large', style: AppDesignSystem.labelLarge),
              Text('Label Medium', style: AppDesignSystem.labelMedium),
              Text('Label Small', style: AppDesignSystem.labelSmall),
            ]),

            _buildSection('Colors', 'Design system color palette', [
              Wrap(
                spacing: AppDesignSystem.spacingXS.w,
                runSpacing: AppDesignSystem.spacingXS.h,
                children: [
                  _buildColorSwatch('Primary', AppDesignSystem.primaryColor),
                  _buildColorSwatch(
                    'Primary Light',
                    AppDesignSystem.primaryLight,
                  ),
                  _buildColorSwatch('Accent', AppDesignSystem.accentColor),
                  _buildColorSwatch('Success', AppDesignSystem.successColor),
                  _buildColorSwatch('Error', AppDesignSystem.errorColor),
                  _buildColorSwatch('Warning', AppDesignSystem.warningColor),
                  _buildColorSwatch('Info', AppDesignSystem.infoColor),
                ],
              ),
            ]),

            SizedBox(height: AppDesignSystem.spacing4XL.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppDesignSystem.spacingXL.h),
        Text(title, style: AppDesignSystem.h3),
        SizedBox(height: AppDesignSystem.spacing2XS.h),
        Text(
          subtitle,
          style: AppDesignSystem.bodySmall.copyWith(
            color: AppDesignSystem.neutral500,
          ),
        ),
        SizedBox(height: AppDesignSystem.spacingMD.h),
        ...children,
      ],
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusSM.r),
            border: Border.all(color: AppDesignSystem.neutral200),
          ),
        ),
        SizedBox(height: AppDesignSystem.spacing2XS.h),
        SizedBox(
          width: 60.w,
          child: Text(
            name,
            style: AppDesignSystem.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
