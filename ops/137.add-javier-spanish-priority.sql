-- @operation: custom migration
-- @entity: batch
-- @name: Add Javier Spanish Priority
-- @description: Preserve Javier's Profilarr v1 Spanish-friendly release preferences in PCD format.

-- BTM and BEN THE MEN are trusted Spanish-friendly sources, so they should no
-- longer trigger the upstream low-quality custom formats.
DELETE FROM custom_format_conditions
WHERE custom_format_name = 'LQ'
  AND name = 'BTM'
  AND type = 'release_group'
  AND arr_type = 'all'
  AND negate = 0
  AND required = 0;

DELETE FROM custom_format_conditions
WHERE custom_format_name = 'LQ (Release Title)'
  AND name = 'BEN THE MEN'
  AND type = 'release_title'
  AND arr_type = 'all'
  AND negate = 0
  AND required = 0;

-- BTM and BEN THE MEN already exist upstream. Add the remaining release-group
-- expressions and release-title fallbacks from the legacy custom database.
INSERT INTO regular_expressions (name, pattern, description)
VALUES ('BTM (Release Title)', '(?:^|[ ._-])BTM$', 'Release-title fallback for BTM');

INSERT INTO regular_expressions (name, pattern, description)
VALUES ('LatTeam', '^(LatTeam)$', 'LatTeam release group');

INSERT INTO regular_expressions (name, pattern, description)
VALUES ('LatTeam (Release Title)', '(?:^|[ ._-])LatTeam$', 'Release-title fallback for LatTeam');

INSERT INTO regular_expressions (name, pattern, description)
VALUES ('SyncTeam', '^(SyncTeam)$', 'SyncTeam release group');

INSERT INTO regular_expressions (name, pattern, description)
VALUES ('SyncTeam (Release Title)', '(?:^|[ ._-])SyncTeam$', 'Release-title fallback for SyncTeam');

INSERT INTO regular_expressions (name, pattern, description)
VALUES ('SMS', '^(SMS)$', 'SMS release group');

INSERT INTO regular_expressions (name, pattern, description)
VALUES ('SMS (Release Title)', '(?:^|[ ._-])SMS$', 'Release-title fallback for SMS');

INSERT INTO regular_expression_tags (regular_expression_name, tag_name)
VALUES ('BTM', 'Language');
INSERT INTO regular_expression_tags (regular_expression_name, tag_name)
VALUES ('BTM (Release Title)', 'Language');
INSERT INTO regular_expression_tags (regular_expression_name, tag_name)
VALUES ('BEN THE MEN', 'Language');
INSERT INTO regular_expression_tags (regular_expression_name, tag_name)
VALUES ('LatTeam', 'Language');
INSERT INTO regular_expression_tags (regular_expression_name, tag_name)
VALUES ('LatTeam (Release Title)', 'Language');
INSERT INTO regular_expression_tags (regular_expression_name, tag_name)
VALUES ('SyncTeam', 'Language');
INSERT INTO regular_expression_tags (regular_expression_name, tag_name)
VALUES ('SyncTeam (Release Title)', 'Language');
INSERT INTO regular_expression_tags (regular_expression_name, tag_name)
VALUES ('SMS', 'Language');
INSERT INTO regular_expression_tags (regular_expression_name, tag_name)
VALUES ('SMS (Release Title)', 'Language');

INSERT INTO custom_formats (name, description, include_in_rename)
VALUES (
  'Spanish Priority',
  'Custom priority for sources Javier trusts to include Spanish audio or Spanish-friendly releases.',
  0
);

INSERT INTO custom_format_tags (custom_format_name, tag_name)
VALUES ('Spanish Priority', 'Language');

INSERT INTO custom_format_conditions
  (custom_format_name, name, type, arr_type, negate, required)
VALUES
  ('Spanish Priority', 'BTM', 'release_group', 'all', 0, 0),
  ('Spanish Priority', 'BTM (Release Title)', 'release_title', 'all', 0, 0),
  ('Spanish Priority', 'BEN THE MEN', 'release_title', 'all', 0, 0),
  ('Spanish Priority', 'LatTeam', 'release_group', 'all', 0, 0),
  ('Spanish Priority', 'LatTeam (Release Title)', 'release_title', 'all', 0, 0),
  ('Spanish Priority', 'SyncTeam', 'release_group', 'all', 0, 0),
  ('Spanish Priority', 'SyncTeam (Release Title)', 'release_title', 'all', 0, 0),
  ('Spanish Priority', 'SMS', 'release_group', 'all', 0, 0),
  ('Spanish Priority', 'SMS (Release Title)', 'release_title', 'all', 0, 0);

INSERT INTO condition_patterns
  (custom_format_name, condition_name, regular_expression_name)
VALUES
  ('Spanish Priority', 'BTM', 'BTM'),
  ('Spanish Priority', 'BTM (Release Title)', 'BTM (Release Title)'),
  ('Spanish Priority', 'BEN THE MEN', 'BEN THE MEN'),
  ('Spanish Priority', 'LatTeam', 'LatTeam'),
  ('Spanish Priority', 'LatTeam (Release Title)', 'LatTeam (Release Title)'),
  ('Spanish Priority', 'SyncTeam', 'SyncTeam'),
  ('Spanish Priority', 'SyncTeam (Release Title)', 'SyncTeam (Release Title)'),
  ('Spanish Priority', 'SMS', 'SMS'),
  ('Spanish Priority', 'SMS (Release Title)', 'SMS (Release Title)');

-- The v1 fork gave Spanish Priority a score of 2000 in every Radarr and Sonarr
-- profile. Use the existing per-app mappings to reproduce that behavior.
INSERT INTO quality_profile_custom_formats
  (quality_profile_name, custom_format_name, arr_type, score)
SELECT DISTINCT quality_profile_name, 'Spanish Priority', arr_type, 2000
FROM quality_profile_custom_formats
WHERE arr_type IN ('radarr', 'sonarr');
