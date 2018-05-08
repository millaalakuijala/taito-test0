-- Verify taito_test0:user.table on pg

BEGIN;

SELECT id FROM example_user WHERE FALSE;

ROLLBACK;
