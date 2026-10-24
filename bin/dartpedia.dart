import 'dart:io';

import 'package:command_runner/command_runner.dart';
import 'package:http/http.dart' as http;

const version = '0.0.1';

void main(List<String> arguments) {
  if (arguments.isEmpty || arguments.first == 'help') {
    printUsage();
  } else if (arguments.first == 'version') {
    print('Dartpedia CLI version $version');
  } else if (arguments.first == 'search') {
    // Ambil argument setelah 'search'
    final List<String>? inputArgs = arguments.length > 1
        ? arguments.sublist(1)
        : null;
    searchWikipedia(inputArgs);
  } else {
    printUsage();
  }
}

void printUsage() {
  print(
    "The following commands are valid: 'help', 'version', 'search <ARTICLE-TITLE>'",
  );
}

// The function is now async. This is essential because it will call getWikipediaArticle, which is an async function itself and will need to await its result.
void searchWikipedia(List<String>? arguments) async {
  final String articleTitle;

  // If the user didn't pass in arguments, request an article title.
  if (arguments == null || arguments.isEmpty) {
    print('Please provide an article title.');

    final inputFromStdIn = stdin.readLineSync();
    if (inputFromStdIn == null || inputFromStdIn.isEmpty) {
      print('No article title provided. Exiting.');
      return;
    }
    articleTitle = inputFromStdIn;
  } else {
    // Otherwise, join the arguments from [list] into a single string.
    articleTitle = arguments.join(' ');
  }

  print('Looking up articles about "$articleTitle". Please wait.');
  print('Here ya go!');
  final articleContent = await getWikipediaArticle(articleTitle);
  print(articleContent);
}

// This function will be async because network requests are asynchronous operations.
// The Future<String> return type indicates that this function will eventually produce a String result, but not immediately, because it's an asynchronous operation.
Future<String> getWikipediaArticle(String articleTitle) async {
  // Make the HTTP request
  final response = await http.get(
    Uri.https(
      'en.wikipedia.org', // Wikipedia API domain
      '/api/rest_v1/page/summary/$articleTitle', // API path for article summary
    ),
  );

  if (response.statusCode == 200) {
    return response.body;
  }

  // Return an error message if the request failed
  return 'Error: Failed to fetch article "$articleTitle". Status code: ${response.statusCode}';
}
