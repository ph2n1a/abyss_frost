import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class CreditsFooter extends StatefulWidget {
  const CreditsFooter({super.key});

  @override
  State<CreditsFooter> createState() => _CreditsFooterState();
}

class _CreditsFooterState extends State<CreditsFooter> {
  late final TapGestureRecognizer _siteTap;
  late final TapGestureRecognizer _telegramTap;

  @override
  void initState() {
    super.initState();
    _siteTap = TapGestureRecognizer()
      ..onTap = () => _launch('https://devnetspace.com');
    _telegramTap = TapGestureRecognizer()
      ..onTap = () => _launch('https://t.me/ph2n1a');
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _siteTap.dispose();
    _telegramTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Center(
      child: Text.rich(
        TextSpan(
          style: TextStyle(color: appColors.mediumColor, height: 1.4),
          children: [
            const TextSpan(text: '©DevNet - '),
            TextSpan(
              text: 'https://devnetspace.com',
              style: TextStyle(
                color: appColors.backColor,
                decoration: TextDecoration.underline,
                decorationColor: appColors.backColor,
              ),
              recognizer: _siteTap,
            ),
            const TextSpan(text: '\nTelegram - '),
            TextSpan(
              text: 't.me/ph2n1a',
              style: TextStyle(
                color: appColors.backColor,
                decoration: TextDecoration.underline,
                decorationColor: appColors.backColor,
              ),
              recognizer: _telegramTap,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}