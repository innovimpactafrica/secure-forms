import re

f = r'lib\features\client\presentation\pages\mes_documents_screen.dart'

with open(f, 'r', encoding='utf-8') as fh:
    content = fh.read()

# ── 1. Mettre à jour l'appel _DocumentViewerSheet ──────────────────────────
old_call = """                  builder: (_) => _DocumentViewerSheet(

                    label: documentType.title,
                    documentId: existing.id,
                  ),"""

new_call = """                  builder: (_) => _DocumentViewerSheet(
                    label: documentType.title,
                    documentId: existing.id,
                    existing: existing,
                    documentType: documentType,
                    directUrl: existing.fileUrl,
                    backFileUrl: existing.backFileUrl,
                    backFileId: existing.backFileId,
                  ),"""

if old_call in content:
    content = content.replace(old_call, new_call)
    print("✓ Appel mis à jour")
else:
    print("✗ Appel non trouvé — tentative regex")
    content = re.sub(
        r'builder: \(_\) => _DocumentViewerSheet\(\s*\n\s*label: documentType\.title,\s*\n\s*documentId: existing\.id,\s*\n\s*\),',
        new_call,
        content
    )
    print("✓ Appel mis à jour via regex")

# ── 2. Remplacer la classe _DocumentViewerSheet complète ───────────────────
# Trouver le début et la fin
start_marker = 'class _DocumentViewerSheet extends StatefulWidget {'
end_marker = 'class _PdfBytesViewer extends StatefulWidget {'

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx == -1 or end_idx == -1:
    print("✗ Marqueurs non trouvés")
    exit(1)

new_viewer = '''class _DocumentViewerSheet extends StatefulWidget {
  final String label;
  final String documentId;
  final String? directUrl;
  final String? backFileUrl;
  final String? backFileId;
  final UploadedDocumentModel existing;
  final DocumentTypeModel documentType;

  const _DocumentViewerSheet({
    required this.label,
    required this.documentId,
    required this.existing,
    required this.documentType,
    this.directUrl,
    this.backFileUrl,
    this.backFileId,
  });

  @override
  State<_DocumentViewerSheet> createState() => _DocumentViewerSheetState();
}

class _DocumentViewerSheetState extends State<_DocumentViewerSheet> {
  final _pageController = PageController();
  int _currentPage = 0;
  Uint8List? _frontBytes;
  Uint8List? _backBytes;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<Uint8List> _fetch(String url, bool withToken) async {
    final token = UserSession.instance.accessToken;
    final headers = withToken
        ? {'Authorization': 'Bearer $token', 'Accept': '*/*'}
        : <String, String>{};
    final r = await http.get(Uri.parse(url), headers: headers);
    if (r.statusCode == 200) return r.bodyBytes;
    throw Exception('Erreur ${r.statusCode}');
  }

  Future<void> _loadFiles() async {
    try {
      final useDirectUrl = widget.directUrl != null && widget.directUrl!.isNotEmpty;
      final mainUrl = useDirectUrl
          ? widget.directUrl!
          : BaseUrl.profileDocumentFile(widget.documentId);
      final front = await _fetch(mainUrl, !useDirectUrl);
      Uint8List? back;
      if (widget.backFileUrl != null && widget.backFileUrl!.isNotEmpty) {
        back = await _fetch(widget.backFileUrl!, false);
      }
      if (mounted) setState(() { _frontBytes = front; _backBytes = back; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<Uint8List> get _pages {
    final list = <Uint8List>[];
    if (_frontBytes != null) list.add(_frontBytes!);
    if (_backBytes != null) list.add(_backBytes!);
    return list;
  }

  void _deleteCurrentPage(BuildContext context) {
    final isBack = _currentPage == 1 && _backBytes != null;
    final docId = isBack
        ? (widget.backFileId ?? widget.existing.id)
        : widget.existing.id;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
        title: Text('documents.delete_confirm_title'.tr(),
            style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w700, fontSize: AppConstants.fontSizeLarge, color: AppColors.textDark)),
        content: Text('documents.delete_confirm_body'.tr(),
            style: TextStyle(fontFamily: AppConstants.fontFamilyInter, fontSize: AppConstants.fontSizeMedium, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('documents.cancel'.tr(), style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ProfileDocumentRepository.invalidate(docId);
              context.read<ProfileBloc>().add(DeleteProfileDocumentEvent(documentId: docId));
              Navigator.of(context).pop();
            },
            child: Text('documents.delete'.tr(),
                style: TextStyle(color: AppColors.statusRejected, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _editCurrentPage(BuildContext context) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: _DocumentUpdateModal(
          documentType: widget.documentType,
          existingDocument: widget.existing,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final pages = _pages;
    final total = pages.length;

    return Container(
      height: screenH * 0.92,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: AppConstants.modalHandleWidth,
                    height: AppConstants.modalHandleHeight,
                    decoration: BoxDecoration(
                      color: AppColors.modalHandle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          fontWeight: FontWeight.w700,
                          fontSize: AppConstants.fontSizeXXLarge,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!_loading && total > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentPage + 1}/$total',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeRegular,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (!_loading)
                      GestureDetector(
                        onTap: () => _editCurrentPage(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryDark),
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (!_loading)
                      GestureDetector(
                        onTap: () => _deleteCurrentPage(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.statusRejected.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.delete_outline, size: 18, color: AppColors.statusRejected),
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close, color: AppColors.textSecondary, size: AppConstants.iconSizeLarge),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryDark)))
                : _error != null
                    ? Center(child: Text(_error!, style: TextStyle(color: AppColors.statusRejected, fontSize: 14)))
                    : total == 0
                        ? Center(child: Icon(Icons.insert_drive_file_outlined, size: 80, color: AppColors.primary))
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: total,
                            onPageChanged: (i) => setState(() => _currentPage = i),
                            itemBuilder: (_, i) => InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: Image.memory(
                                pages[i],
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
                            ),
                          ),
          ),
          if (!_loading && total > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(total, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppColors.primaryDark : AppColors.borderGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }
}

'''

content = content[:start_idx] + new_viewer + content[end_idx:]
print("✓ Classe _DocumentViewerSheet remplacée")

with open(f, 'w', encoding='utf-8') as fh:
    fh.write(content)

print("✓ Fichier sauvegardé")
