-- Verify taito_test0:fileCollection.alter on pg

BEGIN;

SELECT collection FROM example_file WHERE FALSE;

ROLLBACK;
