import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc
import 'package:news_app/blocs/news_channel/news_channel_bloc.dart'; // Import your NewsChannelBloc
import 'package:news_app/view_model/news_view_model.dart'; // Import your NewsViewModel
import 'package:news_app/view/splash_screen.dart'; // Keep your SplashScreen import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NewsChannelBloc>(
      create: (context) => NewsChannelBloc(
        newsViewModel: NewsViewModel(),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData( // Adding a basic theme based on your HomeScreen
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(
                centerTitle: true,
                color: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Colors.black,
                )
            )
        ),
        home: const SplashScreen(), // Your app still starts with SplashScreen
      ),
    );
  }
}