import 'package:kidsdo/domain/entities/challenge.dart';

/// Biblioteca de retos predefinidos por categoría
class PredefinedChallenges {
  /// Retos de higiene personal
  static final List<Challenge> hygieneList = [
    Challenge(
      id: 'hygiene_teeth_morning',
      title: 'Cepillarse los dientes por la mañana',
      description:
          'Cepillarse los dientes después del desayuno durante al menos 2 minutos',
      category: ChallengeCategory.hygiene,
      points: 10,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 3, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'tooth_brush',
    ),
    Challenge(
      id: 'hygiene_teeth_night',
      title: 'Cepillarse los dientes por la noche',
      description:
          'Cepillarse los dientes antes de acostarse durante al menos 2 minutos',
      category: ChallengeCategory.hygiene,
      points: 10,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 3, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'tooth_brush',
    ),
    Challenge(
      id: 'hygiene_bath',
      title: 'Bañarse sin ayuda',
      description:
          'Bañarse o ducharse sin ayuda, lavando todo el cuerpo correctamente',
      category: ChallengeCategory.hygiene,
      points: 15,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 5, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'shower',
    ),
    Challenge(
      id: 'hygiene_hands',
      title: 'Lavarse las manos',
      description:
          'Lavarse las manos con jabón antes de las comidas y después del baño',
      category: ChallengeCategory.hygiene,
      points: 5,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 3, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'soap',
    ),
    Challenge(
      id: 'hygiene_hair',
      title: 'Peinarse el cabello',
      description: 'Cepillarse o peinarse el cabello después de bañarse',
      category: ChallengeCategory.hygiene,
      points: 5,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 5, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'hair_brush',
    ),
  ];

  /// Retos escolares
  static final List<Challenge> schoolList = [
    Challenge(
      id: 'school_homework',
      title: 'Hacer los deberes escolares',
      description:
          'Completar todas las tareas escolares del día sin necesidad de recordatorios',
      category: ChallengeCategory.school,
      points: 20,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 6, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'book',
    ),
    Challenge(
      id: 'school_reading',
      title: 'Lectura diaria',
      description: 'Leer durante al menos 15 minutos al día',
      category: ChallengeCategory.school,
      points: 15,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 6, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'book_open',
    ),
    Challenge(
      id: 'school_backpack',
      title: 'Preparar mochila escolar',
      description:
          'Preparar la mochila con todos los materiales necesarios para el día siguiente',
      category: ChallengeCategory.school,
      points: 10,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 6, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'backpack',
    ),
    Challenge(
      id: 'school_good_grade',
      title: 'Buena calificación',
      description:
          'Obtener una calificación de 8 o superior en un examen o trabajo',
      category: ChallengeCategory.school,
      points: 30,
      frequency: ChallengeFrequency.once,
      ageRange: const {'min': 6, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'star',
    ),
  ];

  /// Retos de orden
  static final List<Challenge> orderList = [
    Challenge(
      id: 'order_bed',
      title: 'Hacer la cama',
      description: 'Hacer la cama correctamente cada mañana al levantarse',
      category: ChallengeCategory.order,
      points: 10,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 5, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'bed',
    ),
    Challenge(
      id: 'order_toys',
      title: 'Recoger los juguetes',
      description: 'Recoger y guardar todos los juguetes al terminar de jugar',
      category: ChallengeCategory.order,
      points: 10,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 3, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'toys',
    ),
    Challenge(
      id: 'order_room',
      title: 'Ordenar la habitación',
      description:
          'Mantener la habitación ordenada y limpia durante toda la semana',
      category: ChallengeCategory.order,
      points: 25,
      frequency: ChallengeFrequency.weekly,
      ageRange: const {'min': 5, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'room',
    ),
    Challenge(
      id: 'order_clothes',
      title: 'Ordenar la ropa',
      description:
          'Guardar la ropa limpia en el armario y poner la sucia en el cesto',
      category: ChallengeCategory.order,
      points: 10,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 6, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'tshirt',
    ),
  ];

  /// Retos de responsabilidad
  static final List<Challenge> responsibilityList = [
    Challenge(
      id: 'responsibility_schedule',
      title: 'Cumplir con los horarios',
      description:
          'Respetar los horarios establecidos para comidas, tareas y hora de dormir',
      category: ChallengeCategory.responsibility,
      points: 15,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 6, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'clock',
    ),
    Challenge(
      id: 'responsibility_alarm',
      title: 'Levantarse con el despertador',
      description:
          'Levantarse a la primera alarma sin necesidad de recordatorios adicionales',
      category: ChallengeCategory.responsibility,
      points: 10,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 8, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'alarm',
    ),
    Challenge(
      id: 'responsibility_pet',
      title: 'Cuidado de mascota',
      description:
          'Alimentar, limpiar y cuidar de la mascota sin necesidad de recordatorios',
      category: ChallengeCategory.responsibility,
      points: 15,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 6, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'pet',
    ),
    Challenge(
      id: 'responsibility_plant',
      title: 'Cuidado de planta',
      description: 'Regar y cuidar las plantas asignadas según necesiten',
      category: ChallengeCategory.responsibility,
      points: 10,
      frequency: ChallengeFrequency.weekly,
      ageRange: const {'min': 5, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'plant',
    ),
  ];

  /// Retos de ayuda doméstica
  static final List<Challenge> helpList = [
    Challenge(
      id: 'help_table',
      title: 'Poner la mesa',
      description:
          'Poner la mesa correctamente para toda la familia antes de la comida',
      category: ChallengeCategory.help,
      points: 10,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 5, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'cutlery',
    ),
    Challenge(
      id: 'help_dishes',
      title: 'Ayudar con los platos',
      description: 'Llevar los platos sucios a la cocina y ayudar a limpiarlos',
      category: ChallengeCategory.help,
      points: 10,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 5, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'dishes',
    ),
    Challenge(
      id: 'help_trash',
      title: 'Sacar la basura',
      description: 'Recoger y sacar la basura cuando sea necesario',
      category: ChallengeCategory.help,
      points: 10,
      frequency: ChallengeFrequency.weekly,
      ageRange: const {'min': 8, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'trash',
    ),
    Challenge(
      id: 'help_groceries',
      title: 'Ayudar con la compra',
      description: 'Ayudar a guardar la compra en su lugar correspondiente',
      category: ChallengeCategory.help,
      points: 15,
      frequency: ChallengeFrequency.weekly,
      ageRange: const {'min': 6, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'grocery',
    ),
  ];

  /// Retos para eventos especiales
  static final List<Challenge> specialList = [
    Challenge(
      id: 'special_garden',
      title: 'Ayudar en el jardín',
      description:
          'Ayudar con las tareas de jardinería como regar, quitar malas hierbas o plantar',
      category: ChallengeCategory.special,
      points: 20,
      frequency: ChallengeFrequency.weekly,
      ageRange: const {'min': 6, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'garden',
    ),
    Challenge(
      id: 'special_recycle',
      title: 'Reciclar correctamente',
      description:
          'Separar correctamente los residuos en sus contenedores correspondientes',
      category: ChallengeCategory.special,
      points: 15,
      frequency: ChallengeFrequency.weekly,
      ageRange: const {'min': 5, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'recycle',
    ),
    Challenge(
      id: 'special_holiday',
      title: 'Preparación festiva',
      description:
          'Ayudar con la decoración y preparativos para festividades o celebraciones',
      category: ChallengeCategory.special,
      points: 25,
      frequency: ChallengeFrequency.once,
      ageRange: const {'min': 4, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'party',
    ),
  ];

  /// Retos para hermanos
  static final List<Challenge> siblingList = [
    Challenge(
      id: 'sibling_share',
      title: 'Compartir juguetes',
      description:
          'Compartir juguetes y pertenencias con hermanos sin discutir',
      category: ChallengeCategory.sibling,
      points: 15,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 3, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'share',
    ),
    Challenge(
      id: 'sibling_play',
      title: 'Jugar juntos',
      description: 'Jugar juntos durante 30 minutos sin conflictos',
      category: ChallengeCategory.sibling,
      points: 15,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 3, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'play',
    ),
    Challenge(
      id: 'sibling_help',
      title: 'Ayudar al hermano/a',
      description: 'Ayudar al hermano/a menor con alguna tarea o actividad',
      category: ChallengeCategory.sibling,
      points: 20,
      frequency: ChallengeFrequency.daily,
      ageRange: const {'min': 6, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'help',
    ),
    Challenge(
      id: 'sibling_conflict',
      title: 'Resolver conflictos',
      description:
          'Resolver un conflicto con hermanos sin intervención de adultos',
      category: ChallengeCategory.sibling,
      points: 25,
      frequency: ChallengeFrequency.once,
      ageRange: const {'min': 6, 'max': 12},
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      icon: 'handshake',
    ),
  ];

  /// Obtiene todos los retos predefinidos
  static List<Challenge> getAll() {
    return [
      ...hygieneList,
      ...schoolList,
      ...orderList,
      ...responsibilityList,
      ...helpList,
      ...specialList,
      ...siblingList,
    ];
  }

  /// Obtiene retos por categoría
  static List<Challenge> getByCategory(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return hygieneList;
      case ChallengeCategory.school:
        return schoolList;
      case ChallengeCategory.order:
        return orderList;
      case ChallengeCategory.responsibility:
        return responsibilityList;
      case ChallengeCategory.help:
        return helpList;
      case ChallengeCategory.special:
        return specialList;
      case ChallengeCategory.sibling:
        return siblingList;
    }
  }

  /// Obtiene retos por rango de edad
  static List<Challenge> getByAgeRange(int age) {
    return getAll().where((challenge) {
      final minAge = challenge.ageRange['min'] as int;
      final maxAge = challenge.ageRange['max'] as int;
      return age >= minAge && age <= maxAge;
    }).toList();
  }
}
