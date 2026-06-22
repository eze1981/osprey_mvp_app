import 'package:flutter/cupertino.dart';

import 'package:osprey_mvp_app/models/inspection.dart';
import 'package:osprey_mvp_app/screens/inspection_screen.dart';
import 'package:osprey_mvp_app/services/inspection_repository.dart';

class InspectionsListScreen extends StatefulWidget {
  final InspectionRepository repository;
  final void Function(int) onSetActive;

  const InspectionsListScreen({
    super.key,
    required this.repository,
    required this.onSetActive,
  });

  @override
  State<InspectionsListScreen> createState() => InspectionsListScreenState();
}

class InspectionsListScreenState extends State<InspectionsListScreen> {
  List<Inspection> _inspections = [];
  Map<int, int> _counts = {};

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final inspections = await widget.repository.getAllInspections();
    final counts = <int, int>{};
    for (final i in inspections) {
      counts[i.id] = await widget.repository.getItemCount(i.id);
    }
    if (mounted) setState(() { _inspections = inspections; _counts = counts; });
  }

  Future<void> _createInspection() async {
    final controller = TextEditingController();
    final name = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('New Inspection'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'e.g. 123 Main St - Roof',
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    final id = await widget.repository.createInspection(name);
    widget.onSetActive(id);
    await reload();
  }

  Future<void> _confirmDelete(Inspection inspection, int index) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete inspection?'),
        content: Text('This will delete "${inspection.name}" and all its items.'),
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
    if (confirmed != true) return;
    await widget.repository.deleteInspection(inspection.id);
    setState(() => _inspections.removeAt(index));
  }

  void _openInspection(Inspection inspection) {
    widget.onSetActive(inspection.id);
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => InspectionScreen(
          repository: widget.repository,
          inspectionId: inspection.id,
          title: inspection.name,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Inspections'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _createInspection,
          child: const Icon(CupertinoIcons.add, size: 22),
        ),
      ),
      child: SafeArea(
        child: _inspections.isEmpty
            ? const Center(
                child: Text('No inspections yet.\nTap + to create one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: CupertinoColors.systemGrey, fontSize: 16)),
              )
            : CustomScrollView(
                slivers: [
                  CupertinoSliverRefreshControl(onRefresh: reload),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final inspection = _inspections[index];
                        final count = _counts[inspection.id] ?? 0;
                        return Dismissible(
                          key: ValueKey(inspection.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            color: CupertinoColors.destructiveRed,
                            child: const Icon(CupertinoIcons.trash,
                                color: CupertinoColors.white, size: 24),
                          ),
                          confirmDismiss: (_) async {
                            await _confirmDelete(inspection, index);
                            return false; // we handle removal manually
                          },
                          child: GestureDetector(
                            onTap: () => _openInspection(inspection),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey6.darkColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(inspection.name,
                                            style: const TextStyle(
                                                color: CupertinoColors.white,
                                                fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$count items · ${_formatDate(inspection.createdAt)}',
                                          style: const TextStyle(
                                              color: CupertinoColors.systemGrey,
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(CupertinoIcons.chevron_right,
                                      color: CupertinoColors.systemGrey,
                                      size: 18),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _inspections.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
