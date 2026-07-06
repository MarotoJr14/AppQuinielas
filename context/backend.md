C:.
│   .env
│   .gitignore
│   alembic.ini
│   docker-compose.yml
│   Dockerfile
│   entrypoint.sh
│   README.md
│   requirements.txt
│
├───alembic
│   │   env.py
│   │   README
│   │   script.py.mako
│   │
│   └───versions
│           0998c86903cb_initial_schema.py
│           3b2a7f4c1e2d_add_penalties_and_penalty_events.py
│           5a1c8d4f2b90_unique_match_field_datetime.py
│
├───app
│   │   main.py
│   │   __init__.py
│   │
│   ├───api
│   │   │   __init__.py
│   │   │
│   │   └───v1
│   │       │   api.py
│   │       │   deps.py
│   │       │   __init__.py
│   │       │
│   │       └───routes
│   │               audit_logs.py
│   │               auth.py
│   │               events.py
│   │               lineups.py
│   │               matches.py
│   │               players.py
│   │               player_stats.py
│   │               player_teams.py
│   │               teams.py
│   │               tournaments.py
│   │               users.py
│   │               user_tournaments.py
│   │
│   ├───core
│   │       config.py
│   │       security.py
│   │       __init__.py
│   │
│   ├───db
│   │       base.py
│   │       deps.py
│   │       session.py
│   │       __init__.py
│   │
│   ├───models
│   │       audit_log.py
│   │       enums.py
│   │       event.py
│   │       lineup.py
│   │       match.py
│   │       player.py
│   │       player_team.py
│   │       team.py
│   │       tournament.py
│   │       user.py
│   │       user_tournament.py
│   │       __init__.py
│   │
│   ├───repositories
│   │       audit_log_repository.py
│   │       event_repository.py
│   │       lineup_repository.py
│   │       match_repository.py
│   │       player_repository.py
│   │       player_team_repository.py
│   │       team_repository.py
│   │       tournament_repository.py
│   │       user_repository.py
│   │       user_tournament_repository.py
│   │       __init__.py
│   │
│   ├───schemas
│   │       audit_log_schema.py
│   │       auth_schema.py
│   │       event_schema.py
│   │       lineup_schema.py
│   │       match_schema.py
│   │       player_schema.py
│   │       player_team_schema.py
│   │       team_schema.py
│   │       tournament_schema.py
│   │       user_schema.py
│   │       user_tournament_schema.py
│   │       __init__.py
│   │   
│   │
│   ├───services
│   │       audit_log_service.py
│   │       auth_service.py
│   │       event_service.py
│   │       lineup_service.py
│   │       match_service.py
│   │       player_service.py
│   │       player_team_service.py
│   │       team_service.py
│   │       tournament_service.py
│   │       user_service.py
│   │       user_tournament_service.py
│   │       __init__.py
│   │
│   └───utils
│           tournament_guard.py
│           __init__.py
│
├───seed
│   │   seed_users.py
│   │   __init__.py
│   │
│   └───data-2026
│           futcup_plantilla_matches_octavos.json
│           futcup_plantilla_players_1aco.json
│           futcup_plantilla_players_1afi.json
│           futcup_plantilla_players_1asir.json
│           futcup_plantilla_players_1coi.json
│           futcup_plantilla_players_1gad.json
│           futcup_plantilla_players_1mkt.json
│           futcup_plantilla_players_1smra.json
│           futcup_plantilla_players_1smrb.json
│           futcup_plantilla_players_2acoa.json
│           futcup_plantilla_players_2acob.json
│           futcup_plantilla_players_2afi.json
│           futcup_plantilla_players_2asir.json
│           futcup_plantilla_players_2coi.json
│           futcup_plantilla_players_2lab.json
│           futcup_plantilla_players_2mkt.json
│           futcup_plantilla_players_2smra.json
│           futcup_plantilla_players_2smrb.json
│           futcup_plantilla_players_profes.json
│           futcup_plantilla_teams.json
│
└───tests