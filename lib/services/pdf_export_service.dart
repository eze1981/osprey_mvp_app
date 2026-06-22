import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:osprey_mvp_app/models/inspection_item.dart';
import 'package:osprey_mvp_app/services/inspection_repository.dart';

class PdfExportService {
  static Future<void> exportAndShare({
    required List<InspectionItem> items,
    required InspectionRepository repository,
  }) async {
    final pdf = pw.Document();
    final count = items.length;
    final earliest = items.last.createdAt;
    final latest = items.first.createdAt;
    final dateRange =
        '${_fmtDate(earliest)} — ${_fmtDate(latest)}';
    final title = 'Inspection Report';
    final subtitle = '$count items · $dateRange';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, text: title),
          pw.Text(subtitle,
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          pw.SizedBox(height: 12),
          ...items.map((item) => _buildItem(item, repository)),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/inspection_report.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)]);
  }

  static pw.Widget _buildItem(InspectionItem item, InspectionRepository repo) {
    final photoPath = repo.getPhotoPath(item);
    final photoFile = File(photoPath);
    final timestamp =
        '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')} '
        '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(timestamp,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        if (photoFile.existsSync())
          pw.Image(
            pw.MemoryImage(photoFile.readAsBytesSync()),
            width: 300,
            fit: pw.BoxFit.contain,
          ),
        pw.SizedBox(height: 4),
        if (item.transcript != null && item.transcript!.isNotEmpty)
          pw.Text(item.transcript!, style: const pw.TextStyle(fontSize: 12)),
        pw.Divider(),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static String _fmtDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
