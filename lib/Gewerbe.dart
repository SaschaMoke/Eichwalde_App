class Gewerbe{
  final String name;
  final String gewerbeart;
  final String adresse;
  final int tel;
  final String image;

  Gewerbe(
    this.name,
    this.gewerbeart,
    this.adresse,
    this.tel,
    this.image,
  );
}

List gewerbes = [
  Gewerbe('Antiquariat Bahnhofstraße','Einzelhandel','Bahnhofstraße 6',493067803684,'Assets/wappen_Eichwalde.png'),
  Gewerbe('Apfel trifft Zwiebel','Feinkost','Chopinstraße 42',493051653151,'Assets/image2.png'),
  Gewerbe('Autowerkstatt starke mobile','Autowerkstatt','August-Bebel-Allee 48',493067825315,'Assets/image3.png'), 
  Gewerbe('Bäckerei Peter Schneider','Bäckerei','Uhlandallee 55& Bahnhofstraße 88',49337572789,'Assets/image5.png'),
  Gewerbe('BLM Geotest','Auftragnehmer','Schmöckwitzer Straße 90',493063905723,'Assets/image4.png'),
  Gewerbe('Bridge Die Werbeagentur','PR-Agentur','Stadionstraße 5',493054807287,'Assets/image6.png'),
  Gewerbe('Café Josef','Cafe','Bahnhofstraße 10',4930516533820,'Assets/image7.png'),
  Gewerbe('Dachkonzept Ihle Zimmerei- und Dachdeckerhandwerk','Zimmermann','Waldstraße 207',493081829486,'Assets/image8.png'),
  Gewerbe('Das Rabenmütterchen - Keramikwerkstatt','Töpferei','Am Graben 5',49306756767,'Assets/image9.png'),
  Gewerbe('DJ und Veranstaltungsservice','Partyservice','-',4917620703289,'Assets/image10.png'),
  Gewerbe('KOMMA - Eichwalder Buchhandlung','Buchhandlung','Bahnhofstraße 87',49306758511,'Assets/wappen_Eichwalde.png'),
  Gewerbe('Mario - Der Eismacher in Eichwalde','Cafe','Bahnhofstraße 89a',493089756808,'Assets/wappen_Eichwalde.png'),
];