
import 'package:flutter/material.dart';
import 'package:flutter_application_3/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'info.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

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
      ),

      body: Padding(
        padding: const EdgeInsets.all(18), // أو أي قيمة مناسبة
        child: BlocBuilder<DictionaryCubit, DicotionaryState>(
          builder: (context, state) {
            if (state is Favoritwords) {
              return ListView.builder(
                itemCount: state.words.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ), // مسافة بين الكروت
                    child: InfoCard(
                      Info(
                        'words',
                        state.words[index],
                        const Color.fromARGB(255, 252, 251, 167),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('no Favorite Words'));
            }
          },
        ),
      ),
    );
  }
}