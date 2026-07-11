import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// Renders fenced code blocks in AI chat replies with syntax highlighting.
class MarkdownCodeBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String language = element.attributes['class']
            ?.replaceFirst('language-', '') ??
        'plaintext';
    final String code = element.textContent.trimRight();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: HighlightView(
        code,
        language: language,
        theme: githubTheme,
        padding: const EdgeInsets.all(12),
        textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      ),
    );
  }
}
