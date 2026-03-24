import 'dart:io';

Future<void> main() async {
  final dir = Directory('assets/images');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final urls = {
    'dragon_bridge.jpg': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Danang_Dragon_Bridge.jpg/1280px-Danang_Dragon_Bridge.jpg',
    'han_river.jpg': 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&q=80&w=1080',
    'tour1.jpg': 'https://images.unsplash.com/photo-1596701062351-8c2c14d1fdd0?auto=format&fit=crop&q=80&w=600',
    'tour2.jpg': 'https://images.unsplash.com/photo-1549488344-c7da4fbce82f?auto=format&fit=crop&q=80&w=600',
    'tour3.jpg': 'https://images.unsplash.com/photo-1620023412581-226871aade6b?auto=format&fit=crop&q=80&w=600',
    'map.jpg': 'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=400',
  };

  for (final entry in urls.entries) {
    try {
      final request = await HttpClient().getUrl(Uri.parse(entry.value));
      final response = await request.close();
      if (response.statusCode == 200) {
        await response.pipe(File('assets/images/${entry.key}').openWrite());
        stdout.writeln('Downloaded ${entry.key}');
      } else {
        stdout.writeln('Failed ${entry.key}: ${response.statusCode}');
        // Provide dummy image
        final fallback = await HttpClient().getUrl(Uri.parse('https://dummyimage.com/600x400/0f1b3e/ffffff.png&text=${entry.key}'));
        final fbResp = await fallback.close();
        await fbResp.pipe(File('assets/images/${entry.key}').openWrite());
      }
    } catch (e) {
      stdout.writeln('Error ${entry.key}: $e');
    }
  }
}
