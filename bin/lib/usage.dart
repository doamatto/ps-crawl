import 'package:args/args.dart';

// Shows the command usage when using the help flag
void printUsage(ArgParser parser) {
  print('');
  print('PrivacySpy Bot – Time to track some online privacy.');
  print('Licensed under the GNU General Public license (v3.0).');
  print(
    'Developed while stalking privacy policies by Matt Ronchetto (doamatto).',
  );
  print('Source: https://github.com/doamatto/privacyspy-bot');
  print('');
  print('=== === ===');
  print('');
  print(parser.usage);
}
