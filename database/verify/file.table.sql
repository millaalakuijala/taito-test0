-- Verify taito_test0:file.table on pg

BEGIN;

SELECT id FROM example_file WHERE FALSE;

ROLLBACK;
