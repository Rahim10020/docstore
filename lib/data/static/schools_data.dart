import '../models/school.dart';
import '../models/department.dart';

final List<School> schoolsData = [
  School(
    id: 'epl',
    name: 'École Polytechnique de Lomé',
    shortName: 'EPL',
    imageAsset: 'assets/images/epl-logo.png',
    departments: [
      Department(
        id: 'gc',
        name: 'Génie Civil',
        levels: ['L1', 'L2', 'L3', 'M1', 'M2'],
        courseFolders: {
          // Exemple: 'Mathématiques': '1ABC123...',
          // Ajoutez les IDs de dossiers Google Drive ici
        },
      ),
      Department(
        id: 'ge',
        name: 'Génie Électrique',
        levels: ['L1', 'L2', 'L3', 'M1', 'M2'],
      ),
      Department(
        id: 'gl',
        name: 'Génie Logiciel',
        levels: ['L1', 'L2', 'L3', 'M1', 'M2'],
      ),
      // Ajoutez les autres départements ici
    ],
  ),
  // Ajoutez d'autres écoles si nécessaire
];

