
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites_page.dart';

//------------------ Main ------------------------

void main() {
  runApp(const MyApp());
}

//------------------ App Root ------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DictionaryCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const DictionaryHome(),
      ),
    );
  }
}

//------------------ Dictionary Home ------------------------

class DictionaryHome extends StatefulWidget {
  const DictionaryHome({super.key});

  @override
  State<DictionaryHome> createState() => _DictionaryHomeState();
}

class _DictionaryHomeState extends State<DictionaryHome> {
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 120, 0, 141),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            children: const [
              TextSpan(
                text: 'D',
                style: TextStyle(
                  color: Color.fromARGB(255, 251, 249, 153),
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                ),
              ),
              TextSpan(text: 'ictionary'),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<DictionaryCubit>(),
                    child: Favorite(),
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 33,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                onChanged: (String value) async {
                  await context.read<DictionaryCubit>().search(value);
                },
                decoration: InputDecoration(
                  hintText: 'Enter a word to search...',
                  filled: true,
                  prefixIcon: IconButton(
                    onPressed: () {
                      context.read<DictionaryCubit>().saveWord(
                        textController.text,
                      );
                    },
                    icon: const Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.purple,
                    ),
                  ),
                  fillColor: Colors.white60,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              BlocBuilder<DictionaryCubit, DicotionaryState>(
                builder: (context, state) {
                  if (state is DicotionaryLoading) {
                    return const Center(child: CircularProgressIndicator());

                    } else if (state is DicotionaryFailure) {
                    return Center(
                      child: Text(
                        state.errorMessage,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 222, 0, 0),
                        ),
                      ),
                    );
                  } else if (state is DicotionarySuccess) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          InfoCard(
                            Info(
                              'Word',
                              state.word,
                              const Color.fromARGB(255, 253, 172, 211),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InfoCard(
                            Info(
                              'Meaning',
                              state.meaning,
                              const Color.fromARGB(255, 171, 216, 253),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InfoCard(
                            Info(
                              'Example',
                              state.example,
                              const Color.fromARGB(255, 200, 251, 169),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text(
                        "Search a word to get started",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//------------------ Cubit & States ------------------------

abstract class DicotionaryState {}

class DicotionaryInitial extends DicotionaryState {}

class DicotionaryLoading extends DicotionaryState {}

class DicotionarySuccess extends DicotionaryState {
  final String word;
  final String meaning;
  final String example;

  DicotionarySuccess(this.word, this.meaning, this.example);
}

class DicotionaryFailure extends DicotionaryState {
  final String errorMessage;

  DicotionaryFailure(this.errorMessage);
}

class Favoritwords extends DicotionaryState {
  final List<String> words;
  Favoritwords(this.words);
}

class DictionaryCubit extends Cubit<DicotionaryState> {
  final Dio dio = Dio();
  DictionaryCubit() : super(DicotionaryInitial());

  Future<void> search(String word) async {
    emit(DicotionaryLoading());

    try {
      final response = await dio.get(
        'https://api.dictionaryapi.dev/api/v2/entries/en/$word',
      );

      final data = response.data[0];
      final meaning =
          data['meanings'][0]['definitions'][0]['definition'] ??
          'No meaning found';
      final example =
          data['meanings'][0]['definitions'][0]['example'] ??
          'No example available';

      emit(DicotionarySuccess(word, meaning, example));
    } catch (e) {
      emit(DicotionaryFailure('word not found or error occurred'));
    }
  }

  Future<void> saveWord(String word) async {
    final pref = await SharedPreferences.getInstance();
    List<String> words = pref.getStringList('word') ?? [];
    if (!words.contains(word)) {
      words.add(word);
      await pref.setStringList('word', words);
    }
    emit(Favoritwords(words));
  }

  Future<List<String>> getWord() async {
    final pref = await SharedPreferences.getInstance();
    List<String> words = pref.getStringList('word') ?? [];
    emit(Favoritwords(words));
    return words;
  }
}

//------------------ InfoCard ------------------------

class InfoCard extends StatelessWidget {
  final Info info;

  const InfoCard(this.info, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        color: info.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color.fromARGB(255, 129, 129, 129).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            info.value,
            style: TextStyle(
              fontSize: 15,
              fontStyle: info.isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
} 