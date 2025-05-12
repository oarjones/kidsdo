import 'package:kidsdo/domain/entities/reward.dart'; // Asegúrate que la ruta sea correcta

// Podríamos añadir una categoría para las recompensas predefinidas
enum PredefinedRewardCategory {
  treats, // Comida, dulces
  screenTime, // Tiempo de pantalla, videojuegos
  activities, // Actividades especiales, salidas
  privileges, // Privilegios especiales en casa
  toysAndGames, // Juguetes, juegos
  learning, // Libros, material educativo
  other,
}

// Helper para convertir el enum de categoría a String y viceversa
String predefinedRewardCategoryToString(PredefinedRewardCategory category) =>
    category.name;
PredefinedRewardCategory predefinedRewardCategoryFromString(
    String? categoryString) {
  return PredefinedRewardCategory.values.firstWhere(
    (e) => e.name == categoryString,
    orElse: () => PredefinedRewardCategory.other,
  );
}

/// Clase que define la estructura de una RECOMPENSA PREDEFINIDA (plantilla).
/// Esta es diferente de la entidad `Reward` que se guarda para cada familia.
class PredefinedReward {
  final String id; // ID único para la plantilla de recompensa predefinida
  final Map<String, String>
      name; // Nombres traducidos, ej: {'es': 'Nombre ES', 'en': 'Name EN'}
  final Map<String, String>? description; // Descripciones traducidas, opcional
  final int pointsRequired; // Puntos sugeridos
  final RewardType type; // Tipo de recompensa (enum de reward.dart)
  final String icon; // Nombre del asset del icono (ej: "ice_cream_icon")
  final Map<String, dynamic>?
      typeSpecificData; // Datos adicionales específicos del tipo
  final bool isUnique; // Sugerencia de si es única
  final PredefinedRewardCategory
      category; // Categoría de la recompensa predefinida

  const PredefinedReward({
    required this.id,
    required this.name,
    this.description,
    required this.pointsRequired,
    required this.type,
    required this.icon,
    this.typeSpecificData,
    this.isUnique = false,
    required this.category,
  });
}

final List<PredefinedReward> predefinedRewardsList = [
  // --- TREATS ---
  const PredefinedReward(
    id: 'pr_treat_ice_cream',
    name: {'es': 'Helado Especial', 'en': 'Special Ice Cream'},
    description: {
      'es': 'Un helado grande después de la cena.',
      'en': 'A big ice cream after dinner.'
    },
    pointsRequired: 100,
    type: RewardType.simple,
    icon: 'ice_cream_icon', // Placeholder, necesitarás los assets
    category: PredefinedRewardCategory.treats,
  ),
  const PredefinedReward(
    id: 'pr_treat_movie_snacks',
    name: {'es': 'Snacks para la Película', 'en': 'Movie Snacks'},
    description: {
      'es': 'Palomitas y tu snack favorito para la noche de película.',
      'en': 'Popcorn and your favorite snack for movie night.'
    },
    pointsRequired: 150,
    type: RewardType.simple,
    icon: 'popcorn_icon',
    category: PredefinedRewardCategory.treats,
  ),

  // --- SCREEN TIME ---
  const PredefinedReward(
    id: 'pr_screen_30min_extra',
    name: {
      'es': '30 Minutos Extra de Pantalla',
      'en': '30 Extra Screen Minutes'
    },
    description: {
      'es':
          'Disfruta de 30 minutos adicionales en tu dispositivo o videojuego favorito.',
      'en': 'Enjoy 30 additional minutes on your favorite device or video game.'
    },
    pointsRequired: 200,
    type: RewardType.digitalAccess,
    icon: 'game_controller_icon',
    typeSpecificData: {
      'accessType': 'generic_device_time',
      'durationMinutes': 30
    },
    category: PredefinedRewardCategory.screenTime,
  ),
  const PredefinedReward(
    id: 'pr_screen_choose_movie',
    name: {'es': 'Elegir la Película Familiar', 'en': 'Choose Family Movie'},
    description: {
      'es': 'Tú eliges qué película verá la familia esta noche.',
      'en': 'You get to choose what movie the family watches tonight.'
    },
    pointsRequired: 250,
    type: RewardType.privilege, // O experience
    icon: 'movie_ticket_icon',
    category: PredefinedRewardCategory.screenTime, // O activities
  ),

  // --- ACTIVITIES / EXPERIENCES ---
  const PredefinedReward(
    id: 'pr_activity_park_trip',
    name: {
      'es': 'Viaje al Parque de Atracciones',
      'en': 'Trip to the Amusement Park'
    },
    description: {
      'es': 'Una excursión especial al parque de atracciones o temático.',
      'en': 'A special outing to the amusement or theme park.'
    },
    pointsRequired: 1000,
    type: RewardType.experience,
    icon: 'ferris_wheel_icon',
    category: PredefinedRewardCategory.activities,
    isUnique: true,
  ),
  const PredefinedReward(
    id: 'pr_activity_stay_up_late',
    name: {'es': 'Acostarse 30 Min Tarde', 'en': 'Stay Up 30 Min Later'},
    description: {
      'es': 'Puedes acostarte 30 minutos más tarde de tu hora habitual.',
      'en': 'You can go to bed 30 minutes later than your usual bedtime.'
    },
    pointsRequired: 180,
    type: RewardType.privilege,
    icon: 'moon_stars_icon',
    category: PredefinedRewardCategory.privileges,
  ),

  // --- TOYS & GAMES ---
  const PredefinedReward(
    id: 'pr_toy_small_surprise',
    name: {'es': 'Juguete Sorpresa Pequeño', 'en': 'Small Surprise Toy'},
    description: {
      'es': 'Un pequeño juguete sorpresa elegido por tus padres.',
      'en': 'A small surprise toy chosen by your parents.'
    },
    pointsRequired: 300,
    type: RewardType
        .product, // o surprise si el contenido es realmente desconocido
    icon: 'gift_icon',
    category: PredefinedRewardCategory.toysAndGames,
  ),

  // --- LEARNING ---
  const PredefinedReward(
    id: 'pr_learning_new_book',
    name: {'es': 'Libro Nuevo', 'en': 'New Book'},
    description: {
      'es': 'Elige un libro nuevo para leer.',
      'en': 'Choose a new book to read.'
    },
    pointsRequired: 250,
    type: RewardType.product,
    icon: 'book_icon',
    category: PredefinedRewardCategory.learning,
  ),

  // --- Long Term Goal Example (más complejo de implementar solo con esto) ---
  // PredefinedReward(
  //   id: 'pr_goal_bike',
  //   name: {'es': 'Bicicleta Nueva', 'en': 'New Bicycle'},
  //   description: {'es': 'Ahorra para conseguir una bicicleta nueva.', 'en': 'Save up to get a new bicycle.'},
  //   pointsRequired: 5000, // Puntos para la meta final
  //   type: RewardType.longTermGoal,
  //   icon: 'bicycle_icon',
  //   category: PredefinedRewardCategory.toysAndGames,
  //   isUnique: true,
  // ),
];

// Funciones helper (opcionales, ya que la traducción se manejará en el repositorio al leer)
String getTranslatedPredefinedRewardName(
    PredefinedReward predefinedReward, String languageCode) {
  return predefinedReward.name[languageCode] ??
      predefinedReward.name['en'] ??
      predefinedReward.id;
}

String? getTranslatedPredefinedRewardDescription(
    PredefinedReward predefinedReward, String languageCode) {
  if (predefinedReward.description == null) return null;
  return predefinedReward.description![languageCode] ??
      predefinedReward.description!['en'];
}
