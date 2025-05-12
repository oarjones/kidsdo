# Documento Funcional: Módulo de Recompensas - KidsDo (Versión Actualizada)

**Fecha de Última Modificación:** 11 de mayo de 2025

**Versión:** 1.0

## 1. Introducción

### 1.1. Propósito del Módulo
El módulo de Recompensas tiene como objetivo principal incentivar y motivar a los niños a completar desafíos y adoptar comportamientos positivos mediante un sistema de refuerzo. Este módulo permitirá a los padres definir recompensas personalizadas o predefinidas que los niños podrán obtener al acumular puntos o cumplir ciertos criterios establecidos. Se busca que sea una herramienta flexible para los padres y atractiva para los niños (cuya interfaz se desarrollará en una fase posterior).

### 1.2. Alineación con la Visión de KidsDo
KidsDo busca ser una herramienta integral para la gestión de tareas y el fomento de hábitos en los niños, mejorando la dinámica familiar. El módulo de recompensas se alinea directamente con esta visión al:
* Proporcionar un mecanismo de refuerzo positivo tangible.
* Fomentar la autonomía y responsabilidad del niño al trabajar hacia metas.
* Facilitar la comunicación y el acuerdo entre padres e hijos sobre expectativas y reconocimientos.
* Integrarse con el sistema de desafíos existente, creando un ciclo completo de tarea-esfuerzo-recompensa.

## 2. Objetivos del Módulo

### 2.1. Para los Niños (Lógica subyacente en esta fase)
* Soportar un sistema claro y motivador para visualizar y alcanzar recompensas (la visualización directa por el niño se implementará en UI/UX futura).
* Permitir la acumulación de puntos y el canje de recompensas como base para el reconocimiento de sus esfuerzos.
* Establecer las bases para que comprendan el valor del esfuerzo y la constancia.

### 2.2. Para los Padres (Enfoque principal de UI/UX en esta fase)
* Brindar una herramienta flexible y completa para configurar y gestionar recompensas.
* Facilitar la incentivación de comportamientos deseados y la finalización de tareas.
* Permitir la personalización de las recompensas según las preferencias y necesidades de cada niño y familia.
* Mantener un registro detallado de las recompensas otorgadas y los puntos de los niños.
* Gestionar el proceso de canje de recompensas.

## 3. Alcance del Módulo (Fase Actual)

### 3.1. Funcionalidades Principales Incluidas
* Definición de un sistema de puntos que los niños ganan al completar desafíos.
* **Gestión completa de recompensas por parte de los padres:**
    * Creación, edición y eliminación de recompensas (nombre, descripción, coste en puntos, imagen/icono, tipo).
    * Inclusión de "Recompensas Predefinidas por la App" que los padres pueden activar y personalizar.
* **Lógica de canje de recompensas:**
    * Aunque la UI del niño no se implementa, la lógica para que una recompensa pueda ser marcada como "solicitada para canje" (potencialmente por acción del padre en nombre del niño inicialmente, o preparándose para la UI futura del niño).
    * Aprobación/Denegación de canjes por parte de los padres.
* **Gestión y visualización de puntos del niño por parte de los padres.**
* **Notificaciones para padres** relacionadas con el proceso de canje de recompensas. Lógica de notificaciones para niños preparada para futura UI.
* **Modelos de datos y lógica de negocio para todas las funcionalidades descritas, incluyendo las que interactuarán con la UI del niño en el futuro.**

### 3.2. Funcionalidades con UI/UX de Niño Postergada (Lógica y modelos sí se desarrollan)
* Listado de recompensas disponibles visible para los niños.
* Solicitud de canje de recompensas iniciada directamente por el niño desde su interfaz.
* Visualización del saldo de puntos y recompensas obtenidas por los niños en su propia interfaz.
* Notificaciones directas y visibles en la interfaz del niño.

### 3.3. Funcionalidades Fuera de Alcance (para esta primera versión, podrían considerarse a futuro)
* Recompensas grupales complejas que requieran contribuciones de varios niños para un objetivo común familiar.
* Integración con tiendas externas para recompensas físicas.

## 4. Roles de Usuario y Funcionalidades Detalladas

### 4.1. Administrador/Padre (UI/UX a implementar en esta fase)

* **Gestión de Puntos por Desafío:**
    * Al crear o editar un desafío, asignar un valor en "puntos de recompensa" que el niño ganará al completarlo satisfactoriamente.
* **Creación y Configuración de Recompensas:**
    * Acceder a una sección "Recompensas" en el panel de administración.
    * Utilizar una biblioteca de "Recompensas Predefinidas por la App" como base o inspiración.
    * Definir nuevas recompensas personalizadas con los siguientes atributos:
        * Nombre de la recompensa.
        * Descripción (opcional, pero puede ser la "sorpresa" en `RewardType.SURPRISE`).
        * Coste en puntos (puede ser 0 para recompensas otorgadas directamente o sorpresas especiales).
        * **Tipo de recompensa (`RewardType` enum):**
            * `PREDEFINED_PRIVILEGE`: Un privilegio común sugerido por la app (ej: "30 min extra de videojuegos").
            * `CUSTOM_PRIVILEGE`: Permisos especiales definidos por el padre (ej: "Acostarse 30 min más tarde").
            * `PREDEFINED_FAMILY_ACTIVITY`: Actividad familiar común sugerida (ej: "Noche de peli con palomitas").
            * `CUSTOM_FAMILY_ACTIVITY`: Actividad familiar definida por el padre (ej: "Ir al parque de atracciones el sábado").
            * `PREDEFINED_SMALL_GIFT`: Pequeño objeto/regalo sugerido (ej: "Un sobre de cromos").
            * `CUSTOM_SMALL_GIFT`: Regalo específico definido por el padre (ej: "Ese libro que querías").
            * `SURPRISE`: El niño ve un nombre genérico/atractivo (ej: "Caja Misteriosa"), pero el contenido real (en la descripción, visible solo para el padre inicialmente) se revela al canjear/aprobar.
            * `LONG_TERM_GOAL`: Recompensa significativa a largo plazo con condiciones especiales (ver sub-sección abajo).
            * `DIGITAL_APP_UNLOCK`: Desbloqueo de contenido en la app (ej: nuevo avatar, tema).
            * `CHARITABLE_DONATION`: Contribuir a una causa (gestionado por padres).
            * `EDUCATIONAL_EXPERIENCE`: Visita a museo, libro educativo.
            * `ONE_ON_ONE_TIME`: Tiempo exclusivo con un padre.
        * **Configuración para `LONG_TERM_GOAL` (Gran Regalo):**
            * `longTermGoalConditions`: Objeto o mapa para definir las condiciones.
                * `type`: Enum (`pointsAverageOverPeriod`, `specificChallengesCompleted`, `cumulativePointsTotal`).
                * `pointsAverageTarget`: Int? (para `pointsAverageOverPeriod`).
                * `periodInDays`: Int? (ej: 365 para anual, para `pointsAverageOverPeriod`).
                * `requiredChallengeIds`: List<String>? (para `specificChallengesCompleted`).
                * `cumulativePointsTarget`: Int? (para `cumulativePointsTotal`).
            * Mecanismo de verificación (inicialmente podría ser manual por el padre, quien confirma que se cumplieron, o una función que el padre puede disparar para verificar).
        * Icono o imagen representativa (selección de una galería predefinida por la app o subida por el padre).
        * Posibilidad de marcar una recompensa como "Activa" o "Inactiva".
    * Editar/Eliminar recompensas existentes.
    * Ver un listado de todas las recompensas creadas para la familia.
* **Gestión de Canjes:**
    * Recibir notificaciones (si se configuran) cuando una recompensa está lista para aprobación (sea por simulación de solicitud o preparación para futura UI del niño).
    * Acceder a una lista de recompensas pendientes de aprobación/entrega.
    * Aprobar o denegar la recompensa (con opción de añadir una nota).
    * Al aprobar, los puntos se descuentan automáticamente del saldo del niño.
* **Visualización y Ajuste de Puntos del Niño:**
    * Ver el saldo de puntos actual de cada niño.
    * Posibilidad de añadir o restar puntos manualmente a un niño con una justificación obligatoria (registrada en un log).
* **Historial de Recompensas:**
    * Ver un historial de recompensas canjeadas/otorgadas por cada niño (qué, cuándo, coste).

### 4.2. Niño (Lógica y modelos a implementar en esta fase; UI/UX en fase futura)

* **Acumulación de Puntos:**
    * El saldo de puntos (`currentPoints` en `Child` model) se actualiza automáticamente al completar desafíos con puntos asignados.
* **Lógica de Canje (Backend):**
    * Capacidad de que una recompensa se asocie a un niño con estado "pendiente de aprobación" o "canjeada", descontando puntos si aplica.
* **Notificaciones (Backend/Lógica):**
    * Generación de eventos de notificación (puntos ganados, recompensa aprobada/denegada) que podrán ser consumidos por la UI del niño en el futuro.

## 5. Flujo de Usuario (Enfoque en el Padre para esta fase, con lógica subyacente para el Niño)

### 5.1. Padre Configura Recompensas y Puntos por Desafío
1.  El padre navega a la sección "Desafíos".
2.  Crea un nuevo desafío (o edita uno existente) y le asigna 100 puntos.
3.  El padre navega a la sección "Recompensas" (en su panel de administración).
4.  Elige añadir una recompensa predefinida "30 min de TV extra" (tipo `PREDEFINED_PRIVILEGE`), ajusta el coste a 500 puntos y la activa.
5.  Crea una recompensa personalizada "Acampada de fin de semana" (tipo `LONG_TERM_GOAL`), coste 10000 puntos, y define la condición: `cumulativePointsTarget: 10000`.
6.  Crea una "Caja Sorpresa Semanal" (tipo `SURPRISE`), coste 200 puntos. En la descripción (visible para él) anota "Vale por un helado doble".

### 5.2. Niño Gana Puntos y Padre Gestiona "Canje" (Simulación o preparación para futura UI del niño)
1.  El niño completa un desafío.
2.  El padre evalúa el desafío como "Completado".
3.  El sistema automáticamente otorga 100 puntos al niño. El padre puede ver el saldo actualizado del niño en el panel de gestión. (Futuro: Niño recibe notificación visual/sonora).
4.  El niño acumula 550 puntos. El padre, hablando con el niño, acuerda que quiere la "30 min de TV extra".
5.  El padre, desde su panel, busca la recompensa "30 min de TV extra" para el niño y la marca como "Canjear/Aprobar".
6.  Los 500 puntos se descuentan del saldo del niño.
7.  La recompensa aparece en el historial de recompensas del niño. (Futuro: Niño recibe notificación "¡Tu recompensa ha sido aprobada!").

## 6. Modelo de Datos (Entidades Propuestas y/o Actualizaciones)

### 6.1. Nueva Entidad: `Reward`
* `id`: String (autogenerado, único)
* `familyId`: String (FK a `Family`)
* `name`: String (Nombre visible para el niño y el padre)
* `description`: String? (Detalles. Para `SURPRISE`, esta es la descripción oculta inicialmente para el niño)
* `pointsRequired`: int
* `type`: Enum `RewardType` { `PREDEFINED_PRIVILEGE`, `CUSTOM_PRIVILEGE`, `PREDEFINED_FAMILY_ACTIVITY`, `CUSTOM_FAMILY_ACTIVITY`, `PREDEFINED_SMALL_GIFT`, `CUSTOM_SMALL_GIFT`, `SURPRISE`, `LONG_TERM_GOAL`, `DIGITAL_APP_UNLOCK`, `CHARITABLE_DONATION`, `EDUCATIONAL_EXPERIENCE`, `ONE_ON_ONE_TIME` }
* `predefinedId`: String? (Si es una recompensa de la biblioteca de la app, para tracking y posibles actualizaciones globales)
* `longTermGoalConditions`: Map<String, dynamic>? (Almacena las condiciones específicas si `type` es `LONG_TERM_GOAL`. Ver punto 4.1)
    * Ej: `{ "conditionType": "cumulativePointsTotal", "targetValue": 10000 }`
    * Ej: `{ "conditionType": "pointsAverageOverPeriod", "targetValue": 50, "periodDays": 365 }`
* `iconUrl`: String? (URL a un icono predefinido de la app)
* `customImageUrl`: String? (URL si el padre subió una imagen personalizada por el padre)
* `isEnabled`: bool (default: true)
* `isArchived`: bool (default: false, para recompensas `LONG_TERM_GOAL` ya conseguidas o abandonadas)
* `createdByParentId`: String (FK a `User` o `Parent`)
* `createdAt`: Timestamp
* `updatedAt`: Timestamp

### 6.2. Nueva Entidad: `RedeemedReward` (Registro de Canjes)
* `id`: String (autogenerado, único)
* `rewardId`: String (FK a `Reward`)
* `rewardSnapshot`: Map<String, dynamic> (Copia de los datos de la recompensa al momento del canje: `name`, `type`, `description` (revelada si era sorpresa), etc.)
* `childId`: String (FK a `Child`)
* `familyId`: String (FK a `Family`)
* `pointsSpent`: int
* `status`: Enum `RedemptionStatus` { `pendingApproval` (si se implementa un flujo de solicitud futuro), `approved` (padre la otorga/confirma), `denied` (si hubo solicitud y se niega), `redeemed` (confirmación final de entrega/disfrute) }
    * Para la fase actual, podría ir directamente a `approved` o `redeemed` por acción del padre.
* `requestedAt`: Timestamp? (si hay flujo de solicitud)
* `processedAt`: Timestamp (cuando el padre aprueba/deniega/otorga)
* `processedByParentId`: String (FK a `User` o `Parent` que procesó)
* `parentNotes`: String? (justificación si se deniega o nota adicional)

### 6.3. Actualización a Entidad `Child` (o `FamilyChildModel`)
* Añadir campo: `currentPoints`: int (default: 0)
* (Opcional futuro) `lifetimePoints`: int (para estadísticas o condiciones de `LONG_TERM_GOAL`)
* (Opcional futuro) `pointsLog`: List<Map<String, dynamic>> para rastrear cada ganancia/gasto de puntos. Ej: `[{ "timestamp": ..., "amount": 50, "reason": "challenge_completed", "challengeId": "xyz", "description": "Completó 'Hacer la cama'" }, { "timestamp": ..., "amount": -200, "reason": "reward_redeemed", "rewardId": "abc", "description": "Canjeó 'Caja Sorpresa'" }]` -> Esto podría ser una subcolección también.

### 6.4. Actualización a Entidad `Challenge` (o `ChallengeModel`)
* Añadir campo: `pointsAwarded`: int (default: 0 o un valor estándar para nuevos desafíos, no null)

### 6.5. Estructura para `PredefinedReward` (a definir, similar a `predefined_challenges.dart`)
* Lista de objetos `PredefinedReward` con `id`, `name_es`, `name_en`, `defaultPoints`, `type`, `defaultIconUrl`.

## 7. Integración con Módulos Existentes (Enfoque Padre para UI)

### 7.1. Módulo de Desafíos (`ChallengeController`, `ChallengeRepository`, `CreateEditChallengePage`)
* Al crear/editar un `Challenge`, permitir al padre establecer `pointsAwarded`.
* Cuando un `ChallengeExecution` se marca como completado, si `pointsAwarded > 0`:
    * Incrementar `child.currentPoints`. (Lógica en `ChallengeController` o un nuevo `PointController`).
    * (Lógica) Crear un evento/notificación interna para el niño (para futura UI).

### 7.2. Módulo de Perfiles de Niño (Vista del Padre)
* En la gestión de perfiles de niños por el padre (`ChildProfilesPage`, `EditChildProfilePage`), mostrar `child.currentPoints`.

### 7.3. Módulo de Notificaciones (Lógica principalmente)
* (Lógica) Generar notificaciones para el niño: Puntos ganados, recompensa aprobada/denegada (para futura UI).
* (UI Padre) Notificar a los padres sobre acciones relevantes si se define (ej: "Recordatorio: 'Gran Regalo' de Juanito está cerca de cumplirse").

### 7.4. Interfaz de Padres
* Añadir nueva sección/pestaña principal en el menú de navegación para "Recompensas".

### 7.5. Flujo de Evaluación de Desafíos (`BatchEvaluationPage`, `ChallengeEvaluationDialog`)
* Al marcar un desafío como completado, se debe disparar la lógica de otorgar puntos. El padre debe ver una confirmación o feedback de los puntos otorgados.

## 8. Consideraciones de Diseño (UI/UX) - Enfoque en el Padre

### 8.1. Para Padres
* **Eficiencia y Claridad:** Formularios intuitivos para crear/editar recompensas, especialmente los tipos más complejos como `LONG_TERM_GOAL`.
* **Control Total:** Gestión fácil de puntos (con logs de ajustes manuales), aprobación/gestión de recompensas.
* **Buena Visualización:** Listados claros de recompensas, historial de canjes por niño, saldo de puntos de cada niño.
* **Feedback:** Confirmaciones visuales al guardar recompensas, otorgar puntos, etc.

### 8.2. Para Niños (Lógica y Modelos)
* Aunque no haya UI, la lógica debe ser robusta. Considerar cómo se sentiría el niño al interactuar con esto en el futuro (justicia, claridad de reglas).

## 9. Ideas Adicionales Oportunas (Incorporadas o para Futuro)

* **9.1. Recompensas Predefinidas por la App:** **INCLUIDA EN ESTA FASE.**
* **9.2. Recompensas Sorpresa como tipo:** **INCLUIDA EN ESTA FASE.**
* **9.3. Justificación para Ajuste Manual de Puntos:** **INCLUIDA EN ESTA FASE** (campo obligatorio y log).
* **9.4. Sonidos y Animaciones (para UI futura del niño):** Mantener en mente, reutilizar `CelebrationAnimation` cuando aplique.
* **9.5. Límite de Canjes o "Enfriamiento":** (Futura mejora)
* **9.6. Wishlist para Niños:** (Futura mejora, UI Niño)
* **9.7. Historial detallado de Puntos (PointsLog):** Considerar para `Child` model (ver 6.3) para auditoría y futuras analíticas/condiciones.

## 10. Consideraciones Técnicas

### 10.1. Backend (Firebase Firestore)
* Nuevas colecciones: `rewards` (subcolección de `families` o colección raíz con `familyId`), `redeemedRewards`.
* (Opcional) Subcolección `pointsLog` bajo cada `child`.
* Actualizar documentos de `children` (`currentPoints`, etc.).
* Actualizar documentos de `challenges` (`pointsAwarded`).
* **Cloud Functions:**
    * Para lógica transaccional (descontar puntos, registrar canje).
    * (Futuro) Para evaluación periódica de `LONG_TERM_GOAL`.
    * (Futuro) Para enviar notificaciones push complejas.

### 10.2. Frontend (Flutter - GetX) - Enfoque Padres
* **Nuevos Controladores (GetX):**
    * `RewardManagementController` (o similar): Para la gestión completa de recompensas y puntos desde la perspectiva del padre.
* **Nuevos Repositorios y Datasources:** `RewardRepository`, `RewardRemoteDatasource`.
* **Nuevos Modelos:** `RewardModel`, `RedeemedRewardModel`, `PredefinedRewardModel`.
* **Nuevas Vistas/Páginas (Padres):**
    * Listado de recompensas de la familia.
    * Creación/Edición de recompensas (con lógica para diferentes tipos, incluyendo `LONG_TERM_GOAL` y `SURPRISE`).
    * Panel de gestión de puntos de niños (ver saldo, añadir/restar manualmente).
    * Historial de recompensas canjeadas por niño.
    * Selector de recompensas predefinidas.
* **Actualizar Vistas Existentes (Padres):** `CreateEditChallengePage` (añadir `pointsAwarded`), vistas de perfil de niño (mostrar puntos), evaluación de desafíos (integrar otorgamiento de puntos).

### 10.3. Seguridad (Firebase Rules)
* Padres: CRUD en `rewards` de su `familyId`, crear `redeemedRewards` para sus hijos, modificar `currentPoints` de sus hijos (idealmente vía Cloud Function tras validación).
* Niños (acceso futuro): Leer `rewards` de su `familyId`, leer sus `redeemedRewards`, leer sus `currentPoints`.

### 10.4. Traducciones
* Todas las nuevas etiquetas para la UI de padres.

## 11. Próximos Pasos Sugeridos

1.  **Validación Final de este Documento Funcional:** Por tu parte.
2.  **Diseño de UI/UX Detallado (Mockups) para las pantallas de Padres.**
3.  **Planificación Técnica Detallada:** Desglose de tareas, modelos de datos finales en Firebase, firma de métodos de controladores/repositorios.
4.  **Implementación por Fases (dentro de esta primera gran fase centrada en padres):**
    * Fase 1.A: Modelos de datos base. Lógica de puntos (ganar puntos por desafíos completados). CRUD básico de recompensas (tipos simples) por padres y visualización en panel de padres. Ajuste manual de puntos.
    * Fase 1.B: Implementación de tipos de recompensa complejos (`LONG_TERM_GOAL`, `SURPRISE`). Recompensas predefinidas.
    * Fase 1.C: Lógica de "canje" gestionada por padres. Historial de recompensas. Notificaciones para padres.
    * Fase 1.D: Refinamientos, pruebas exhaustivas de la lógica y UI de padres.