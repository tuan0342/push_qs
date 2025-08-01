class ClassificationSection extends StatelessWidget {
  const ClassificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _sectionBox(
      title: 'CLASSIFICATION & DECONFLICTION',
      children: [
        const Text('TBM', style: _infoStyle),
        const Text('Raid Size: 1', style: _infoStyle),
        const SizedBox(height: 6),
        DropdownButton<String>(
          value: 'Hostile',
          items: ['Hostile', 'Friendly'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (_) {},
        ),
        DropdownButton<String>(
          value: 'Tactical Ballistic Missile',
          items: ['Tactical Ballistic Missile', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (_) {},
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            FilledButton(onPressed: () {}, child: const Text('Hold Fire')),
            const SizedBox(width: 6),
            OutlinedButton(onPressed: () {}, child: const Text('Cease Fire')),
          ],
        ),
      ],
    );
  }
}
