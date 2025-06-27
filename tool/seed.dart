import 'package:supabase/supabase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'seed_data.dart';

// WARNING: This script will delete all existing data in the 'blocks' and 'routines' tables.
// It is intended for development purposes only.

Future<void> main() async {
  final logger = Logger();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Get Supabase credentials from environment variables
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    logger.e('Error: SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env file');
    return;
  }

  // Initialize the client using the imported credentials
  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
  logger.i('Supabase client initialized.');

  try {
    // 1. Clear existing data (order matters due to foreign keys)
    logger.i('Deleting existing data...');
    // We use `is not null` as a filter to delete all rows, which is valid for UUID columns.
    await client.from('blocks').delete().not('id', 'is', null);
    await client.from('routines').delete().not('id', 'is', null);
    logger.i('Existing data deleted successfully.');

    // 2. Seed new data
    logger.i('Seeding new data...');
    for (final routineData in seedRoutines) {
      // The 'id' from the seed file is a human-readable slug. We remove it
      // and let the database generate the actual UUID primary key.
      routineData.remove('id');
      final blocks =
          routineData.remove('blocks') as List<Map<String, dynamic>>;

      // Insert the routine and select back the record to get the generated ID.
      final insertedRoutine = await client
          .from('routines')
          .insert(routineData)
          .select('id')
          .single();
      final newRoutineId = insertedRoutine['id'];

      logger.i('  -> Inserted routine: ${routineData['title']}');

      // Insert the blocks using the new database-generated routine ID.
      for (int i = 0; i < blocks.length; i++) {
        final blockData = blocks[i];
        blockData['routine_id'] = newRoutineId;
        blockData['block_order'] = i; // Add the order
        await client.from('blocks').insert(blockData);
      }
      logger.i('    - Inserted ${blocks.length} blocks.');
    }

    logger.i('\nDatabase seeding completed successfully!');
  } catch (error) {
    logger.e('\nAn error occurred during seeding:');
    logger.e(error);
  } finally {
    await client.dispose();
    logger.i('Supabase client disposed.');
  }
}