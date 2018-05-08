-- Revert taito_test0:file.table from pg

BEGIN;

DROP TABLE example_file;

COMMIT;
