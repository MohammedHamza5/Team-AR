import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_cubit.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_state.dart';
import 'package:team_ar/features/confirm_subscription/widget/confirm_subscription_form.dart';
import 'package:team_ar/core/widgets/plans_list_card.dart';
import 'package:team_ar/features/confirm_subscription/widget/register_bloc_listener.dart';
import '../../core/prefs/shared_pref_manager.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/app_local_keys.dart';
import '../plans_screen/model/user_plan.dart';

class ConfirmSubscriptionScreen extends StatefulWidget {
  const ConfirmSubscriptionScreen({super.key, required this.userPlan});

  final UserPlan userPlan;

  @override
  State<ConfirmSubscriptionScreen> createState() =>
      _ConfirmSubscriptionScreenState();
}

class _ConfirmSubscriptionScreenState extends State<ConfirmSubscriptionScreen> {
  bool isSendImages = false;

  @override
  void initState() {
    context.read<ConfirmSubscriptionCubit>().userPlan = widget.userPlan;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: const AppBarBackButton(),
        title: Text(
          AppLocalKeys.confirmSubscription.tr(),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontSize: 21.sp, color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlansListCard(
                isSelected: true,
                plan: widget.userPlan,
              ),
              SizedBox(
                height: 16.h,
              ),
              Text(
                AppLocalKeys.enterYourInfo.tr(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 18.sp,
                    ),
              ),
              SizedBox(
                height: 4.h,
              ),
              Text(
                AppLocalKeys.forSubscription.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.lightGrey,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              SizedBox(height: 21.h),
              const ConfirmSubscriptionForm(),
              SizedBox(
                height: 21.h,
              ),
              Row(
                children: [
                  Checkbox(
                    value: isSendImages,
                    onChanged: (value) {
                      isSendImages = value!;
                      context.read<ConfirmSubscriptionCubit>().isSendImages =
                          isSendImages;
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Expanded(
                    child: Text(
                      AppLocalKeys.sendBodyImages.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.lightGrey,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 21.h,
              ),
              BlocBuilder<ConfirmSubscriptionCubit, ConfirmSubscriptionState>(
                builder: (context, state) {
                  return Align(
                    alignment: AlignmentDirectional.center,
                    child: state is SubscriptionLoading
                        ? const CircularProgressIndicator()
                        : MaterialButton(
                            onPressed: () async {
                              final role =
                                  await SharedPreferencesHelper.getString(
                                      AppConstants.userRole);

                              if (role?.toLowerCase() != "admin") {
                                showComingSoonDialog(context);
                              }

                              if (context
                                      .read<ConfirmSubscriptionCubit>()
                                      .formKey
                                      .currentState!
                                      .validate() &&
                                  context
                                      .read<ConfirmSubscriptionCubit>()
                                      .isSendImages) {
                                context
                                    .read<ConfirmSubscriptionCubit>()
                                    .subscribe();
                              }
                            },
                            color: AppColors.newPrimaryColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 60.w, vertical: 4.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              AppLocalKeys.subscribe.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                      color: AppColors.white, fontSize: 18.sp),
                            )),
                  );
                },
              ),
              const RegisterBlocListener()
            ],
          ),
        ),
      ),
    );
  }
}

void showComingSoonDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Coming Soon'),
          ],
        ),
        content: const Text(
          'This feature will be enabled for users soon. Stay tuned!',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    },
  );
}
