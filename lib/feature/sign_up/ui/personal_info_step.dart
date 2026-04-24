import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_text_styles.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/login/ui/widgets/app_dropdown_field.dart';
import 'package:unilib/feature/login/ui/widgets/app_input_field.dart';
import 'package:unilib/feature/login/ui/widgets/primary_button.dart';
import 'package:unilib/feature/sign_up/logic/signup_controller.dart';
import 'package:unilib/feature/sign_up/ui/widget/year_chip_selector.dart';

class PersonalInfoStep extends StatelessWidget {
  const PersonalInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SignupController>();

    return Form(
      key: ctrl.formKeyStep0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Info', style: AppTextStyles.heading),
          SizedBox(height: 1.h),
          Text(
            'Tell us about yourself to get started',
            style: AppTextStyles.subheading,
          ),
          SizedBox(height: 3.h),

          // First & Last name
          Row(
            children: [
              Expanded(
                child: AppInputField(
                  label: 'First Name',
                  hint: 'Amr',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: ctrl.firstNameCtrl,
                  validator: ctrl.validateFirstName,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: AppInputField(
                  label: 'Last Name',
                  hint: 'Fadel',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: ctrl.lastNameCtrl,
                  validator: ctrl.validateLastName,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Student ID
          AppInputField(
            label: 'Student ID',
            hint: '1234567891234567',
            prefixIcon: Icons.badge_outlined,
            controller: ctrl.studentIdCtrl,
            validator: ctrl.validateStudentId,
          ),
          SizedBox(height: 2.h),

          // Faculty
          AppDropdownField<String>(
            label: 'Faculty / Department',
            hint: 'Select your faculty...',
            prefixIcon: Icons.school_outlined,
            value: ctrl.selectedFaculty,
            items: SignupController.faculties
                .map(
                  (f) => DropdownMenuItem(
                    value: f,
                    child: Text(
                      f,
                      style: AppTextStyles.inputText.copyWith(
                        color: AppColors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: ctrl.setFaculty,
            validator: ctrl.validateFaculty,
          ),
          SizedBox(height: 2.h),

          // Academic Year label
          Text('Academic Year', style: AppTextStyles.fieldLabel),
          SizedBox(height: 1.h),
          YearChipSelector(
            years: SignupController.academicYears,
            selected: ctrl.selectedYear,
            onSelected: ctrl.setYear,
          ),
          SizedBox(height: 4.h),

          PrimaryButton(
            label: 'Continue →',
            onPressed: () => ctrl.nextStep(),
            isLoading: false,
          ),
        ],
      ),
    );
  }
}
