// PATCH-24
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_icons.dart';
import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/widgets/app_toast.dart';
import '../../../../../../core/widgets/grace_avatar.dart';
import '../../../../../../core/widgets/sub_page.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});
  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _Field {
  _Field(this.label, this.icon, String v, {this.keyboard = TextInputType.text}) : value = v;
  final String label;
  final IconData icon;
  final TextInputType keyboard;
  String value;
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _fields = <_Field>[
    _Field('First Name', AppIcons.userCircle, 'Grace'),
    _Field('Last Name', AppIcons.userCircle, 'Mitchell'),
    _Field('E-mail', AppIcons.mail, 'grace.mitchell@example.com', keyboard: TextInputType.emailAddress),
    _Field('Phone', AppIcons.phone, '(201) 555-0125', keyboard: TextInputType.phone),
    _Field('Home address', AppIcons.pin, '729 Rue J69'),
    _Field('City', AppIcons.pin, 'Abidjan'),
    _Field('Country', AppIcons.globe, 'Côte d\'Ivoire'),
    _Field('Date of birth', AppIcons.clock, '12/03/1994', keyboard: TextInputType.datetime),
  ];
  int? _editing;
  final _ctl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _ctl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _edit(int i) {
    setState(() => _editing = i);
    _ctl.text = _fields[i].value;
    _ctl.selection = TextSelection.collapsed(offset: _ctl.text.length);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _cancel() {
    _focus.unfocus();
    setState(() => _editing = null);
  }

  void _save() {
    final i = _editing!;
    final v = _ctl.text.trim();
    if (v.isNotEmpty) _fields[i].value = v;
    _focus.unfocus();
    setState(() => _editing = null);
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    return SubPage(
      title: 'Profile info',
      child: Column(
        children: [
          const SizedBox(height: 16.3),
          SizedBox(
            width: 96 + 20,
            height: 96,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 10,
                  child: ClipOval(child: SizedBox(width: 96, height: 96, child: Image.memory(kGraceAvatarBytes, fit: BoxFit.cover, gaplessPlayback: true))),
                ),
                Positioned(
                  left: 10 + 96 - 18 - 4.2,
                  top: 96 - 18 - 4.2 + 1,
                  child: GestureDetector(
                    onTap: () => showAppToast(context, 'Change photo'),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(color: c.field, shape: BoxShape.circle, border: Border.all(color: c.background, width: 1.8)),
                      child: Icon(AppIcons.plus, size: 18, color: c.title),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.5),
              decoration: BoxDecoration(color: p.tile, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line, width: 1.2)),
              child: Column(
                children: [
                  for (var i = 0; i < _fields.length; i++) _block(p, i),
                  const SizedBox(height: 4),
                  _deleteButton(p),
                  const SizedBox(height: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _block(AppPalette p, int i) {
    final c = p.c;
    final f = _fields[i];
    final editing = _editing == i;
    final lbl = p.dark ? const Color(0xFFBDBDBD) : const Color(0xFFA8A8A8);
    return Container(
      height: 88,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.divider, width: 1.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 17.5),
          Text(f.label, style: interStyle(lbl, size: 12.6, h: 1.2, ls: -0.25)),
          const Spacer(),
          SizedBox(
            height: 48.3,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.only(left: 15),
              decoration: editing
                  ? BoxDecoration(color: c.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.title, width: 1.2))
                  : null,
              child: Row(
                children: [
                  Icon(f.icon, size: 22, color: editing ? c.title : p.mutedText),
                  const SizedBox(width: 11),
                  Expanded(
                    child: editing
                        ? Material(
                            type: MaterialType.transparency,
                            child: TextField(
                              controller: _ctl,
                              focusNode: _focus,
                              keyboardType: f.keyboard,
                              onSubmitted: (_) => _save(),
                              cursorColor: c.caret,
                              style: interStyle(c.title, size: 14.2, h: 1.2, ls: -0.28),
                              decoration: const InputDecoration(isCollapsed: true, border: InputBorder.none),
                            ),
                          )
                        : Text(f.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: interStyle(p.mutedText, size: 14.2, h: 1.2, ls: -0.28)),
                  ),
                  if (editing) ...[
                    Pressable(onTap: _cancel, child: SizedBox(width: 28, height: 44, child: Icon(AppIcons.xThin, size: 16, color: c.title))),
                    Pressable(onTap: _save, child: SizedBox(width: 30, height: 44, child: Icon(AppIcons.checkThin, size: 18, color: c.title))),
                    const SizedBox(width: 6),
                  ] else
                    Pressable(
                      onTap: () => _edit(i),
                      child: SizedBox(width: 44, height: 44, child: Icon(AppIcons.pencil, size: 20, color: c.title)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8.7),
        ],
      ),
    );
  }

  Widget _deleteButton(AppPalette p) {
    return Pressable(
      onTap: () => showAppToast(context, 'Delete Account'),
      child: Container(
        height: 44.1,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: p.coral, borderRadius: BorderRadius.circular(12)),
        child: Text('Delete Account', style: interStyle(Colors.white, size: 14, w: FontWeight.w500, h: 1.2, ls: -0.3)),
      ),
    );
  }
}
