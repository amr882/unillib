import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:unilib/keys.dart';

class AIRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GenerativeModel _model;

  AIRepository() {
    _model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: aiApiKey);
  }

  Future<String> fetchAndAnalyze(String docId) async {
    try {
      final doc = await _firestore.collection('data').doc(docId).get();
      if (!doc.exists) {
        throw Exception('Document not found in the database.');
      }

      final content = doc.data()?['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        throw Exception(
          'Found the document, but it has no content to analyze.',
        );
      }

      final prompt =
          'Summarize this database entry in 2 sentences.\n\n$content';

      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('The AI model returned an empty response.');
      }

      return response.text!;
    } on FirebaseException catch (e) {
      throw Exception('Database Error: ${e.message}');
    } on GenerativeAIException catch (e) {
      throw Exception('AI Quota Limit or Error: ${e.message}');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      throw Exception(msg);
    }
  }
}
