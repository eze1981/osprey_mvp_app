import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:osprey_mvp_app/models/inspection_item.dart';
import 'package:osprey_mvp_app/screens/inspection_detail_screen.dart';
import 'package:osprey_mvp_app/services/inspection_repository.dart';
import 'package:osprey_mvp_app/services/pdf_export_service.dart';

class InspectionScreen extends StatefulWidget {
  final InspectionRepository repository;
  final int inspectionId;
  final String title;
  const InspectionScreen({super.key, required this.repository, required this.inspectionId, required this.title});

  @override
  State<InspectionScreen> createState() => InspectionScreenState();
}

class InspectionScreenState extends State<InspectionScreen> {
  List<InspectionItem> _items = [];

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final items = await widget.repository.getItemsForInspection(widget.inspectionId);
    if (mounted) setState(() => _items = items);
  }

  Future<void> _exportPdf() async {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CupertinoActivityIndicator(radius: 16)),
    );
    await PdfExportService.exportAndShare(
      items: _items,
      repository: widget.repository,
    );
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  Future<bool> _confirmDelete() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete inspection?'),
        content:
            const Text('This will permanently remove the photo and audio.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _openDetail(InspectionItem item) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => InspectionDetailScreen(
          item: item,
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_items.isEmpty
            ? widget.title
            : '${widget.title} (${_items.length})'),
        trailing: _items.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _exportPdf,
                child: const Icon(CupertinoIcons.share, size: 22),
              )
            : null,
      ),
      child: SafeArea(
        child: _items.isEmpty
            ? const Center(
                child: Text('No inspections yet',
                    style: TextStyle(
                        color: CupertinoColors.systemGrey, fontSize: 16)),
              )
            : CustomScrollView(
                slivers: [
                  CupertinoSliverRefreshControl(onRefresh: reload),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCard(_items[index], index),
                      childCount: _items.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCard(InspectionItem item, int index) {
    final photoPath = widget.repository.getPhotoPath(item);
    final photoExists = File(photoPath).existsSync();

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: CupertinoColors.destructiveRed,
        child: const Icon(CupertinoIcons.trash,
            color: CupertinoColors.white, size: 24),
      ),
      confirmDismiss: (_) => _confirmDelete(),
      onDismissed: (_) async {
        await widget.repository.deleteItem(item.id);
        setState(() => _items.removeAt(index));
      },
      child: GestureDetector(
        onTap: () => _openDetail(item),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6.darkColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: photoExists
                      ? Image.file(File(photoPath), fit: BoxFit.cover)
                      : Container(
                          color: CupertinoColors.systemGrey4,
                          child: const Icon(CupertinoIcons.photo,
                              color: CupertinoColors.systemGrey)),
                ),
              ),
              const SizedBox(width: 12),
              // Timestamp + transcript preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTimestamp(item.createdAt),
                      style: const TextStyle(
                          color: CupertinoColors.systemGrey, fontSize: 12),
                    ),
                    if (item.transcript != null && item.transcript!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.transcript!,
                          style: const TextStyle(
                              color: CupertinoColors.white, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (item.transcript == null || item.transcript!.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Transcribing...',
                          style: TextStyle(
                              color: CupertinoColors.systemGrey, fontSize: 13,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(CupertinoIcons.chevron_right,
                  color: CupertinoColors.systemGrey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
