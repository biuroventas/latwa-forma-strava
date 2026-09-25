import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'legal_document.dart';

void openLegalDocument(BuildContext context, LegalKind kind) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => LegalDocumentScreen(kind: kind),
    ),
  );
}

void openLegalOrExternal(BuildContext context, String url) {
  if (url == AppConstants.termsUrl) {
    openLegalDocument(context, LegalKind.terms);
    return;
  }
  if (url == AppConstants.privacyPolicyUrl) {
    openLegalDocument(context, LegalKind.privacy);
    return;
  }
  openExternalUrl(url);
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.kind});

  final LegalKind kind;

  static const _ink = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF5C665C);
  static const _link = Color(0xFF009639);

  @override
  Widget build(BuildContext context) {
    final doc = LegalDocument.of(
      kind,
      languageCode: Localizations.localeOf(context).languageCode,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F2),
      appBar: AppBar(
        title: Text(doc.title),
        backgroundColor: const Color(0xFFF4F8F2),
        foregroundColor: _ink,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Text(
            doc.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _ink,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            doc.updated,
            style: const TextStyle(fontSize: 13, color: _muted),
          ),
          const SizedBox(height: 8),
          for (final section in doc.sections) ...[
            const SizedBox(height: 18),
            Text(
              section.heading,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            for (final paragraph in section.paragraphs)
              Padding(
                padding: EdgeInsets.only(top: 8, left: paragraph.bullet ? 4 : 0),
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 15, height: 1.45, color: _ink),
                    children: [
                      if (paragraph.bullet) const TextSpan(text: '•  '),
                      for (final piece in paragraph.pieces)
                        piece.kind == null && piece.url == null
                            ? TextSpan(
                                text: piece.text,
                                style: TextStyle(
                                  fontWeight: piece.bold ? FontWeight.w700 : null,
                                ),
                              )
                            : WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: () => _openPiece(context, piece),
                                  child: Text(
                                    piece.text,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.45,
                                      color: _link,
                                      fontWeight:
                                          piece.bold ? FontWeight.w700 : FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: _link,
                                    ),
                                  ),
                                ),
                              ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _openPiece(BuildContext context, LegalPiece piece) {
    final linked = piece.kind;
    if (linked != null) {
      openLegalDocument(context, linked);
      return;
    }
    final url = piece.url;
    if (url != null) openExternalUrl(url);
  }
}
