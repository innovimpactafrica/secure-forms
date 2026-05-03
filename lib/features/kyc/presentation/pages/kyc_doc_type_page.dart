import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/core/utils/user_session.dart';
import 'package:quick_forms/features/kyc/data/models/identity_document_model.dart';
import 'package:quick_forms/features/kyc/data/repositories/identity_document_repository.dart';
import 'package:quick_forms/features/kyc/domain/bloc/kyc_bloc.dart';
import 'kyc_step1_id_page.dart';

class KycDocTypePage extends StatefulWidget {
  const KycDocTypePage({super.key});

  @override
  State<KycDocTypePage> createState() => _KycDocTypePageState();
}

class _KycDocTypePageState extends State<KycDocTypePage> {
  final _repo = IdentityDocumentRepository();
  List<KycDocTypeModel> _types = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final token = UserSession.instance.accessToken;
      final types = await _repo.getKycDocumentTypes(token);
      if (mounted)
        setState(() {
          _types = types;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
    }
  }

  void _navigate(KycDocTypeModel type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<KycBloc>(),
          child: KycStep1IdPage(docType: type),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('kyc.title'.tr(),
                          style: TextStyle(
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontWeight: FontWeight.w600,
                              fontSize: AppConstants.fontSizeLarge,
                              color: AppColors.textBlack87)),
                      Text('kyc.choose_doc_label'.tr(),
                          style: TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontSize: AppConstants.fontSizeRegular,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text('kyc.choose_doc_title'.tr(),
                        style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: AppColors.textBlack87)),
                    const SizedBox(height: 6),
                    Text('kyc.choose_doc_subtitle'.tr(),
                        style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeMedium,
                            color: AppColors.textSecondary,
                            height: 1.5)),
                    const SizedBox(height: 32),
                    if (_loading)
                      const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                    else if (_error != null)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!,
                                style: const TextStyle(
                                    color: AppColors.statusRejected,
                                    fontSize: 14),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _loading = true;
                                  _error = null;
                                });
                                _load();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                    color: AppColors.primaryDark,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text('archives.retry'.tr(),
                                    style: const TextStyle(
                                        color: AppColors.white, fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: _types.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) => _DocTypeItem(
                            type: _types[i],
                            onTap: () => _navigate(_types[i]),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocTypeItem extends StatelessWidget {
  final KycDocTypeModel type;
  final VoidCallback onTap;

  const _DocTypeItem({required this.type, required this.onTap});

  IconData get _icon {
    final t = type.title.toLowerCase();
    if (t.contains('cni') || t.contains('identit'))
      return Icons.credit_card_outlined;
    if (t.contains('passeport') || t.contains('passport'))
      return Icons.book_outlined;
    if (t.contains('permis')) return Icons.drive_eta_outlined;
    return Icons.description_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight, width: 1.5),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(_icon, color: AppColors.primaryDark, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.title,
                      style: TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          fontWeight: FontWeight.w600,
                          fontSize: AppConstants.fontSizeMedium,
                          color: AppColors.textBlack87)),
                  if (type.aliases.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(type.aliases.join(', '),
                        style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeRegular,
                            color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }
}
