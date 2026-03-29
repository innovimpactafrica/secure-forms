class CountryCode {
  final String flag;
  final String name;
  final String dialCode;

  const CountryCode({
    required this.flag,
    required this.name,
    required this.dialCode,
  });
}

const List<CountryCode> kCountryCodes = [
  CountryCode(flag: '🇸🇳', name: 'Sénégal',       dialCode: '+221'),
  CountryCode(flag: '🇫🇷', name: 'France',         dialCode: '+33'),
  CountryCode(flag: '🇨🇮', name: "Côte d'Ivoire",  dialCode: '+225'),
  CountryCode(flag: '🇲🇱', name: 'Mali',           dialCode: '+223'),
  CountryCode(flag: '🇬🇳', name: 'Guinée',         dialCode: '+224'),
  CountryCode(flag: '🇧🇫', name: 'Burkina Faso',   dialCode: '+226'),
  CountryCode(flag: '🇳🇬', name: 'Nigeria',        dialCode: '+234'),
  CountryCode(flag: '🇨🇲', name: 'Cameroun',       dialCode: '+237'),
  CountryCode(flag: '🇲🇦', name: 'Maroc',          dialCode: '+212'),
  CountryCode(flag: '🇩🇿', name: 'Algérie',        dialCode: '+213'),
  CountryCode(flag: '🇧🇪', name: 'Belgique',       dialCode: '+32'),
  CountryCode(flag: '🇨🇭', name: 'Suisse',         dialCode: '+41'),
  CountryCode(flag: '🇺🇸', name: 'États-Unis',     dialCode: '+1'),
  CountryCode(flag: '🇬🇧', name: 'Royaume-Uni',    dialCode: '+44'),
];