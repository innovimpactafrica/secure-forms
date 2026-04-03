import re

path = 'lib/features/auth/presentation/pages/login_screen.dart'
lines = open(path, encoding='utf-8').readlines()

new_method = """  void _showIncompleteDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
        title: Row(children: [
          const Icon(Icons.info_outline,
              color: AppColors.primary, size: AppConstants.iconSizeLarge),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'login.incomplete_title'.tr(),
              style: const TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontWeight: FontWeight.w700,
                fontSize: AppConstants.fontSizeLarge,
                color: AppColors.textDark),
            ),
          ),
        ]),
        content: Text(
          'login.incomplete_message'.tr(),
          style: const TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            color: AppColors.textSecondary,
            height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('login.incomplete_later'.tr(),
              style: const TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamed(AppRoutes.resumeRegistration);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusRound))),
            child: Text('login.incomplete_action'.tr(),
              style: const TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                color: AppColors.white,
                fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
"""

# Trouver les indices de debut et fin de la methode corrompue
start_idx = None
end_idx = None
for i, line in enumerate(lines):
    if 'void _showIncompleteDialog' in line:
        start_idx = i
    if start_idx is not None and i > start_idx:
        if 'Future<void> _sendFcmTokenAfterLogin' in line:
            end_idx = i
            break

print(f'start={start_idx}, end={end_idx}')
result = lines[:start_idx] + [new_method] + lines[end_idx:]
open(path, 'w', encoding='utf-8').writelines(result)
print(f'Done - total lines: {len(result)}')
