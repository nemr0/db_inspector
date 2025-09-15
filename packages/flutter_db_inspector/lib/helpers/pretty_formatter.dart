extension PrettyFormatter on String {
  String get toPrettyFormattedString {
    final s = trim();
    final buf = StringBuffer();
    int depth = 0;
    bool atLineStart = false;

    String indent() => List.filled(depth, '  ').join(); // two spaces per level
    void newLine() {
      if (!atLineStart) {
        buf.writeln();
        atLineStart = true;
      }
    }
    void writeWithIndent(String text) {
      if (atLineStart) {
        buf.write(indent());
        atLineStart = false;
      }
      buf.write(text);
    }



    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      switch (c) {
        case '(':
          writeWithIndent('(');
          newLine();
          depth++;
          break;
        case ')':
          depth = (depth - 1).clamp(0, 1 << 30);
          if (atLineStart) {
            // place closing on its own line with current (decreased) indent
            buf.write(indent());
            atLineStart = false;
          }
          buf.write(')');
          break;
        case ',':
          buf.write(',');
          newLine();
          break;
        default:
          writeWithIndent(c);
      }
    }



    return buf.toString().trimRight();
  }
}
