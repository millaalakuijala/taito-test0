-- Revert taito_test0:fileCollection.alter from pg

BEGIN;

ALTER TABLE example_file DROP COLUMN collection;

COMMIT;
