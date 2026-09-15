import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'layers/functional/Partie/data/gateways/sauvegarde_partie_locale.dart';
import 'layers/functional/Partie/presentation/cubit/partie_cubit.dart';
import 'layers/functional/Partie/presentation/views/partie_view.dart';
import 'layers/technical/Persistance/preferences_partagees.dart';
import 'layers/technical/Theme/theme_atelier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ApplicationAtelier());
}

class ApplicationAtelier extends StatelessWidget {
  const ApplicationAtelier({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silicium & Cie',
      debugShowCheckedModeBanner: false,
      theme: ThemeAtelier.clair(),
      darkTheme: ThemeAtelier.sombre(),
      home: BlocProvider(
        create: (_) => PartieCubit(
          sauvegarde: SauvegardePartieLocale(PreferencesPartagees()),
        )..demarrer(),
        child: const PartieView(),
      ),
    );
  }
}
