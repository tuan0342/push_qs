class TrackDetailsSection extends StatelessWidget {
  const TrackDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _sectionBox(
      title: 'TRACK DETAILS',
      children: [
        const Text('Track 117', style: _infoStyle),
        const Text('Source: FP4', style: _infoStyle),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(border: Border.all(color: Colors.white30)),
          child: const Text('IFF Response'),
        ),
        const SizedBox(height: 4),
        FilledButton(onPressed: () {}, child: const Text('Interrogate IFF')),
      ],
    );
  }
}
