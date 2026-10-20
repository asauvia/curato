import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class ScrollableTermsDialog extends StatefulWidget {
  final String title;
  final String termsContent;
  final Color primaryColor;
  final Function(bool) onAccepted;

  const ScrollableTermsDialog({
    super.key,
    required this.title,
    required this.termsContent,
    required this.onAccepted,
    this.primaryColor = AppColors.primaryPink,
  });

  @override
  State<ScrollableTermsDialog> createState() => _ScrollableTermsDialogState();
}

class _ScrollableTermsDialogState extends State<ScrollableTermsDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (_scrollController.position.maxScrollExtent <= 5) {
          setState(() {
            _hasScrolledToBottom = true;
          });
        }
      }
    });
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 15) {
        if (!_hasScrolledToBottom) {
          setState(() {
            _hasScrolledToBottom = true;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  List<TextSpan> _parseRichText(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final RegExp regExp = RegExp(
        r'(<b>.*?</b>|<i>.*?</i>|<strong>.*?</strong>|<em>.*?</em>|<li>.*?</li>)',
        dotAll: true);

    int lastMatchEnd = 0;
    final matches = regExp.allMatches(text);

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      final matchedText = match.group(0)!;
      if (matchedText.startsWith('<b>') || matchedText.startsWith('<strong>')) {
        final innerText = matchedText
            .replaceAll('<b>', '')
            .replaceAll('</b>', '')
            .replaceAll('<strong>', '')
            .replaceAll('</strong>', '');
        spans.add(TextSpan(
          text: innerText,
          style: baseStyle.copyWith(fontWeight: FontWeight.bold, color: AppColors.foreground),
        ));
      } else if (matchedText.startsWith('<i>') || matchedText.startsWith('<em>')) {
        final innerText = matchedText
            .replaceAll('<i>', '')
            .replaceAll('</i>', '')
            .replaceAll('<em>', '')
            .replaceAll('</em>', '');
        spans.add(TextSpan(
          text: innerText,
          style: baseStyle.copyWith(fontStyle: FontStyle.italic, color: AppColors.foreground),
        ));
      } else if (matchedText.startsWith('<li>')) {
        final innerText = matchedText
            .replaceAll('<li>', '')
            .replaceAll('</li>', '');
        spans.add(TextSpan(
          text: '\n  • $innerText',
          style: baseStyle.copyWith(color: AppColors.foreground),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.mutedForeground),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20,
                )
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Please scroll to the bottom of the terms to accept.',
              style: GoogleFonts.instrumentSans(
                fontSize: 13,
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.background,
                ),
                padding: const EdgeInsets.all(20),
                child: Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: RichText(
                        text: TextSpan(
                          children: _parseRichText(
                            widget.termsContent.isNotEmpty
                                ? widget.termsContent
                                : "No Terms & Conditions provided.",
                            GoogleFonts.instrumentSans(
                              fontSize: 14,
                              color: AppColors.foreground,
                              height: 1.65,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _hasScrolledToBottom
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: widget.primaryColor.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _agreed,
                            onChanged: (v) {
                              setState(() {
                                _agreed = v ?? false;
                              });
                            },
                            activeColor: widget.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'I have read and agree to the Terms & Conditions.',
                              style: GoogleFonts.instrumentSans(
                                fontSize: 13,
                                color: AppColors.foreground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(border: Border.all(color: AppColors.border),
                          color: AppColors.muted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Scroll down to unlock agreement',
                              style: GoogleFonts.instrumentSans(
                                fontSize: 12,
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mutedForeground,
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.instrumentSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _agreed
                      ? () {
                          widget.onAccepted(true);
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.border,
                    disabledForegroundColor: AppColors.mutedForeground,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Accept & Continue',
                    style: GoogleFonts.instrumentSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
