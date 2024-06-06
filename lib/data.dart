// data.dart
import 'dart:core';
import 'dart:ffi';

final Map<String, String> fileUrls = {
  '개역개정': 'https://lifovebible.github.io/data/kornkrv.lfa',
  '바른성경': 'https://lifovebible.github.io/data/korktv.lfa',
  '개역한글': 'https://lifovebible.github.io/data/korhrv.lfa',
  '흠정역': 'https://lifovebible.github.io/data/korHKJV.lfa',
  '개역한글국한문': 'https://lifovebible.github.io/data/kchhrv.lfa',
  '가톨릭성경': 'https://lifovebible.github.io/data/korcath.lfa',
  '中文英皇欽定本上帝版繁體': 'https://lifovebible.github.io/data/ckjv.lfa',
  '中文英皇欽定本神版繁體': 'https://lifovebible.github.io/data/ckjvgod.lfa',
  '中文英皇钦定本上帝版简体': 'https://lifovebible.github.io/data/ckjvsimp.lfa',
  '中文英皇钦定本神版简体': 'https://lifovebible.github.io/data/ckjvsimpgod.lfa',
  '新译本简体': 'https://lifovebible.github.io/data/chnncv.lfa',
  '新译本繁體': 'https://lifovebible.github.io/data/chnncvtr.lfa',
  '和合本简体': 'https://lifovebible.github.io/data/chnunisimpnospace.lfa',
  '和合本繁體': 'https://lifovebible.github.io/data/chuniwospace.lfa',
  '思高繁体聖經': 'https://lifovebible.github.io/data/chncath.lfa',
  'KJV': 'https://lifovebible.github.io/data/engkjv.lfa',
  'ASV': 'https://lifovebible.github.io/data/engasv.lfa',
  'Darby': 'https://lifovebible.github.io/data/engdrb.lfa',
  'ESV': 'https://lifovebible.github.io/data/engesv.lfa',
  'GNT': 'https://lifovebible.github.io/data/enggnt.lfa',
  'Weymouth(NT)': 'https://lifovebible.github.io/data/engwmt.lfa',
  'YLT': 'https://lifovebible.github.io/data/engylt.lfa',
  'Albanian(Bibla e Shenjtë)':
      'https://lifovebible.github.io/data/albanian.lfa',
  'Bulgarian(БЪЛГАРСКА БИБЛИЯ)':
      'https://lifovebible.github.io/data/croatian.lfa',
  'Croatian(BIBLIJA)': 'https://lifovebible.github.io/data/amharic.lfa',
  'Czech(česko Bible)': 'https://lifovebible.github.io/data/czech.lfa',
  'Danish(Bibelen)': 'https://lifovebible.github.io/data/danish.lfa',
  'Dutch(De Bijbel)': 'https://lifovebible.github.io/data/dutch.lfa',
  'Finnish(PyhäRaamattu)': 'https://lifovebible.github.io/data/finpr.lfa',
  'PyhäRaamattu(1933/1938)': 'https://lifovebible.github.io/data/finpr38.lfa',
  'French(Darby)': 'https://lifovebible.github.io/data/frdarby.lfa',
  'French(L.Segond)': 'https://lifovebible.github.io/data/frsegond.lfa',
  'German(Luther)': 'https://lifovebible.github.io/data/gerlut.lfa',
  'Greek(Septuagint/OT)': 'https://lifovebible.github.io/data/grestg.lfa',
  'Greek(Stephanos/NT)': 'https://lifovebible.github.io/data/grestp.lfa',
  'Transliterated(OT)': 'https://lifovebible.github.io/data/hbrtrl.lfa',
  'Hebrew(Modern)': 'https://lifovebible.github.io/data/hebmod.lfa',
  'HebrewOT(BHS)NT': 'https://lifovebible.github.io/data/hebrewbhs.lfa',
  'HebrewOT(WLC)': 'https://lifovebible.github.io/data/hebrewwlc.lfa',
  'Hungarian(Biblia)': 'https://lifovebible.github.io/data/hungarian.lfa',
  'Hindi(पवित्र बाइबिल)': 'https://lifovebible.github.io/data/hindi.lfa',
  'Icelandic(Biblían)': 'https://lifovebible.github.io/data/icelandic.lfa',
  'IndonesiaTer.Baru': 'https://lifovebible.github.io/data/idntbaru.lfa',
  'Japanese(口語訳)': 'https://lifovebible.github.io/data/jpnjct.lfa',
  'Japanese(新改訳)': 'https://lifovebible.github.io/data/jpnnew.lfa',
  'Japanese(新共同訳)': 'https://lifovebible.github.io/data/jpnnit.lfa',
  'Latin(Vulgate)': 'https://lifovebible.github.io/data/latvul.lfa',
  'Lithuanian': 'https://lifovebible.github.io/data/lith.lfa',
  'Malagasy': 'https://lifovebible.github.io/data/malagasy.lfa',
  'Persian(کتاب مقدس)': 'https://lifovebible.github.io/data/persian.lfa',
  'Portuguese': 'https://lifovebible.github.io/data/prtaa.lfa',
  'Russian(Synodal)': 'https://lifovebible.github.io/data/russyn.lfa',
  'Spanish(ReinaValera1960)': 'https://lifovebible.github.io/data/spnrei.lfa',
  'Tagalog': 'https://lifovebible.github.io/data/tagalog.lfa',
  'Tagalog(Mag.Bal.)': 'https://lifovebible.github.io/data/tagamag.lfa',
  'Thai': 'https://lifovebible.github.io/data/thai.lfa',
  'Turkish': 'https://lifovebible.github.io/data/turkish.lfa',
  'Vietnamese': 'https://lifovebible.github.io/data/vietnamese.lfa',
  'Myanmarese': 'https://lifovebible.github.io/data/my.lfa',
  'Amharic(መጽሐፍ ቅዱስ)': 'https://lifovebible.github.io/data/amharic.lfa',
  'Bengali(পবিত্র বাইবেল)': 'https://lifovebible.github.io/data/bengali.lfa',
  'Italian(La Sacra Bibbia)': 'https://lifovebible.github.io/data/italian.lfa',
  'Kannada(ಪವಿತ್ರ ಬೈಬಲ್)': 'https://lifovebible.github.io/data/kannada.lfa',
  'Luganda(Baibuli y\'Oluganda)':
      'https://lifovebible.github.io/data/luganda.lfa'
};

final Map<String, int> bookChapters = {
  'Genesis': 50,
  'Exodus': 40,
  'Leviticus': 27,
  'Numbers': 36,
  'Deuteronomy': 34,
  'Joshua': 24,
  'Judges': 21,
  'Ruth': 4,
  '1 Samuel': 31,
  '2 Samuel': 24,
  '1 Kings': 22,
  '2 Kings': 25,
  '1 Chronicles': 29,
  '2 Chronicles': 36,
  'Ezra': 10,
  'Nehemiah': 13,
  'Esther': 10,
  'Job': 42,
  'Psalms': 150,
  'Proverbs': 31,
  'Ecclesiastes': 12,
  'Song of Solomon': 8,
  'Isaiah': 66,
  'Jeremiah': 52,
  'Lamentations': 5,
  'Ezekiel': 48,
  'Daniel': 12,
  'Hosea': 14,
  'Joel': 3,
  'Amos': 9,
  'Obadiah': 1,
  'Jonah': 4,
  'Micah': 7,
  'Nahum': 3,
  'Habakkuk': 3,
  'Zephaniah': 3,
  'Haggai': 2,
  'Zechariah': 14,
  'Malachi': 4,
  'Matthew': 28,
  'Mark': 16,
  'Luke': 24,
  'John': 21,
  'Acts': 28,
  'Romans': 16,
  '1 Corinthians': 16,
  '2 Corinthians': 13,
  'Galatians': 6,
  'Ephesians': 6,
  'Philippians': 4,
  'Colossians': 4,
  '1 Thessalonians': 5,
  '2 Thessalonians': 3,
  '1 Timothy': 6,
  '2 Timothy': 4,
  'Titus': 3,
  'Philemon': 1,
  'Hebrews': 13,
  'James': 5,
  '1 Peter': 5,
  '2 Peter': 3,
  '1 John': 5,
  '2 John': 1,
  '3 John': 1,
  'Jude': 1,
  'Revelation': 22,
};

class ReadStatus {
  String version = "";
  Map<String, List<bool>> isRead = {
    'Genesis': List.filled(50, false),
    'Exodus': List.filled(40, false),
    'Leviticus': List.filled(27, false),
    'Numbers': List.filled(36, false),
    'Deuteronomy': List.filled(34, false),
    'Joshua': List.filled(24, false),
    'Judges': List.filled(21, false),
    'Ruth': List.filled(4, false),
    '1 Samuel': List.filled(31, false),
    '2 Samuel': List.filled(24, false),
    '1 Kings': List.filled(22, false),
    '2 Kings': List.filled(25, false),
    '1 Chronicles': List.filled(29, false),
    '2 Chronicles': List.filled(36, false),
    'Ezra': List.filled(10, false),
    'Nehemiah': List.filled(13, false),
    'Esther': List.filled(10, false),
    'Job': List.filled(42, false),
    'Psalms': List.filled(150, false),
    'Proverbs': List.filled(31, false),
    'Ecclesiastes': List.filled(12, false),
    'Song of Solomon': List.filled(8, false),
    'Isaiah': List.filled(66, false),
    'Jeremiah': List.filled(52, false),
    'Lamentations': List.filled(5, false),
    'Ezekiel': List.filled(48, false),
    'Daniel': List.filled(12, false),
    'Hosea': List.filled(14, false),
    'Joel': List.filled(3, false),
    'Amos': List.filled(9, false),
    'Obadiah': List.filled(1, false),
    'Jonah': List.filled(4, false),
    'Micah': List.filled(7, false),
    'Nahum': List.filled(3, false),
    'Habakkuk': List.filled(3, false),
    'Zephaniah': List.filled(3, false),
    'Haggai': List.filled(2, false),
    'Zechariah': List.filled(14, false),
    'Malachi': List.filled(4, false),
    'Matthew': List.filled(28, false),
    'Mark': List.filled(16, false),
    'Luke': List.filled(24, false),
    'John': List.filled(21, false),
    'Acts': List.filled(28, false),
    'Romans': List.filled(14, false),
    '1 Corinthians': List.filled(16, false),
    '2 Corinthians': List.filled(13, false),
    'Galatians': List.filled(6, false),
    'Ephesians': List.filled(6, false),
    'Philippians': List.filled(4, false),
    'Colossians': List.filled(4, false),
    '1 Thessalonians': List.filled(5, false),
    '2 Thessalonians': List.filled(3, false),
    '1 Timothy': List.filled(6, false),
    '2 Timothy': List.filled(4, false),
    'Titus': List.filled(3, false),
    'Philemon': List.filled(1, false),
    'Hebrews': List.filled(13, false),
    'James': List.filled(5, false),
    '1 Peter': List.filled(5, false),
    '2 Peter': List.filled(3, false),
    '1 John': List.filled(5, false),
    '2 John': List.filled(1, false),
    '3 John': List.filled(1, false),
    'Jude': List.filled(1, false),
    'Revelation': List.filled(22, false),
  };

  ReadStatus(this.version);

  bool? getRead(String book, int chapter) {
    return isRead[book]?[chapter];
  }

  void setRead(String book, int chapter) {
    isRead[book]?[chapter] = true;
  }

  String getVersion() {
    return version;
  }

  int? getLength(String book) {
    return isRead[book]?.length;
  }

  void clearAllReads() {
    for(var k in isRead.keys) {
      isRead[k]?.fillRange(0, isRead[k]!.length, false);
    }
  }
}

List<ReadStatus> reads = [];
List<String> selectedVersions = [];
Set<String> downloadedVersions = {};
Map<String, List<String>> filesMap = {};
Map<String, String> fileContents = {};
