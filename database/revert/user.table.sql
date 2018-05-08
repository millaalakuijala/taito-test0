-- Revert taito_test0:user.table from pg

BEGIN;

DROP TABLE example_user;

COMMIT;
