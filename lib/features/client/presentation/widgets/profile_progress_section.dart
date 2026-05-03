import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/core/utils/session_storage.dart';
import 'package:quick_forms/core/utils/user_session.dart';
import 'package:quick_forms/features/auth/domain/bloc/user_bloc.dart';
import 'package:quick_forms/features/auth/domain/bloc/user_state.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_bloc.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_event.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_state.dart';
import 'package:quick_forms/features/client/presentation/pages/step2_documents_screen.dart';

class ProfileProgressSection extends StatefulWidget {
  const ProfileProgressSection({super.key});

  @override
  State<ProfileProgressSection> createState() => _ProfileProgressSectionState();
}

class _ProfileProgressSectionState extends State<ProfileProgressSection> {
  bool _showCompletedBanner = false;
  int _lastCompletion = -1;

  Future<void> _handleCompletion(int newCompletion) async {
    final userId = UserSession.instance.userId;
    if (newCompletion < 100 && _lastCompletion >= 100) {
      await SessionStorage.resetProfileCompleteBanner(userId);
    }
    if (newCompletion >= 100 && _lastCompletion >= 0 && _lastCompletion < 100) {
      final alreadyShown =
          await SessionStorage.hasShownProfileCompleteBanner(userId);
      if (!alreadyShown) {
        await SessionStorage.markProfileCompleteBannerShown(userId);
        if (mounted) {
          setState(() => _showCompletedBanner = true);
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _showCompletedBanner = false);
          });
        }
      }
    }
    _lastCompletion = newCompletion;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, userState) {
        if (userState is UserLoaded)
          _handleCompletion(userState.user.profileCompletion);
      },
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, profileState) {
          int? newCompletion;
          if (profileState is ProfileDocumentsLoaded)
            newCompletion = profileState.completion.completion;
          if (profileState is ProfileDocumentUploadedSuccess)
            newCompletion = profileState.completion.completion;
          if (profileState is ProfileDocumentUploadedNeedsVerification)
            newCompletion = profileState.completion.completion;
          if (profileState is ProfileDocumentPatched)
            newCompletion = profileState.completion.completion;
          if (profileState is ProfileDocumentDeleted)
            newCompletion = profileState.completion.completion;
          if (newCompletion != null) _handleCompletion(newCompletion);
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            int? completion;
            if (profileState is ProfileDocumentsLoaded)
              completion = profileState.completion.completion;
            else if (profileState is ProfileDocumentUploadedSuccess)
              completion = profileState.completion.completion;
            else if (profileState is ProfileDocumentUploadedNeedsVerification)
              completion = profileState.completion.completion;
            else if (profileState is ProfileDocumentPatched)
              completion = profileState.completion.completion;
            else if (profileState is ProfileDocumentDeleted)
              completion = profileState.completion.completion;
            else if (profileState is ProfileDocumentUploading)
              completion = profileState.completion.completion;

            if (completion == null) return const SizedBox.shrink();
            if (completion >= 100 && !_showCompletedBanner)
              return const SizedBox.shrink();

            if (_showCompletedBanner) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.statusValideGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            AppColors.statusValideGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: AppColors.statusValideGreen, size: 22),
                      const SizedBox(width: 10),
                      Text('home.profile_completed'.tr(),
                          style: TextStyle(
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.statusValideGreen)),
                    ],
                  ),
                ),
              );
            }

            final progress = (completion / 100).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('home.complete_profile'.tr(),
                      style: TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                          height: 7,
                          decoration: BoxDecoration(
                              color: AppColors.progressTrack,
                              borderRadius: BorderRadius.circular(4))),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                            height: 7,
                            decoration: BoxDecoration(
                                color: AppColors.progressFill,
                                borderRadius: BorderRadius.circular(4))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('$completion%',
                        style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.progressFill)),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                          value: context.read<ProfileBloc>(),
                          child: const Step2DocumentsScreen()),
                    )),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(23)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 20),
                          Text('home.start_now'.tr(),
                              style: TextStyle(
                                  fontFamily: AppConstants.fontFamilySofiaSans,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          const SizedBox(width: 12),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                                color: AppColors.white, shape: BoxShape.circle),
                            child: Icon(Icons.arrow_forward,
                                color: AppColors.primaryDarker, size: 16),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
