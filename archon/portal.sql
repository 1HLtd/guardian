--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;
CREATE LANGUAGE plpgsql;

SET search_path = stats, pg_catalog;

ALTER TABLE ONLY stats.servers_traffic DROP CONSTRAINT server_id_fkey;
SET search_path = servers_history, pg_catalog;

ALTER TABLE ONLY servers_history.server_delete_reasons DROP CONSTRAINT history_id_fkey;
ALTER TABLE ONLY servers_history.group_delete_reasons DROP CONSTRAINT history_id_fkey;
SET search_path = servers, pg_catalog;

ALTER TABLE ONLY servers.options DROP CONSTRAINT options_srv_id_fkey;
ALTER TABLE ONLY servers.options DROP CONSTRAINT options_group_id_fkey;
ALTER TABLE ONLY servers.lpr DROP CONSTRAINT lpr_servid_fkey;
ALTER TABLE ONLY servers.disk_usage DROP CONSTRAINT disk_usage_servid_fkey;
SET search_path = problems, pg_catalog;

ALTER TABLE ONLY problems.stats_24h DROP CONSTRAINT stats_24h_server_id_fkey;
ALTER TABLE ONLY problems.durations_24h DROP CONSTRAINT durations_24h_srv_id_fkey;
SET search_path = monitoring, pg_catalog;

ALTER TABLE ONLY monitoring.srv_status DROP CONSTRAINT status_server_id_fkey;
SET search_path = servers, pg_catalog;

DROP TRIGGER lpr_history_trigger ON servers.lpr;
DROP TRIGGER log_history ON servers.groups;
DROP TRIGGER log_history ON servers.list;
SET search_path = monitoring, pg_catalog;

DROP TRIGGER update_lag ON monitoring.srv_status;
SET search_path = stats, pg_catalog;

DROP INDEX stats.servers_traffic_server_id_idx;
DROP INDEX stats.servers_traffic_date_idx;
SET search_path = servers, pg_catalog;

DROP INDEX servers.type;
DROP INDEX servers.server_index;
DROP INDEX servers."options.srv_id_index";
DROP INDEX servers."options.group_id_index";
DROP INDEX servers.lpr_servid_date;
DROP INDEX servers.lpr_servid;
DROP INDEX servers.lpr_date;
DROP INDEX servers.id;
DROP INDEX servers.group_enabled;
DROP INDEX servers.genabled;
SET search_path = problems, pg_catalog;

DROP INDEX problems.srv_id_index;
DROP INDEX problems.server_down_index;
DROP INDEX problems.problems_durations_archive_start_time_srv_id_idx;
DROP INDEX problems.problems_durations_archive_start_time_idx;
DROP INDEX problems.problems_durations_archive_srv_id_idx;
DROP INDEX problems.problems_durations_archive_date_idx;
DROP INDEX problems.durations_24h_date_idx;
DROP INDEX problems.down_id;
DROP INDEX problems.active_srv_down;
DROP INDEX problems.active_down;
SET search_path = monitoring, pg_catalog;

DROP INDEX monitoring.srv_srv_index;
SET search_path = hawk, pg_catalog;

DROP INDEX hawk.hourly_info_server_idx;
DROP INDEX hawk.hourly_info_failed_brutes_blocked_idx;
DROP INDEX hawk.hourly_info_date_idx;
SET search_path = stats, pg_catalog;

ALTER TABLE ONLY stats.servers_traffic DROP CONSTRAINT date_server_id_ukey;
SET search_path = servers_history, pg_catalog;

ALTER TABLE ONLY servers_history.server_delete_reasons DROP CONSTRAINT server_delete_reasons_pkey;
ALTER TABLE ONLY servers_history.list DROP CONSTRAINT list_pkey;
ALTER TABLE ONLY servers_history.groups DROP CONSTRAINT groups_pkey;
ALTER TABLE ONLY servers_history.group_delete_reasons DROP CONSTRAINT group_delete_reasons_pkey;
SET search_path = servers, pg_catalog;

ALTER TABLE ONLY servers.options DROP CONSTRAINT options_pkey;
ALTER TABLE ONLY servers.lpr_history DROP CONSTRAINT lpr_history_pkey;
ALTER TABLE ONLY servers.list DROP CONSTRAINT list_server_id;
ALTER TABLE ONLY servers.list DROP CONSTRAINT list_pkey;
ALTER TABLE ONLY servers.list DROP CONSTRAINT list_id;
ALTER TABLE ONLY servers.groups DROP CONSTRAINT groups_pkey;
SET search_path = problems, pg_catalog;

ALTER TABLE ONLY problems.service_downs DROP CONSTRAINT service_downs_pkey;
ALTER TABLE ONLY problems.problems_durations_archive DROP CONSTRAINT problems_durations_archive_pkey;
ALTER TABLE ONLY problems.stats_24h DROP CONSTRAINT "24h_stats_pkey";
SET search_path = monitoring, pg_catalog;

ALTER TABLE ONLY monitoring.svc_status DROP CONSTRAINT svc_status_server_id_key;
ALTER TABLE ONLY monitoring.svc_status DROP CONSTRAINT services_status_pkey;
ALTER TABLE ONLY monitoring.lags DROP CONSTRAINT lags_pkey;
SET search_path = hawk, pg_catalog;

ALTER TABLE ONLY hawk.hourly_info DROP CONSTRAINT hourly_info_date_server_ukey;
SET search_path = cpustats, pg_catalog;

ALTER TABLE ONLY cpustats.user_stats DROP CONSTRAINT user_stats_server_key;
ALTER TABLE ONLY cpustats.cpu_stats DROP CONSTRAINT cpu_stats_date_key;
SET search_path = servers_history, pg_catalog;

ALTER TABLE servers_history.list ALTER COLUMN h_id DROP DEFAULT;
ALTER TABLE servers_history.groups ALTER COLUMN h_id DROP DEFAULT;
SET search_path = servers, pg_catalog;

ALTER TABLE servers.lpr_history ALTER COLUMN id DROP DEFAULT;
ALTER TABLE servers.list ALTER COLUMN id DROP DEFAULT;
ALTER TABLE servers.groups ALTER COLUMN id DROP DEFAULT;
SET search_path = problems, pg_catalog;

ALTER TABLE problems.stats_24h ALTER COLUMN id DROP DEFAULT;
ALTER TABLE problems.durations_daily ALTER COLUMN id DROP DEFAULT;
ALTER TABLE problems.durations_24h ALTER COLUMN id DROP DEFAULT;
ALTER TABLE problems.daily_stats ALTER COLUMN id DROP DEFAULT;
SET search_path = monitoring, pg_catalog;

ALTER TABLE monitoring.svc_status ALTER COLUMN id DROP DEFAULT;
SET search_path = stats, pg_catalog;

DROP TABLE stats.servers_traffic;
SET search_path = servers_history, pg_catalog;

DROP TABLE servers_history.server_delete_reasons;
DROP SEQUENCE servers_history.list_h_id_seq;
DROP TABLE servers_history.list;
DROP TABLE servers_history.internal_reasons_table;
DROP SEQUENCE servers_history.groups_h_id_seq;
DROP TABLE servers_history.groups;
DROP TABLE servers_history.group_delete_reasons;
SET search_path = servers, pg_catalog;

DROP VIEW servers.show_servers_with_options;
DROP VIEW servers.show_groups_with_server_counts;
DROP VIEW servers.server_options_and_properties;
DROP SEQUENCE servers.lpr_history_id_seq;
DROP TABLE servers.lpr_history;
DROP TABLE servers.lpr;
DROP SEQUENCE servers.list_id_seq;
DROP SEQUENCE servers.groups_id_seq;
DROP TABLE servers.disk_usage;
SET search_path = quotastats, pg_catalog;

DROP VIEW quotastats.user_min_max_values;
DROP TABLE quotastats.user_usage;
DROP VIEW quotastats.disk_min_max_values;
DROP TABLE quotastats.disk_usage;
SET search_path = problems, pg_catalog;

DROP VIEW problems.show_old_downs_local;
DROP VIEW problems.show_old_downs_by_date_server_group_and_type;
DROP VIEW problems.show_old_downs_by_date_server_and_type;
DROP VIEW problems.show_old_downs_by_date_and_server;
DROP VIEW problems.show_old_downs;
DROP VIEW problems.show_last24h_downs_local;
DROP VIEW problems."show_last24h_downs_by_server_id_OLD";
DROP VIEW problems.show_last24h_downs_by_server_id;
DROP VIEW problems.show_last24h_downs_by_server_group_and_type;
DROP VIEW problems.show_last24h_downs_by_server_and_type;
DROP VIEW problems.show_last24h_downs_by_server;
DROP VIEW problems.show_last24h_downs;
DROP VIEW problems.show_downtimes;
DROP VIEW problems.show_downs_without_comments;
DROP VIEW problems.show_active_durations_with_server_group;
DROP VIEW problems.show_active_durations;
DROP VIEW problems.show_active_downs;
DROP TABLE problems.service_downs;
DROP TABLE problems.problems_durations_archive;
DROP SEQUENCE problems.dur_24h_id_seq;
DROP SEQUENCE problems.daily_stats_id_seq;
DROP TABLE problems.daily_stats;
DROP SEQUENCE problems.daily_dur_id_seq;
DROP TABLE problems.durations_daily;
DROP SEQUENCE problems."24h_stats_id_seq";
DROP TABLE problems.stats_24h;
SET search_path = monitoring, pg_catalog;

DROP VIEW monitoring.show_problems2;
DROP VIEW monitoring.show_problems;
SET search_path = problems, pg_catalog;

DROP TABLE problems.durations_24h;
SET search_path = monitoring, pg_catalog;

DROP VIEW monitoring.show_lags;
DROP VIEW monitoring.sg_statuses2;
DROP VIEW monitoring.sg_statuses;
DROP TABLE monitoring.srv_status;
DROP SEQUENCE monitoring.services_status_id_seq;
DROP TABLE monitoring.svc_status;
DROP VIEW monitoring.servers;
SET search_path = servers, pg_catalog;

DROP TABLE servers.options;
DROP TABLE servers.groups;
SET search_path = monitoring, pg_catalog;

DROP TABLE monitoring.lags;
SET search_path = hawk, pg_catalog;

DROP VIEW hawk.stats_all_servers;
DROP VIEW hawk.daily_min_max_values;
DROP TABLE hawk.hourly_info;
SET search_path = cpustats, pg_catalog;

DROP VIEW cpustats.user_min_max_values;
DROP TABLE cpustats.user_stats;
DROP VIEW cpustats.daily_min_max_values;
SET search_path = servers, pg_catalog;

DROP TABLE servers.list;
SET search_path = cpustats, pg_catalog;

DROP TABLE cpustats.cpu_stats;
SET search_path = servers, pg_catalog;

DROP FUNCTION servers.update_machine(machine_id integer, rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, srv_whm text, r_ip inet, r_user character varying, r_pass character varying);
DROP FUNCTION servers.save_sg_id(srv_name text, sg_id integer, ns1name text, ns1ip inet, ns2name text, ns2ip inet, srv_type text);
DROP FUNCTION servers.maintain_list_hstory();
DROP FUNCTION servers.maintain_groups_history();
DROP FUNCTION servers.lpr_history();
DROP FUNCTION servers.insert_server(name character varying, ip_addr inet, grp_id integer, disabled_svcs integer[]);
DROP FUNCTION servers.insert_machine(rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, r_ip inet, r_user character varying, r_pass character varying);
DROP FUNCTION servers.import_server(grp_id integer, srv_name character varying, srv_ip inet, is_enabled boolean, srv_backup_type integer, srv_type integer, srv_s_id integer, disabled_svcs integer[]);
DROP FUNCTION servers.import_group(group_name character varying, group_description text, is_enabled boolean, disabled_svcs integer[]);
DROP FUNCTION servers.enabled_groups();
DROP FUNCTION servers.delete_server(srv_ids integer[], reason text);
DROP FUNCTION servers.delete_group(group_ids integer[], reason text);
SET search_path = problems, pg_catalog;

DROP FUNCTION problems.service_downs_last24h(search_date date, server_groups integer[]);
DROP FUNCTION problems.new_down(d_type integer, server_id integer, comment text, svc_list integer[]);
DROP FUNCTION problems.get_server_type_averages(search_date date, server_groups integer[], page_start integer, page_limit integer, searched_server character varying, sort_column character varying);
DROP FUNCTION problems.end_down(srv integer);
DROP FUNCTION problems.create_problems_durations_archive();
DROP FUNCTION problems.create_default_problems_archive();
DROP FUNCTION problems.comment_down(down_id integer, comment text);
DROP FUNCTION problems.average_service_downs_last24h(search_date date, server_groups integer[]);
SET search_path = monitoring, pg_catalog;

DROP FUNCTION monitoring.update_server_status(srv_status integer, srv_lag integer, srv_load double precision, srv_procs integer, srv_queue integer, srerver_id integer);
DROP FUNCTION monitoring.populate_missing();
DROP FUNCTION monitoring.new_server(sid integer);
DROP FUNCTION monitoring.disable_server(server integer);
DROP FUNCTION monitoring.clear_status();
DROP FUNCTION monitoring.calc_delay();
SET search_path = public, pg_catalog;

DROP TYPE public.service_count_time;
DROP TYPE public.service_average;
DROP TYPE public.server_type_average;
SET search_path = problems, pg_catalog;

DROP TYPE problems.service_count_time;
DROP TYPE problems.service_average;
DROP TYPE problems.server_type_average;
DROP PROCEDURAL LANGUAGE plpgsql;
DROP SCHEMA stats;
DROP SCHEMA servers_history;
DROP SCHEMA servers;
DROP SCHEMA quotastats;
DROP SCHEMA public;
DROP SCHEMA problems;
DROP SCHEMA monitoring;
DROP SCHEMA hawk;
DROP SCHEMA cpustats;
--
-- Name: cpustats; Type: SCHEMA; Schema: -; Owner: portal
--

CREATE SCHEMA cpustats;


ALTER SCHEMA cpustats OWNER TO portal;

--
-- Name: SCHEMA cpustats; Type: COMMENT; Schema: -; Owner: portal
--

COMMENT ON SCHEMA cpustats IS 'CPUStats master schema';


--
-- Name: hawk; Type: SCHEMA; Schema: -; Owner: portal
--

CREATE SCHEMA hawk;


ALTER SCHEMA hawk OWNER TO portal;

--
-- Name: SCHEMA hawk; Type: COMMENT; Schema: -; Owner: portal
--

COMMENT ON SCHEMA hawk IS 'Hawk Master database';


--
-- Name: monitoring; Type: SCHEMA; Schema: -; Owner: portal
--

CREATE SCHEMA monitoring;


ALTER SCHEMA monitoring OWNER TO portal;

--
-- Name: SCHEMA monitoring; Type: COMMENT; Schema: -; Owner: portal
--

COMMENT ON SCHEMA monitoring IS 'All monitoring information is kept here';


--
-- Name: problems; Type: SCHEMA; Schema: -; Owner: portal
--

CREATE SCHEMA problems;


ALTER SCHEMA problems OWNER TO portal;

--
-- Name: SCHEMA problems; Type: COMMENT; Schema: -; Owner: portal
--

COMMENT ON SCHEMA problems IS 'Statistics of problems(timeouts,service downs, etc.)';


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: portal
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO portal;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: portal
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: quotastats; Type: SCHEMA; Schema: -; Owner: portal
--

CREATE SCHEMA quotastats;


ALTER SCHEMA quotastats OWNER TO portal;

--
-- Name: SCHEMA quotastats; Type: COMMENT; Schema: -; Owner: portal
--

COMMENT ON SCHEMA quotastats IS 'QuotaStats Master database';


--
-- Name: servers; Type: SCHEMA; Schema: -; Owner: portal
--

CREATE SCHEMA servers;


ALTER SCHEMA servers OWNER TO portal;

--
-- Name: servers_history; Type: SCHEMA; Schema: -; Owner: portal
--

CREATE SCHEMA servers_history;


ALTER SCHEMA servers_history OWNER TO portal;

--
-- Name: SCHEMA servers_history; Type: COMMENT; Schema: -; Owner: portal
--

COMMENT ON SCHEMA servers_history IS 'Contains the history for the servers schema.';


--
-- Name: stats; Type: SCHEMA; Schema: -; Owner: portal
--

CREATE SCHEMA stats;


ALTER SCHEMA stats OWNER TO portal;

--
-- Name: SCHEMA stats; Type: COMMENT; Schema: -; Owner: portal
--

COMMENT ON SCHEMA stats IS 'Contains various statistics.';


--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: portal
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO portal;

SET search_path = problems, pg_catalog;

--
-- Name: server_type_average; Type: TYPE; Schema: problems; Owner: portal
--

CREATE TYPE server_type_average AS (
	server character varying(30),
	type integer,
	average double precision
);


ALTER TYPE problems.server_type_average OWNER TO portal;

--
-- Name: service_average; Type: TYPE; Schema: problems; Owner: portal
--

CREATE TYPE service_average AS (
	svc_id integer,
	average double precision
);


ALTER TYPE problems.service_average OWNER TO portal;

--
-- Name: service_count_time; Type: TYPE; Schema: problems; Owner: portal
--

CREATE TYPE service_count_time AS (
	svc_id integer,
	count integer,
	total_time integer
);


ALTER TYPE problems.service_count_time OWNER TO portal;

SET search_path = public, pg_catalog;

--
-- Name: server_type_average; Type: TYPE; Schema: public; Owner: portal
--

CREATE TYPE server_type_average AS (
	server character varying(30),
	type integer,
	average double precision
);


ALTER TYPE public.server_type_average OWNER TO portal;

--
-- Name: service_average; Type: TYPE; Schema: public; Owner: portal
--

CREATE TYPE service_average AS (
	svc_id integer,
	average double precision
);


ALTER TYPE public.service_average OWNER TO portal;

--
-- Name: service_count_time; Type: TYPE; Schema: public; Owner: portal
--

CREATE TYPE service_count_time AS (
	svc_id integer,
	count integer,
	total_time integer
);


ALTER TYPE public.service_count_time OWNER TO portal;

SET search_path = monitoring, pg_catalog;

--
-- Name: calc_delay(); Type: FUNCTION; Schema: monitoring; Owner: portal
--

CREATE FUNCTION calc_delay() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
  -- update the lag into ito the lags table
  UPDATE monitoring.lags SET lag = round(date_part('epoch', NEW.last_updated)-date_part('epoch',OLD.last_updated)) WHERE srv_id = NEW.srv_id;
  RETURN NEW;
END$$;


ALTER FUNCTION monitoring.calc_delay() OWNER TO portal;

--
-- Name: clear_status(); Type: FUNCTION; Schema: monitoring; Owner: portal
--

CREATE FUNCTION clear_status() RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
    i int;
    sid int;
BEGIN
    -- Truncating current tables
    DELETE FROM monitoring.svc_status;
    DELETE FROM monitoring.srv_status;

    -- Populate svc & srv status tables
    FOR sid IN SELECT id FROM servers.list LOOP
    SELECT INTO i nextval('monitoring.services_status_id_seq');
    INSERT INTO monitoring.svc_status ( srv_id, id ) VALUES ( sid, i );
--  INSERT INTO monitoring.svc_status ( srv_id ) VALUES ( sid );
    INSERT INTO monitoring.srv_status ( srv_id ) VALUES ( sid );
    END LOOP;
END;
$$;


ALTER FUNCTION monitoring.clear_status() OWNER TO portal;

--
-- Name: FUNCTION clear_status(); Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON FUNCTION clear_status() IS 'Reinitialize svc & srv status tables';


--
-- Name: disable_server(integer); Type: FUNCTION; Schema: monitoring; Owner: portal
--

CREATE FUNCTION disable_server(server integer) RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN
  UPDATE servers.options SET enabled=false WHERE srv_id = server;
  UPDATE monitoring.srv_status SET status=1, lag=0, "load"=0, mail_queue=0, proc_count=0 WHERE srv_id = server;
  PERFORM problems.end_down(server);
END;$$;


ALTER FUNCTION monitoring.disable_server(server integer) OWNER TO portal;

--
-- Name: new_server(integer); Type: FUNCTION; Schema: monitoring; Owner: portal
--

CREATE FUNCTION new_server(sid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
    i int;
    check_id int;
BEGIN
    SELECT id INTO check_id FROM servers.list WHERE id = sid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'server_id % not found', sid;
    END IF;
    SELECT srv_id INTO check_id FROM monitoring.srv_status WHERE srv_id = sid;
    IF NOT FOUND THEN
        -- Populate svc & srv status tables for the new server
        SELECT INTO i nextval('monitoring.services_status_id_seq');
        INSERT INTO monitoring.svc_status ( id, srv_id ) VALUES ( i, sid );
        -- INSERT INTO monitoring.srv_status ( srv_id, services_id ) VALUES ( sid, i );
        INSERT INTO monitoring.srv_status ( srv_id ) VALUES ( sid );
    END IF;
END;
$$;


ALTER FUNCTION monitoring.new_server(sid integer) OWNER TO portal;

--
-- Name: FUNCTION new_server(sid integer); Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON FUNCTION new_server(sid integer) IS 'Add a new server to the svc_status & srv_status';


--
-- Name: populate_missing(); Type: FUNCTION; Schema: monitoring; Owner: portal
--

CREATE FUNCTION populate_missing() RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
    i int;
    sid int;
BEGIN
    -- Populate svc & srv status tables with the missing servers
    FOR sid IN SELECT id FROM servers.list WHERE id NOT IN ( SELECT srv_id FROM monitoring.srv_status ORDER BY srv_id) LOOP
    SELECT INTO i nextval('monitoring.services_status_id_seq');
    INSERT INTO monitoring.svc_status ( id, srv_id ) VALUES ( i, sid );
    -- INSERT INTO monitoring.srv_status ( srv_id, services_id ) VALUES ( sid, i );
    INSERT INTO monitoring.srv_status ( srv_id ) VALUES ( sid);
    END LOOP;
END;$$;


ALTER FUNCTION monitoring.populate_missing() OWNER TO portal;

--
-- Name: FUNCTION populate_missing(); Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON FUNCTION populate_missing() IS 'Automatically populate missing servers into srv/svc_status tables';


--
-- Name: update_server_status(integer, integer, double precision, integer, integer, integer); Type: FUNCTION; Schema: monitoring; Owner: portal
--

CREATE FUNCTION update_server_status(srv_status integer, srv_lag integer, srv_load double precision, srv_procs integer, srv_queue integer, srerver_id integer) RETURNS void
    LANGUAGE plpgsql STRICT
    AS $$DECLARE
  last_update timestamp without time zone;
BEGIN
  SELECT last_updated INTO last_update FROM monitoring.srv_status WHERE srv_id = server_id;
  IF FOUND THEN
    UPDATE monitoring.lags SET lag = round(date_part('epoch', now())-date_part('epoch',last_update)) WHERE srv_id = server_id;
    UPDATE monitoring.srv_status SET status=srv_status, lag=srv_lag, load=srv_load, proc_count=srv_procs, mail_queue=srv_queue WHERE srv_id = server_id;
  END IF;
END
$$;


ALTER FUNCTION monitoring.update_server_status(srv_status integer, srv_lag integer, srv_load double precision, srv_procs integer, srv_queue integer, srerver_id integer) OWNER TO portal;

SET search_path = problems, pg_catalog;

--
-- Name: average_service_downs_last24h(date, integer[]); Type: FUNCTION; Schema: problems; Owner: portal
--

CREATE FUNCTION average_service_downs_last24h(search_date date, server_groups integer[]) RETURNS SETOF service_average
    LANGUAGE plpgsql
    AS $$DECLARE
    type_counts    integer[20];
    svcs           double precision[20];
    cnt            integer;
    i              integer;
    tmp            problems.service_average;
BEGIN
    type_counts = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}';
    cnt = 0;
    IF search_date >= now()::date THEN
        FOR svcs IN SELECT d.services FROM problems.durations_24h d, servers.options o WHERE d.start_time::date = search_date AND d.duration > 20 AND d."type"=2 AND d.srv_id = o.srv_id AND o.group_id = ANY(server_groups) LOOP
            FOR i IN COALESCE(array_lower(svcs, 1), 0)..COALESCE(array_upper(svcs, 1), -1) LOOP
               type_counts[svcs[i]+1]=type_counts[svcs[i]+1] + 1;
            END LOOP;
            cnt = cnt + 1;
        END LOOP;
    ELSE
        FOR svcs IN SELECT p.services FROM problems.problems_durations_archive p, servers.options o WHERE p.start_time::date = search_date AND p.duration > 20 AND p."type"=2 AND p.srv_id = o.srv_id AND o.group_id = ANY(server_groups) LOOP
            FOR i IN COALESCE(array_lower(svcs, 1), 0)..COALESCE(array_upper(svcs, 1), -1) LOOP
                type_counts[svcs[i]+1]=type_counts[svcs[i]+1] + 1;
            END LOOP;
            cnt = cnt + 1;
        END LOOP;

    END IF;

    FOR i IN 1..array_upper(type_counts, 1) LOOP
        tmp.svc_id = i-1;
        IF cnt > 0 THEN
            tmp.average = type_counts[i]/cnt::double precision;
        END IF;
        RETURN NEXT tmp;
    END LOOP;
    RETURN;
END$$;


ALTER FUNCTION problems.average_service_downs_last24h(search_date date, server_groups integer[]) OWNER TO portal;

--
-- Name: comment_down(integer, text); Type: FUNCTION; Schema: problems; Owner: portal
--

CREATE FUNCTION comment_down(down_id integer, comment text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE
    down    record;
BEGIN
    SELECT INTO down id, start_time, end_time, duration, type, description, srv_id, services, sys_comment FROM problems.durations_24h WHERE id = down_id;
    IF NOT found THEN
        RETURN false;
    END IF;
    IF down.start_time::date < now()::date AND down.end_time IS NOT NULL THEN
        --insert the down in history
        INSERT INTO problems.problems_durations_archive (id, duration, type, description, srv_id, services, sys_comment, start_time, end_time)
        VALUES (down.id, down.duration, down.type, comment, down.srv_id, down.services, down.sys_comment, down.start_time, down.end_time);
        -- delete the down
        DELETE FROM problems.durations_24h WHERE id = down_id;
    ELSE
        UPDATE problems.durations_24h SET description = comment WHERE id = down_id;
    END IF;
    RETURN true;
END$$;


ALTER FUNCTION problems.comment_down(down_id integer, comment text) OWNER TO portal;

--
-- Name: create_default_problems_archive(); Type: FUNCTION; Schema: problems; Owner: portal
--

CREATE FUNCTION create_default_problems_archive() RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
    problem_entry RECORD;
BEGIN
    -- Get all finished downs with comments
    FOR problem_entry in SELECT d.id, d.duration, d.type, d.description, d.srv_id, d.services, d.sys_comment, d.start_time, d.end_time FROM problems.durations_24h d, 
servers.options o WHERE d.end_time IS NOT NULL AND d.srv_id = o.srv_id LOOP
        -- Move the info from that down to the problems_durations_archive
        INSERT INTO
            problems.problems_durations_archive (id, duration, type, description, srv_id, services, sys_comment, start_time, end_time)
        VALUES
            (problem_entry.id, problem_entry.duration, problem_entry.type, problem_entry.description, problem_entry.srv_id, problem_entry.services, 
problem_entry.sys_comment, problem_entry.start_time, problem_entry.end_time);
        -- Remove this down from the problems.durations_24h table
        DELETE FROM
            problems.durations_24h
        WHERE
            id = problem_entry.id;
    END LOOP;
END;$$;


ALTER FUNCTION problems.create_default_problems_archive() OWNER TO portal;

--
-- Name: create_problems_durations_archive(); Type: FUNCTION; Schema: problems; Owner: portal
--

CREATE FUNCTION create_problems_durations_archive() RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
    problem_entry RECORD;
BEGIN
    -- Get all finished downs with comments
    -- Queryto za non empty DESC
    -- SELECT id, duration, type, description, srv_id, services, sys_comment, start_time, end_time FROM durations_24h WHERE end_time IS NOT NULL AND description IS NOT NULL
    -- FOR problem_entry in SELECT d.id, d.duration, d.type, d.description, d.srv_id, d.services, d.sys_comment, d.start_time, d.end_time FROM problems.durations_24h d, servers.options o WHERE d.end_time IS NOT NULL AND d.srv_id = o.srv_id AND (o.group_id NOT IN (1, 2) OR (d.description IS NOT NULL OR d.duration <= 30)) LOOP

    FOR problem_entry in SELECT d.id, d.duration, d.type, d.description, d.srv_id, d.services, d.sys_comment, d.start_time, d.end_time FROM problems.durations_24h d, servers.options o WHERE d.end_time IS NOT NULL AND d.srv_id = o.srv_id AND NOT ((d."type" = 0 OR d."type" = 2 AND ((0 = ANY (d.services)) OR (1 = ANY (d.services)) OR (19 = ANY (d.services)))) AND d.duration >= 60 AND (o.group_id = ANY (ARRAY[1, 2])) AND d.description IS NULL
) LOOP
        -- Move the info from that down to the problems_durations_archive
        INSERT INTO
            problems.problems_durations_archive (id, duration, type, description, srv_id, services, sys_comment, start_time, end_time)
        VALUES
            (problem_entry.id, problem_entry.duration, problem_entry.type, problem_entry.description, problem_entry.srv_id, problem_entry.services, problem_entry.sys_comment, problem_entry.start_time, problem_entry.end_time);
        -- Remove this down from the problems.durations_24h table
        DELETE FROM
            problems.durations_24h
        WHERE
            id = problem_entry.id;
    END LOOP;
END;
$$;


ALTER FUNCTION problems.create_problems_durations_archive() OWNER TO portal;

--
-- Name: FUNCTION create_problems_durations_archive(); Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON FUNCTION create_problems_durations_archive() IS 'Send all finished downs to archive.';


--
-- Name: end_down(integer); Type: FUNCTION; Schema: problems; Owner: portal
--

CREATE FUNCTION end_down(srv integer) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
  down_id int;
  dur int;
  start timestamp without time zone;
  d_type int;
BEGIN
  -- check if there is really a down
  SELECT id,start_time,type INTO down_id,start,d_type FROM problems.durations_24h WHERE srv_id = srv AND end_time IS NULL;
  IF FOUND THEN
    -- calculate the duration
    dur := round(date_part('epoch', now())-date_part('epoch', start));
    UPDATE problems.durations_24h SET end_time=now(), duration = dur WHERE id = down_id;
    -- update the daily_stats table
    PERFORM srv_id FROM problems.daily_stats WHERE srv_id = srv;
    IF FOUND THEN
      IF d_type = 0 THEN
        UPDATE problems.daily_stats SET timeout_downs = timeout_downs+1, timeout_time=timeout_time+dur WHERE srv_id = srv;
      ELSIF d_type = 1 THEN
        UPDATE problems.daily_stats SET allsvc_downs = allsvc_downs+1, allsvc_time=allsvc_time+dur WHERE srv_id = srv;
      ELSIF d_type = 2 THEN
        UPDATE problems.daily_stats SET service_downs = service_downs+1, service_time=service_time+dur WHERE srv_id = srv;
      END IF;
    ELSE
      IF d_type = 0 THEN
        INSERT INTO problems.daily_stats (srv_id,timeout_downs,timeout_time) VALUES (srv,1,dur);
      ELSIF d_type = 1 THEN
        INSERT INTO problems.daily_stats (srv_id,allsvc_downs,allsvc_time) VALUES (srv,1,dur);
      ELSIF d_type = 2 THEN
        INSERT INTO problems.daily_stats (srv_id,service_downs,service_time) VALUES (srv,1,dur);
      END IF;
    END IF;
  END IF;
END;$$;


ALTER FUNCTION problems.end_down(srv integer) OWNER TO portal;

--
-- Name: get_server_type_averages(date, integer[], integer, integer, character varying, character varying); Type: FUNCTION; Schema: problems; Owner: portal
--

CREATE FUNCTION get_server_type_averages(search_date date, server_groups integer[], page_start integer, page_limit integer, searched_server character varying, sort_column character varying) RETURNS SETOF server_type_average
    LANGUAGE plpgsql
    AS $$DECLARE
    all_downs     integer;
    tmp           problems.server_type_average;
    tmp_server    varchar(30);
    tmp_type      integer;
    tmp_count     integer;
BEGIN
    IF search_date >= now()::date THEN
        SELECT INTO all_downs SUM(count) FROM problems.show_last24h_downs_by_server_and_type WHERE server_group = ANY(server_groups);
        IF searched_server IS NULL THEN
            FOR tmp_server, tmp_type, tmp_count IN 
                EXECUTE 'SELECT server, type, count
                FROM problems.show_last24h_downs_by_server_and_type
                WHERE server_group = ANY(''{' || array_to_string(server_groups, ',') || '}'') ORDER BY ' || sort_column || ' OFFSET ' || page_start || ' LIMIT ' || page_limit LOOP
                    tmp.server = tmp_server;
                    tmp.type = tmp_type;
                    tmp.average = tmp_count::double precision / all_downs;
                    RETURN NEXT tmp;
            END LOOP;
        ELSE
            FOR tmp_server, tmp_type, tmp_count IN 
                EXECUTE 'SELECT server, type, count
                FROM problems.show_last24h_downs_by_server_and_type
                WHERE server_group = ANY(''{' || array_to_string(server_groups, ',') || '}'') AND server LIKE ''' || searched_server || '%'' ORDER BY ' || sort_column || ' OFFSET ' || page_start || ' LIMIT ' || page_limit LOOP
                    tmp.server = tmp_server;
                    tmp.type = tmp_type;
                    tmp.average = tmp_count::double precision / all_downs;
                    RETURN NEXT tmp;
            END LOOP;
        END IF;
    ELSE
        SELECT INTO all_downs SUM(count) FROM problems.show_old_downs_by_date_server_and_type WHERE server_group = ANY(server_groups) AND date = search_date;
        IF searched_server IS NULL THEN
            FOR tmp_server, tmp_type, tmp_count IN 
                EXECUTE 'SELECT server, type, count
                FROM problems.show_old_downs_by_date_server_and_type
                WHERE server_group = ANY(''{' || array_to_string(server_groups, ',') || '}'')  AND date = ''' || search_date || '''::date ORDER BY ' || sort_column || ' OFFSET ' || page_start || ' LIMIT ' || page_limit LOOP
                    tmp.server = tmp_server;
                    tmp.type = tmp_type;
                    tmp.average = tmp_count::double precision / all_downs;
                    RETURN NEXT tmp;
            END LOOP;
        ELSE
            FOR tmp_server, tmp_type, tmp_count IN 
                EXECUTE 'SELECT server, type, count
                FROM problems.show_old_downs_by_date_server_and_type
                WHERE server_group = ANY(''{' || array_to_string(server_groups, ',') || '}'')  AND date = ''' || search_date || '''::date AND server LIKE ''' || searched_server || '%'' ORDER BY ' || sort_column || ' OFFSET ' || page_start || ' LIMIT ' || page_limit LOOP
                    tmp.server = tmp_server;
                    tmp.type = tmp_type;
                    tmp.average = tmp_count::double precision / all_downs;
                    RETURN NEXT tmp;
            END LOOP;
        END IF;
    END IF;
END$$;


ALTER FUNCTION problems.get_server_type_averages(search_date date, server_groups integer[], page_start integer, page_limit integer, searched_server character varying, sort_column character varying) OWNER TO portal;

--
-- Name: new_down(integer, integer, text, integer[]); Type: FUNCTION; Schema: problems; Owner: portal
--

CREATE FUNCTION new_down(d_type integer, server_id integer, comment text, svc_list integer[]) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
  down_id int;
  my_type int;
BEGIN
  -- check if we already have an active down for this server
  -- and add the down only if there are no active downs
  SELECT id,type INTO down_id,my_type FROM problems.durations_24h WHERE srv_id = server_id AND end_time IS NULL;
  IF FOUND THEN
    -- do not update the down if it is of type timeout
    IF my_type != d_type AND my_type != 0 THEN
      UPDATE problems.durations_24h SET type=d_type, sys_comment=comment, services=svc_list WHERE id=down_id;
    END IF;
  ELSE
    INSERT INTO problems.durations_24h (type,srv_id,services,sys_comment) 
      VALUES (d_type,server_id,svc_list,comment);
  END IF;
END;$$;


ALTER FUNCTION problems.new_down(d_type integer, server_id integer, comment text, svc_list integer[]) OWNER TO portal;

--
-- Name: service_downs_last24h(date, integer[]); Type: FUNCTION; Schema: problems; Owner: portal
--

CREATE FUNCTION service_downs_last24h(search_date date, server_groups integer[]) RETURNS SETOF service_count_time
    LANGUAGE plpgsql
    AS $$DECLARE
    type_counts    integer[20];
    svcs           integer[20];
    total_times    integer[20];
    duration       integer;
    i              integer;
    tmp            problems.service_count_time;
BEGIN
    type_counts = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}';
    total_times = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}';

    IF search_date >= now()::date THEN
        FOR svcs, duration IN SELECT d.services, d.duration FROM problems.durations_24h d, servers.options o WHERE d.start_time::date = search_date AND d.duration > 20 AND d."type"=2 AND d.srv_id = o.srv_id AND o.group_id = ANY(server_groups) LOOP
            FOR i IN COALESCE(array_lower(svcs, 1), 0)..COALESCE(array_upper(svcs, 1), -1) LOOP
                type_counts[svcs[i]+1]=type_counts[svcs[i]+1] + 1;
                total_times[svcs[i]+1]=total_times[svcs[i]+1] + duration;
            END LOOP;
        END LOOP;
    ELSE
        FOR svcs, duration IN SELECT p.services, p.duration FROM problems.problems_durations_archive p, servers.options o WHERE p.start_time::date = search_date AND p.duration > 20 AND p."type"=2 AND p.srv_id = o.srv_id AND o.group_id = ANY(server_groups) LOOP
            FOR i IN COALESCE(array_lower(svcs, 1), 0)..COALESCE(array_upper(svcs, 1), -1) LOOP
                type_counts[svcs[i]+1]=type_counts[svcs[i]+1] + 1;
                total_times[svcs[i]+1]=total_times[svcs[i]+1] + duration;
            END LOOP;
        END LOOP;

    END IF;
    FOR i IN COALESCE(array_lower(type_counts, 1), 0)..COALESCE(array_upper(type_counts, 1), -1) LOOP
        tmp.svc_id = i-1;
        tmp.count = type_counts[i];
        tmp.total_time = total_times[i];
        RETURN NEXT tmp;
    END LOOP;
    RETURN;
END
$$;


ALTER FUNCTION problems.service_downs_last24h(search_date date, server_groups integer[]) OWNER TO portal;

SET search_path = servers, pg_catalog;

--
-- Name: delete_group(integer[], text); Type: FUNCTION; Schema: servers; Owner: portal
--

CREATE FUNCTION delete_group(group_ids integer[], reason text) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
    server_id    integer;
BEGIN
    UPDATE servers_history.internal_reasons_table SET group_reason = reason, server_reason = reason;
    FOR server_id IN SELECT srv_id FROM servers.options WHERE group_id = ANY(group_ids) LOOP
        DELETE FROM servers.list WHERE id = server_id;
    END LOOP;
    DELETE FROM servers.groups g WHERE g.id = ANY(group_ids);
    UPDATE servers_history.internal_reasons_table SET group_reason = NULL, server_reason = NULL;
END$$;


ALTER FUNCTION servers.delete_group(group_ids integer[], reason text) OWNER TO portal;

--
-- Name: delete_server(integer[], text); Type: FUNCTION; Schema: servers; Owner: portal
--

CREATE FUNCTION delete_server(srv_ids integer[], reason text) RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN
    UPDATE servers_history.internal_reasons_table SET server_reason = reason;
    DELETE FROM servers.list WHERE id = ANY(srv_ids);
    UPDATE servers_history.internal_reasons_table SET server_reason = NULL;
END$$;


ALTER FUNCTION servers.delete_server(srv_ids integer[], reason text) OWNER TO portal;

--
-- Name: enabled_groups(); Type: FUNCTION; Schema: servers; Owner: portal
--

CREATE FUNCTION enabled_groups() RETURNS integer[]
    LANGUAGE plpgsql
    AS $$DECLARE
  gid int;
  ret int[] := '{}';
BEGIN
  FOR gid IN SELECT id FROM servers.groups WHERE enabled LOOP
    ret = array_append(ret, gid);
  END LOOP;
  return ret;
END;$$;


ALTER FUNCTION servers.enabled_groups() OWNER TO portal;

--
-- Name: import_group(character varying, text, boolean, integer[]); Type: FUNCTION; Schema: servers; Owner: portal
--

CREATE FUNCTION import_group(group_name character varying, group_description text, is_enabled boolean, disabled_svcs integer[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
    tmp_id      integer;
    i           integer;
    tmp_name    varchar;
    new_name    varchar;
BEGIN
    SELECT INTO tmp_id nextval('servers.groups_id_seq'::regclass);
    SELECT INTO tmp_name name FROM servers.groups WHERE name=group_name;
    i := 1;
    new_name := group_name;
    WHILE FOUND LOOP
        new_name := group_name||'_'||i;
        SELECT INTO tmp_name name FROM servers.groups WHERE name = new_name;
        i := i + 1;
    END LOOP;
    INSERT INTO servers.groups(id, name, description, enabled, disabled_services) VALUES(tmp_id, new_name, group_description, is_enabled, disabled_svcs);
    RETURN tmp_id;
END;$$;


ALTER FUNCTION servers.import_group(group_name character varying, group_description text, is_enabled boolean, disabled_svcs integer[]) OWNER TO portal;

--
-- Name: import_server(integer, character varying, inet, boolean, integer, integer, integer, integer[]); Type: FUNCTION; Schema: servers; Owner: portal
--

CREATE FUNCTION import_server(grp_id integer, srv_name character varying, srv_ip inet, is_enabled boolean, srv_backup_type integer, srv_type integer, srv_s_id integer, disabled_svcs integer[]) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
    tmp_id     integer;
BEGIN
    SELECT INTO tmp_id nextval('servers.list_id_seq'::regclass);
    INSERT INTO servers.list(id, server, ip, type, s_id) VALUES (tmp_id, srv_name, srv_ip, srv_type, srv_s_id);
    INSERT INTO servers.options(srv_id, group_id, enabled, backup_type, disabled_services) VALUES(tmp_id, grp_id, is_enabled, srv_backup_type, disabled_svcs);
END;$$;


ALTER FUNCTION servers.import_server(grp_id integer, srv_name character varying, srv_ip inet, is_enabled boolean, srv_backup_type integer, srv_type integer, srv_s_id integer, disabled_svcs integer[]) OWNER TO portal;

--
-- Name: insert_machine(integer, integer, character varying, character varying, inet, character varying, inet, integer, integer, inet, character varying, character varying); Type: FUNCTION; Schema: servers; Owner: portal
--

CREATE FUNCTION insert_machine(rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, r_ip inet, r_user character varying, r_pass character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
	i int;
	check_id int;
	check_rid int;
BEGIN
	-- Check if the server exists
	SELECT id INTO check_id FROM servers.list WHERE server = server_name;
	IF FOUND THEN
		RAISE NOTICE 'RECORD already exist!';
	ELSE
		SELECT INTO i nextval('servers.list_id_seq');
		-- Insert into servers.list
		INSERT INTO servers.list ( id, server, ip ) VALUES ( i, server_name, ns1ip );
		-- Insert into Server Manager with corresponding type
		INSERT INTO sm.machines(r_id, id, slot_n, type, usb_encl) VALUES(rack_id, i, slot_num, srv_type, srv_usb);
		-- Insert primary IP into IP manager
		INSERT INTO sm.ips(m_id, ip_addr, domain, type_id) VALUES(i, ns1ip, ns1name, 1);
		-- Insert secondary IP into IP manager
		INSERT INTO sm.ips(m_id, ip_addr, domain, type_id) VALUES(i, ns2ip, ns2name, 18);
		-- Insert into servers.options
		INSERT INTO servers.options ( srv_id, backup_type, group_id, enabled, disabled_services ) VALUES ( i, srv_type, srv_type, true, '{16}' );
		-- Insert remote details
		SELECT r_id INTO check_rid FROM sm.remote_details WHERE r_id=rack_id AND slot_n=slot_num;
		IF NOT FOUND THEN
			INSERT INTO sm.remote_details (username, password, ip_addr, type, r_id, slot_n) VALUES (r_user, r_pass, r_ip, 1, rack_id, slot_num);
		END IF;
	END IF;
END;$$;


ALTER FUNCTION servers.insert_machine(rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, r_ip inet, r_user character varying, r_pass character varying) OWNER TO portal;

--
-- Name: insert_server(character varying, inet, integer, integer[]); Type: FUNCTION; Schema: servers; Owner: portal
--

CREATE FUNCTION insert_server(name character varying, ip_addr inet, grp_id integer, disabled_svcs integer[]) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
    server_id    integer;
BEGIN
    SELECT INTO server_id nextval('servers.list_id_seq'::regclass);
    INSERT INTO servers.list(id, server, ip) VALUES(server_id, name, ip_addr);
    INSERT INTO servers.options(srv_id, group_id, enabled, disabled_services) VALUES(server_id, grp_id, false, disabled_svcs);
END$$;


ALTER FUNCTION servers.insert_server(name character varying, ip_addr inet, grp_id integer, disabled_svcs integer[]) OWNER TO portal;

--
-- Name: lpr_history(); Type: FUNCTION; Schema: servers; Owner: portal
--

CREATE FUNCTION lpr_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	g_id integer;
	update_id integer;
BEGIN
	-- Clear old entries
	DELETE FROM servers.lpr_history WHERE from_date < now() - interval '6 months';
	SELECT INTO g_id group_id FROM servers.options WHERE srv_id=NEW.servid;
	SELECT INTO update_id h.id FROM servers.lpr_history h, servers.options o WHERE o.group_id=g_id AND o.srv_id=h.srv_id ORDER BY h.from_date DESC LIMIT 1;
	UPDATE servers.lpr_history SET to_date=now() WHERE id=update_id;
	INSERT INTO servers.lpr_history(srv_id, from_date) VALUES(NEW.servid, now());
	RETURN NEW;
END;$$;


ALTER FUNCTION servers.lpr_history() OWNER TO portal;

--
-- Name: maintain_groups_history(); Type: FUNCTION; Schema: servers; Owner: portal
--

CREATE FUNCTION maintain_groups_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
    delete_reason    text;
    next_id          integer;
BEGIN
-- if we are deleting we should
-- check the internal_reasons_table for the reason to delete the row and if there is a reason,
-- insert the reason into the group_delete_reasons table.
    IF TG_OP = 'DELETE' THEN
        SELECT INTO delete_reason group_reason FROM servers_history.internal_reasons_table;
        IF delete_reason IS NOT NULL THEN
            SELECT INTO next_id nextval('servers_history.groups_h_id_seq'::regclass);
            INSERT INTO servers_history.groups(h_id, id, name, description, enabled, disabled_services) VALUES (next_id, OLD.id, OLD.name, OLD.description, OLD.enabled, OLD.disabled_services);
            INSERT INTO servers_history.group_delete_reasons(h_id, comment) VALUES(next_id, delete_reason);
        ELSE
            INSERT INTO servers_history.groups(id, name, description, enabled, disabled_services) VALUES(OLD.id, OLD.name, OLD.description, OLD.enabled, OLD.disabled_services);
        END IF;
        RETURN OLD;
    END IF;

    INSERT INTO servers_history.groups(id, name, description, enabled, disabled_services) VALUES(OLD.id, OLD.name, OLD.description, OLD.enabled, OLD.disabled_services);
    RETURN NEW;
END$$;


ALTER FUNCTION servers.maintain_groups_history() OWNER TO portal;

--
-- Name: maintain_list_hstory(); Type: FUNCTION; Schema: servers; Owner: portal
--

CREATE FUNCTION maintain_list_hstory() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
    delete_reason    text;
    next_id          integer;
BEGIN
-- if we are deleting we should
-- check the internal_reasons_table for the reason to delete the row and if there is a reason,
-- insert the reason into the server_delete_reasons table.
    IF TG_OP = 'DELETE' THEN
        raise notice 'deleting';
        SELECT INTO delete_reason server_reason FROM servers_history.internal_reasons_table;
        IF delete_reason IS NOT NULL THEN
        raise notice 'found reason';
            SELECT INTO next_id nextval('servers_history.list_h_id_seq'::regclass);
            INSERT INTO servers_history.list(h_id, id, server, type, ip, s_id) VALUES(next_id, OLD.id, OLD.server, OLD.type, OLD.ip, OLD.s_id);
            INSERT INTO servers_history.server_delete_reasons(h_id, comment) VALUES(next_id, delete_reason);
        ELSE
            INSERT INTO servers_history.list(id, server, type, ip, s_id) VALUES(OLD.id, OLD.server, OLD.type, OLD.ip, OLD.s_id);
        END IF;
        RETURN OLD;
    END IF;

    INSERT INTO servers_history.list(id, server, type, ip, s_id) VALUES(OLD.id, OLD.server, OLD.type, OLD.ip, OLD.s_id);
    RETURN NEW;
END$$;


ALTER FUNCTION servers.maintain_list_hstory() OWNER TO portal;

--
-- Name: save_sg_id(text, integer, text, inet, text, inet, text); Type: FUNCTION; Schema: servers; Owner: portal
--

CREATE FUNCTION save_sg_id(srv_name text, sg_id integer, ns1name text, ns1ip inet, ns2name text, ns2ip inet, srv_type text) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
	i int;
	check_id int;
BEGIN
	-- Check if exists
	SELECT id INTO check_id FROM servers.list WHERE server = srv_name;
	IF FOUND THEN
		-- Update Server's ID and IP if needed
		UPDATE servers.list SET s_id = sg_id, ip = ns1ip WHERE server = srv_name;
	ELSE
		SELECT INTO i nextval('servers.list_id_seq');
		-- Insert into servers.list
		INSERT INTO servers.list ( id, server, s_id, ip ) VALUES ( i, srv_name, sg_id, ns1ip );
		IF srv_type = 'businesshosting' THEN
			-- Insert into options with corresponding Group ID
			INSERT INTO servers.options ( srv_id, backup_type, group_id, enabled ) VALUES ( i, 4, 2, true );
			-- Setting disabled for LPR system
			INSERT INTO sc.disabled(server_id) VALUES(i);
			-- Insert into Server Manager with corresponding type
			INSERT INTO sm.machines(r_id, id, slot_n, type) VALUES(21, i, 1, 2);
			-- Insert primary IP into IP manager
			INSERT INTO sm.ips(m_id, ip_addr, domain, type_id) VALUES(i, ns1ip, ns1name, 1);
			-- Insert secondary IP into IP manager
			INSERT INTO sm.ips(m_id, ip_addr, domain, type_id) VALUES(i, ns2ip, ns2name, 18);
		ELSIF srv_type = 'cloud' THEN
			INSERT INTO servers.options ( srv_id, backup_type, group_id, enabled ) VALUES ( i, 7, 7, true );
		ELSIF srv_type = 'dedicated' THEN
			INSERT INTO servers.options ( srv_id, backup_type, group_id, enabled ) VALUES ( i, 6, 4, true );
			INSERT INTO sm.machines(r_id, id, slot_n, type) VALUES(22, i, 1, 4);
			INSERT INTO sm.ips(m_id, ip_addr, domain, type_id) VALUES(i, ns1ip, ns1name, 1);
			INSERT INTO sm.ips(m_id, ip_addr, domain, type_id) VALUES(i, ns2ip, ns2name, 18);
		ELSE 
			INSERT INTO servers.options ( srv_id, backup_type, group_id, enabled ) VALUES ( i, 1, 1, true );
			INSERT INTO sc.disabled(server_id) VALUES(i);
			INSERT INTO sm.machines(r_id, id, slot_n, type) VALUES(24, i, 1, 1);
			INSERT INTO sm.ips(m_id, ip_addr, domain, type_id) VALUES(i, ns1ip, ns1name, 1);
			INSERT INTO sm.ips(m_id, ip_addr, domain, type_id) VALUES(i, ns2ip, ns2name, 18);
		END IF;
	END IF;
END;$$;


ALTER FUNCTION servers.save_sg_id(srv_name text, sg_id integer, ns1name text, ns1ip inet, ns2name text, ns2ip inet, srv_type text) OWNER TO portal;

--
-- Name: update_machine(integer, integer, integer, character varying, character varying, inet, character varying, inet, integer, integer, text, inet, character varying, character varying); Type: FUNCTION; Schema: servers; Owner: portal
--

CREATE FUNCTION update_machine(machine_id integer, rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, srv_whm text, r_ip inet, r_user character varying, r_pass character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
	i int;
	check_id int;
	remote_id int;
BEGIN
	-- Check if the server exists
	SELECT id INTO check_id FROM servers.list WHERE id = machine_id;
	IF FOUND THEN
		UPDATE sm.machines SET r_id = rack_id, slot_n = slot_num, type = srv_type, whm_key = srv_whm, usb_encl = srv_usb, last_updated = now() WHERE id = machine_id;
		UPDATE servers.list SET server = server_name, ip = ns1ip WHERE id = machine_id;
		UPDATE servers.options SET group_id = srv_type WHERE srv_id = machine_id;
		UPDATE sm.ips SET domain = ns1name, ip_addr = ns1ip WHERE m_id = machine_id AND type_id = 1;
		UPDATE sm.ips SET domain = ns2name, ip_addr = ns2ip WHERE m_id = machine_id AND type_id = 18;
		-- Check if remote details exists
		SELECT r_id INTO remote_id FROM sm.remote_details WHERE r_id = rack_id AND slot_n = slot_num;
		IF FOUND THEN
			UPDATE sm.remote_details SET username = r_user, password = r_pass , ip_addr = r_ip WHERE r_id = rack_id AND slot_n = slot_num;
		ELSE
			INSERT INTO sm.remote_details (username, password, ip_addr, type, r_id, slot_n) VALUES (r_user, r_pass, r_ip, 1, rack_id, slot_num);
		END IF;
	ELSE
		RAISE NOTICE 'RECORD NOT FOUND!';
	END IF;
END;$$;


ALTER FUNCTION servers.update_machine(machine_id integer, rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, srv_whm text, r_ip inet, r_user character varying, r_pass character varying) OWNER TO portal;

SET search_path = cpustats, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cpu_stats; Type: TABLE; Schema: cpustats; Owner: portal; Tablespace: 
--

CREATE TABLE cpu_stats (
    date timestamp without time zone,
    srv_id integer NOT NULL,
    realtime double precision DEFAULT 0 NOT NULL,
    usertime double precision DEFAULT 0 NOT NULL,
    systime double precision DEFAULT 0 NOT NULL,
    executions integer DEFAULT 0 NOT NULL,
    average double precision DEFAULT 0 NOT NULL,
    stype integer
);


ALTER TABLE cpustats.cpu_stats OWNER TO portal;

--
-- Name: TABLE cpu_stats; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON TABLE cpu_stats IS 'CPU Statistics';


--
-- Name: COLUMN cpu_stats.date; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN cpu_stats.date IS 'Date';


--
-- Name: COLUMN cpu_stats.srv_id; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN cpu_stats.srv_id IS 'Server ID';


--
-- Name: COLUMN cpu_stats.realtime; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN cpu_stats.realtime IS 'Realtime';


--
-- Name: COLUMN cpu_stats.usertime; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN cpu_stats.usertime IS 'Usertime';


--
-- Name: COLUMN cpu_stats.systime; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN cpu_stats.systime IS 'Systime';


--
-- Name: COLUMN cpu_stats.executions; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN cpu_stats.executions IS 'Executions';


--
-- Name: COLUMN cpu_stats.average; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN cpu_stats.average IS 'Average load';


SET search_path = servers, pg_catalog;

--
-- Name: list; Type: TABLE; Schema: servers; Owner: portal; Tablespace: 
--

CREATE TABLE list (
    id integer NOT NULL,
    server character varying(30) NOT NULL,
    type integer,
    ip inet NOT NULL,
    s_id integer
);


ALTER TABLE servers.list OWNER TO portal;

--
-- Name: TABLE list; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON TABLE list IS 'Server IDs, IPs and type';


--
-- Name: COLUMN list.server; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN list.server IS 'Server name';


--
-- Name: COLUMN list.type; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN list.type IS '1 - prd; 3 - disabled; 5 - big backup destination';


--
-- Name: COLUMN list.ip; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN list.ip IS 'Management IP of the machine';


--
-- Name: COLUMN list.s_id; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN list.s_id IS 'SG Server''s ID';


SET search_path = cpustats, pg_catalog;

--
-- Name: daily_min_max_values; Type: VIEW; Schema: cpustats; Owner: portal
--

CREATE VIEW daily_min_max_values AS
    SELECT l.server, min(s.realtime) AS min_real, max(s.realtime) AS max_real, min(s.usertime) AS min_user, max(s.usertime) AS max_user, min(s.executions) AS min_count, max(s.executions) AS max_count, min(s.systime) AS min_sys, max(s.systime) AS max_sys, sum(s.realtime) AS real_sum, sum(s.usertime) AS user_sum, sum(s.executions) AS count_sum, sum(s.systime) AS sys_sum, s.stype FROM cpu_stats s, servers.list l WHERE (s.srv_id = l.id) GROUP BY l.server, s.stype;


ALTER TABLE cpustats.daily_min_max_values OWNER TO portal;

--
-- Name: user_stats; Type: TABLE; Schema: cpustats; Owner: portal; Tablespace: 
--

CREATE TABLE user_stats (
    srv_id integer NOT NULL,
    username character varying NOT NULL,
    realtime double precision DEFAULT 0 NOT NULL,
    systime double precision DEFAULT 0 NOT NULL,
    executions integer DEFAULT 0 NOT NULL,
    average double precision DEFAULT 0 NOT NULL,
    stype integer
);


ALTER TABLE cpustats.user_stats OWNER TO portal;

--
-- Name: TABLE user_stats; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON TABLE user_stats IS 'Users statistics';


--
-- Name: COLUMN user_stats.srv_id; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN user_stats.srv_id IS 'Server ID';


--
-- Name: COLUMN user_stats.username; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN user_stats.username IS 'Username';


--
-- Name: COLUMN user_stats.realtime; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN user_stats.realtime IS 'Realtime';


--
-- Name: COLUMN user_stats.systime; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN user_stats.systime IS 'Systime';


--
-- Name: COLUMN user_stats.executions; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN user_stats.executions IS 'Executions';


--
-- Name: COLUMN user_stats.average; Type: COMMENT; Schema: cpustats; Owner: portal
--

COMMENT ON COLUMN user_stats.average IS 'Average load';


--
-- Name: user_min_max_values; Type: VIEW; Schema: cpustats; Owner: portal
--

CREATE VIEW user_min_max_values AS
    SELECT l.server, min(u.realtime) AS min_real, max(u.realtime) AS max_real, min(u.executions) AS min_count, max(u.executions) AS max_count, min(u.systime) AS min_sys, max(u.systime) AS max_sys, sum(u.realtime) AS real_sum, sum(u.executions) AS count_sum, sum(u.systime) AS sys_sum, u.stype FROM user_stats u, servers.list l WHERE (l.id = u.srv_id) GROUP BY l.server, u.stype;


ALTER TABLE cpustats.user_min_max_values OWNER TO portal;

SET search_path = hawk, pg_catalog;

--
-- Name: hourly_info; Type: TABLE; Schema: hawk; Owner: portal; Tablespace: 
--

CREATE TABLE hourly_info (
    date timestamp without time zone DEFAULT now() NOT NULL,
    srv_id integer NOT NULL,
    failed integer DEFAULT 0 NOT NULL,
    brutes integer DEFAULT 0 NOT NULL,
    blocked integer DEFAULT 0 NOT NULL
);


ALTER TABLE hawk.hourly_info OWNER TO portal;

--
-- Name: TABLE hourly_info; Type: COMMENT; Schema: hawk; Owner: portal
--

COMMENT ON TABLE hourly_info IS 'Contains per-hour information for the last 24 hours for each server.';


--
-- Name: COLUMN hourly_info.date; Type: COMMENT; Schema: hawk; Owner: portal
--

COMMENT ON COLUMN hourly_info.date IS 'Date of the record';


--
-- Name: COLUMN hourly_info.srv_id; Type: COMMENT; Schema: hawk; Owner: portal
--

COMMENT ON COLUMN hourly_info.srv_id IS 'Server ID';


--
-- Name: COLUMN hourly_info.failed; Type: COMMENT; Schema: hawk; Owner: portal
--

COMMENT ON COLUMN hourly_info.failed IS 'Number of failed login attempts';


--
-- Name: COLUMN hourly_info.brutes; Type: COMMENT; Schema: hawk; Owner: portal
--

COMMENT ON COLUMN hourly_info.brutes IS 'Number of bruteforce attempts';


--
-- Name: COLUMN hourly_info.blocked; Type: COMMENT; Schema: hawk; Owner: portal
--

COMMENT ON COLUMN hourly_info.blocked IS 'Number of blocked IPs';


--
-- Name: daily_min_max_values; Type: VIEW; Schema: hawk; Owner: portal
--

CREATE VIEW daily_min_max_values AS
    SELECT l.server, min(h.failed) AS min_failed, max(h.failed) AS max_failed, min(h.brutes) AS min_brutes, max(h.brutes) AS max_brutes, min(h.blocked) AS min_blocked, max(h.blocked) AS max_blocked, sum(h.failed) AS failed_sum, sum(h.brutes) AS brutes_sum, sum(h.blocked) AS blocked_sum FROM hourly_info h, servers.list l WHERE ((h.date > (now() - '24:00:00'::interval)) AND (h.srv_id = l.id)) GROUP BY l.server;


ALTER TABLE hawk.daily_min_max_values OWNER TO portal;

--
-- Name: VIEW daily_min_max_values; Type: COMMENT; Schema: hawk; Owner: portal
--

COMMENT ON VIEW daily_min_max_values IS 'Contains the min and max failed, block and brutes values for the last 24h.';


--
-- Name: stats_all_servers; Type: VIEW; Schema: hawk; Owner: portal
--

CREATE VIEW stats_all_servers AS
    SELECT sum(h.failed) AS failed_sum, sum(h.brutes) AS brutes_sum FROM hourly_info h WHERE (h.date > (now() - '01:00:00'::interval)) UNION ALL SELECT sum(h.failed) AS failed_sum, sum(h.brutes) AS brutes_sum FROM hourly_info h WHERE (h.date > (now() - '24:00:00'::interval));


ALTER TABLE hawk.stats_all_servers OWNER TO portal;

--
-- Name: VIEW stats_all_servers; Type: COMMENT; Schema: hawk; Owner: portal
--

COMMENT ON VIEW stats_all_servers IS 'Shows the sum of bruteforce/failed attempts for the last hour (row 1) and last day (row 2).';


SET search_path = monitoring, pg_catalog;

--
-- Name: lags; Type: TABLE; Schema: monitoring; Owner: portal; Tablespace: 
--

CREATE TABLE lags (
    srv_id integer NOT NULL,
    lag integer NOT NULL
);


ALTER TABLE monitoring.lags OWNER TO portal;

--
-- Name: TABLE lags; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON TABLE lags IS 'Servers lags';


SET search_path = servers, pg_catalog;

--
-- Name: groups; Type: TABLE; Schema: servers; Owner: portal; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    disabled_services integer[]
);


ALTER TABLE servers.groups OWNER TO portal;

--
-- Name: TABLE groups; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON TABLE groups IS 'Server groups';


--
-- Name: COLUMN groups.id; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN groups.id IS 'group id';


--
-- Name: COLUMN groups.name; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN groups.name IS 'Short name for the group';


--
-- Name: COLUMN groups.description; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN groups.description IS 'Description of the group usage';


--
-- Name: COLUMN groups.enabled; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN groups.enabled IS 'Are the machines in this group enabled for monitoring';


--
-- Name: COLUMN groups.disabled_services; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN groups.disabled_services IS 'Disabled services for this group';


--
-- Name: options; Type: TABLE; Schema: servers; Owner: portal; Tablespace: 
--

CREATE TABLE options (
    srv_id integer NOT NULL,
    group_id integer DEFAULT 1 NOT NULL,
    disabled_services integer[] DEFAULT '{16}'::integer[],
    enabled boolean DEFAULT true NOT NULL,
    date_added timestamp without time zone DEFAULT now() NOT NULL,
    backup_type integer DEFAULT 1 NOT NULL
);


ALTER TABLE servers.options OWNER TO portal;

--
-- Name: TABLE options; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON TABLE options IS 'Additional information about the server';


--
-- Name: COLUMN options.disabled_services; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN options.disabled_services IS 'Array of services which are not monitored';


--
-- Name: COLUMN options.enabled; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN options.enabled IS 'Is the server enabled for monitoring';


--
-- Name: COLUMN options.date_added; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN options.date_added IS 'Date when the server was added to the DB';


--
-- Name: COLUMN options.backup_type; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN options.backup_type IS '1 - prd; 3 - disabled; 4- business; 5 - big backup destination; 6 - ded';


SET search_path = monitoring, pg_catalog;

--
-- Name: servers; Type: VIEW; Schema: monitoring; Owner: portal
--

CREATE VIEW servers AS
    SELECT s.id, s.server, s.ip, g.id AS gid, (o.disabled_services || g.disabled_services) AS disabled_svc FROM servers.list s, servers.groups g, servers.options o WHERE ((((s.id = o.srv_id) AND (o.group_id = g.id)) AND o.enabled) AND g.enabled);


ALTER TABLE monitoring.servers OWNER TO portal;

--
-- Name: svc_status; Type: TABLE; Schema: monitoring; Owner: portal; Tablespace: 
--

CREATE TABLE svc_status (
    id integer NOT NULL,
    srv_id integer DEFAULT 0 NOT NULL,
    http smallint DEFAULT 0 NOT NULL,
    mysql smallint DEFAULT 0 NOT NULL,
    smtp smallint DEFAULT 0 NOT NULL,
    ftp smallint DEFAULT 0 NOT NULL,
    cron smallint DEFAULT 0 NOT NULL,
    pop3 smallint DEFAULT 0 NOT NULL,
    imap smallint DEFAULT 0 NOT NULL,
    nscd smallint DEFAULT 0 NOT NULL,
    cpanel smallint DEFAULT 0 NOT NULL,
    zendaemon smallint DEFAULT 0 NOT NULL,
    hawk smallint DEFAULT 0 NOT NULL,
    cpustats smallint DEFAULT 0 NOT NULL,
    mailquota smallint DEFAULT 0 NOT NULL,
    lifesigns smallint DEFAULT 0 NOT NULL,
    cpanellogd smallint DEFAULT 0 NOT NULL,
    pgsql smallint DEFAULT 0 NOT NULL,
    dns smallint DEFAULT 0 NOT NULL,
    ionotify smallint DEFAULT 0 NOT NULL,
    syslogd smallint DEFAULT 0 NOT NULL,
    klogd smallint DEFAULT 0 NOT NULL
);


ALTER TABLE monitoring.svc_status OWNER TO portal;

--
-- Name: TABLE svc_status; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON TABLE svc_status IS 'Status of all services per server

Statuses:   0 - not monitored, 1-ok, 2-down';


--
-- Name: COLUMN svc_status.http; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON COLUMN svc_status.http IS '0 - not monitored, 1-ok, 2-down';


--
-- Name: services_status_id_seq; Type: SEQUENCE; Schema: monitoring; Owner: portal
--

CREATE SEQUENCE services_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE monitoring.services_status_id_seq OWNER TO portal;

--
-- Name: services_status_id_seq; Type: SEQUENCE OWNED BY; Schema: monitoring; Owner: portal
--

ALTER SEQUENCE services_status_id_seq OWNED BY svc_status.id;


--
-- Name: srv_status; Type: TABLE; Schema: monitoring; Owner: portal; Tablespace: 
--

CREATE TABLE srv_status (
    srv_id integer NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    lag integer DEFAULT 0 NOT NULL,
    proc_count integer DEFAULT 0 NOT NULL,
    mail_queue integer DEFAULT 0 NOT NULL,
    load double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE monitoring.srv_status OWNER TO portal;

--
-- Name: TABLE srv_status; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON TABLE srv_status IS 'Current server status';


--
-- Name: COLUMN srv_status.last_updated; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON COLUMN srv_status.last_updated IS 'Last update of the information';


--
-- Name: COLUMN srv_status.status; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON COLUMN srv_status.status IS '0-not monitored ,1-ok, 2-timeout, 3-service down,4-all services down,5-maintenance';


--
-- Name: COLUMN srv_status.lag; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON COLUMN srv_status.lag IS 'Lag between the time in the status file and the current machine time(remote machine)';


--
-- Name: COLUMN srv_status.proc_count; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON COLUMN srv_status.proc_count IS 'Number of running processes on the machine';


--
-- Name: COLUMN srv_status.mail_queue; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON COLUMN srv_status.mail_queue IS 'Number of messages in the mail queue';


--
-- Name: COLUMN srv_status.load; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON COLUMN srv_status.load IS 'current server load';


--
-- Name: sg_statuses; Type: VIEW; Schema: monitoring; Owner: portal
--

CREATE VIEW sg_statuses AS
    SELECT l.s_id, srv.status, CASE WHEN (NOT o.enabled) THEN 1 WHEN (o.disabled_services IS NULL) THEN (svc.http)::integer WHEN (0 = ANY (o.disabled_services)) THEN 1 ELSE (svc.http)::integer END AS http, CASE WHEN (NOT o.enabled) THEN 1 ELSE (svc.mysql)::integer END AS mysql, CASE WHEN (NOT o.enabled) THEN 1 ELSE (svc.smtp)::integer END AS smtp, CASE WHEN (NOT o.enabled) THEN 1 ELSE (svc.ftp)::integer END AS ftp, CASE WHEN (NOT o.enabled) THEN 1 ELSE (svc.pop3)::integer END AS pop3, CASE WHEN (NOT o.enabled) THEN 1 ELSE (svc.imap)::integer END AS imap FROM servers.list l, servers.options o, srv_status srv, svc_status svc WHERE (((((l.id = srv.srv_id) AND (l.id = svc.srv_id)) AND (l.id = o.srv_id)) AND (o.group_id = ANY (servers.enabled_groups()))) AND (srv.status > 0));


ALTER TABLE monitoring.sg_statuses OWNER TO portal;

--
-- Name: VIEW sg_statuses; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON VIEW sg_statuses IS 'This view is used by sg.com API to return the current status of all our servers';


--
-- Name: COLUMN sg_statuses.s_id; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON COLUMN sg_statuses.s_id IS 'SG.com Server ID';


--
-- Name: COLUMN sg_statuses.status; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON COLUMN sg_statuses.status IS '0-not monitored ,1-ok, 2-timeout, 3-service down,4-all services down,5-maintenance';


--
-- Name: COLUMN sg_statuses.http; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON COLUMN sg_statuses.http IS '0 - not monitored, 1-ok, 2-down';


--
-- Name: sg_statuses2; Type: VIEW; Schema: monitoring; Owner: portal
--

CREATE VIEW sg_statuses2 AS
    SELECT l.s_id, srv.status, CASE WHEN (o.disabled_services IS NULL) THEN (svc.http)::integer WHEN (0 = ANY (o.disabled_services)) THEN 1 ELSE (svc.http)::integer END AS http, svc.mysql, svc.smtp, svc.ftp, svc.pop3, svc.imap FROM servers.list l, servers.options o, srv_status srv, svc_status svc WHERE (((((l.id = srv.srv_id) AND (l.id = svc.srv_id)) AND (l.id = o.srv_id)) AND (o.group_id = ANY (servers.enabled_groups()))) AND (srv.status > 0));


ALTER TABLE monitoring.sg_statuses2 OWNER TO portal;

--
-- Name: VIEW sg_statuses2; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON VIEW sg_statuses2 IS 'This view is used by sg.com API to return the current status of all our servers';


--
-- Name: show_lags; Type: VIEW; Schema: monitoring; Owner: portal
--

CREATE VIEW show_lags AS
    SELECT count(lags.lag) AS count, lags.lag FROM lags WHERE (lags.lag > 3) GROUP BY lags.lag ORDER BY lags.lag;


ALTER TABLE monitoring.show_lags OWNER TO portal;

--
-- Name: VIEW show_lags; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON VIEW show_lags IS 'Show lags groupd by lag duration';


SET search_path = problems, pg_catalog;

--
-- Name: durations_24h; Type: TABLE; Schema: problems; Owner: portal; Tablespace: 
--

CREATE TABLE durations_24h (
    id integer NOT NULL,
    start_time timestamp without time zone DEFAULT now() NOT NULL,
    end_time timestamp without time zone,
    duration integer,
    type integer NOT NULL,
    description text,
    srv_id integer NOT NULL,
    services integer[],
    sys_comment text
);


ALTER TABLE problems.durations_24h OWNER TO portal;

--
-- Name: TABLE durations_24h; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON TABLE durations_24h IS 'List of the problems for the last 24h';


--
-- Name: COLUMN durations_24h.start_time; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_24h.start_time IS 'Time when the problem was detected';


--
-- Name: COLUMN durations_24h.end_time; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_24h.end_time IS 'Time when the problem was fixed';


--
-- Name: COLUMN durations_24h.duration; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_24h.duration IS 'Duration of the problem';


--
-- Name: COLUMN durations_24h.type; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_24h.type IS '0-timeout,1-allservices,2-one or more services';


--
-- Name: COLUMN durations_24h.description; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_24h.description IS 'Comment about the detected problem';


--
-- Name: COLUMN durations_24h.srv_id; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_24h.srv_id IS 'Id of the server which we are registering a down';


--
-- Name: COLUMN durations_24h.services; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_24h.services IS 'list of services which are down(only when the down is of type 2)';


--
-- Name: COLUMN durations_24h.sys_comment; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_24h.sys_comment IS 'System message or error';


SET search_path = monitoring, pg_catalog;

--
-- Name: show_problems; Type: VIEW; Schema: monitoring; Owner: portal
--

CREATE VIEW show_problems AS
    (SELECT o.group_id, l.server, l.id, srv.status, srv.lag, srv.load, srv.proc_count, srv.mail_queue, d.sys_comment, round((date_part('epoch'::text, now()) - date_part('epoch'::text, d.start_time))) AS dur, svc.http, svc.mysql, svc.smtp, svc.ftp, svc.cron, svc.pop3, svc.nscd, svc.cpanel, svc.zendaemon, svc.hawk, svc.cpustats, svc.mailquota, svc.lifesigns, svc.cpanellogd, svc.pgsql, svc.dns, svc.ionotify, svc.syslogd, svc.klogd FROM servers.list l, srv_status srv, svc_status svc, problems.durations_24h d, servers.options o WHERE (((((((l.id = srv.srv_id) AND (l.id = svc.srv_id)) AND (d.srv_id = l.id)) AND (l.id = o.srv_id)) AND (o.group_id = ANY (servers.enabled_groups()))) AND (srv.status > 1)) AND (d.end_time IS NULL)) ORDER BY srv.load DESC, srv.status DESC) UNION ALL (SELECT o.group_id, l.server, l.id, srv.status, srv.lag, srv.load, srv.proc_count, srv.mail_queue, '' AS sys_comment, CASE WHEN (srv.lag > 20) THEN srv.lag ELSE 0 END AS dur, svc.http, svc.mysql, svc.smtp, svc.ftp, svc.cron, svc.pop3, svc.nscd, svc.cpanel, svc.zendaemon, svc.hawk, svc.cpustats, svc.mailquota, svc.lifesigns, svc.cpanellogd, svc.pgsql, svc.dns, svc.ionotify, svc.syslogd, svc.klogd FROM servers.list l, srv_status srv, svc_status svc, servers.options o WHERE ((((((l.id = srv.srv_id) AND (l.id = svc.srv_id)) AND (l.id = o.srv_id)) AND (o.group_id = ANY (servers.enabled_groups()))) AND (srv.status <= 1)) AND (((srv.load > (5)::double precision) OR (srv.lag > 20)) OR (srv.mail_queue > 450))) ORDER BY srv.load DESC);


ALTER TABLE monitoring.show_problems OWNER TO portal;

--
-- Name: VIEW show_problems; Type: COMMENT; Schema: monitoring; Owner: portal
--

COMMENT ON VIEW show_problems IS 'Show all servers with problems';


--
-- Name: show_problems2; Type: VIEW; Schema: monitoring; Owner: portal
--

CREATE VIEW show_problems2 AS
    (SELECT l.server, l.id, srv.status, srv.lag, srv.load, srv.proc_count, srv.mail_queue, d.sys_comment, round((date_part('epoch'::text, now()) - date_part('epoch'::text, d.start_time))) AS dur, svc.http, svc.mysql, svc.smtp, svc.ftp, svc.cron, svc.pop3, svc.nscd, svc.cpanel, svc.zendaemon, svc.hawk, svc.cpustats, svc.mailquota, svc.lifesigns, svc.cpanellogd, svc.pgsql, svc.dns, svc.ionotify, svc.syslogd, svc.klogd FROM servers.list l, srv_status srv, svc_status svc, problems.durations_24h d, servers.options o WHERE (((((((l.id = srv.srv_id) AND (l.id = svc.srv_id)) AND (d.srv_id = l.id)) AND (l.id = o.srv_id)) AND (o.group_id = ANY (ARRAY[3, 4, 7]))) AND (srv.status > 1)) AND (d.end_time IS NULL)) ORDER BY srv.load DESC, srv.status DESC) UNION ALL (SELECT l.server, l.id, srv.status, srv.lag, srv.load, srv.proc_count, srv.mail_queue, '' AS sys_comment, 0 AS dur, svc.http, svc.mysql, svc.smtp, svc.ftp, svc.cron, svc.pop3, svc.nscd, svc.cpanel, svc.zendaemon, svc.hawk, svc.cpustats, svc.mailquota, svc.lifesigns, svc.cpanellogd, svc.pgsql, svc.dns, svc.ionotify, svc.syslogd, svc.klogd FROM servers.list l, srv_status srv, svc_status svc, servers.options o WHERE ((((((l.id = srv.srv_id) AND (l.id = svc.srv_id)) AND (l.id = o.srv_id)) AND (o.group_id = ANY (ARRAY[3, 4, 7]))) AND (srv.status <= 1)) AND ((srv.load > (10)::double precision) OR (srv.lag > 20))) ORDER BY srv.load DESC);


ALTER TABLE monitoring.show_problems2 OWNER TO portal;

SET search_path = problems, pg_catalog;

--
-- Name: stats_24h; Type: TABLE; Schema: problems; Owner: portal; Tablespace: 
--

CREATE TABLE stats_24h (
    id integer NOT NULL,
    server_id integer NOT NULL,
    hour timestamp without time zone DEFAULT now() NOT NULL,
    timeout_time integer DEFAULT 0 NOT NULL,
    allsvc_time integer DEFAULT 0 NOT NULL,
    service_time integer DEFAULT 0 NOT NULL,
    timeout_downs integer DEFAULT 0 NOT NULL,
    allsvc_downs integer DEFAULT 0 NOT NULL,
    service_downs integer DEFAULT 0 NOT NULL
);


ALTER TABLE problems.stats_24h OWNER TO portal;

--
-- Name: TABLE stats_24h; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON TABLE stats_24h IS 'Statistics for the last 24h by hour';


--
-- Name: COLUMN stats_24h.timeout_time; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN stats_24h.timeout_time IS 'Combined downtime caused by timeouts';


--
-- Name: COLUMN stats_24h.allsvc_time; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN stats_24h.allsvc_time IS 'Combined downtime where all services were down but not considered timeout';


--
-- Name: COLUMN stats_24h.service_time; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN stats_24h.service_time IS 'Combined downtime of a service/s but not all services or ti';


--
-- Name: COLUMN stats_24h.timeout_downs; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN stats_24h.timeout_downs IS 'Combined downtimes caused by timeouts';


--
-- Name: COLUMN stats_24h.allsvc_downs; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN stats_24h.allsvc_downs IS 'Combined downtimes where all services were down';


--
-- Name: COLUMN stats_24h.service_downs; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN stats_24h.service_downs IS 'Combined downtimes where a service/s but not all services were down';


--
-- Name: 24h_stats_id_seq; Type: SEQUENCE; Schema: problems; Owner: portal
--

CREATE SEQUENCE "24h_stats_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE problems."24h_stats_id_seq" OWNER TO portal;

--
-- Name: 24h_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: problems; Owner: portal
--

ALTER SEQUENCE "24h_stats_id_seq" OWNED BY stats_24h.id;


--
-- Name: durations_daily; Type: TABLE; Schema: problems; Owner: portal; Tablespace: 
--

CREATE TABLE durations_daily (
    id integer NOT NULL,
    start_time timestamp without time zone DEFAULT now() NOT NULL,
    end_time timestamp without time zone NOT NULL,
    duration integer,
    type integer NOT NULL,
    services_id integer NOT NULL,
    description text
);


ALTER TABLE problems.durations_daily OWNER TO portal;

--
-- Name: TABLE durations_daily; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON TABLE durations_daily IS 'History of all problems';


--
-- Name: COLUMN durations_daily.start_time; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_daily.start_time IS 'Time when the problem was detected';


--
-- Name: COLUMN durations_daily.end_time; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_daily.end_time IS 'Time when the problem was fixed';


--
-- Name: COLUMN durations_daily.duration; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_daily.duration IS 'Duration of the problem';


--
-- Name: COLUMN durations_daily.type; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_daily.type IS '0-timeout,1-allservices,2-one or more services';


--
-- Name: COLUMN durations_daily.services_id; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_daily.services_id IS 'ID of the services listing';


--
-- Name: COLUMN durations_daily.description; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN durations_daily.description IS 'Comment about the detected problem';


--
-- Name: daily_dur_id_seq; Type: SEQUENCE; Schema: problems; Owner: portal
--

CREATE SEQUENCE daily_dur_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE problems.daily_dur_id_seq OWNER TO portal;

--
-- Name: daily_dur_id_seq; Type: SEQUENCE OWNED BY; Schema: problems; Owner: portal
--

ALTER SEQUENCE daily_dur_id_seq OWNED BY durations_daily.id;


--
-- Name: daily_stats; Type: TABLE; Schema: problems; Owner: portal; Tablespace: 
--

CREATE TABLE daily_stats (
    id integer NOT NULL,
    srv_id integer NOT NULL,
    hour timestamp without time zone DEFAULT now() NOT NULL,
    timeout_time integer DEFAULT 0 NOT NULL,
    allsvc_time integer DEFAULT 0 NOT NULL,
    service_time integer DEFAULT 0 NOT NULL,
    timeout_downs integer DEFAULT 0 NOT NULL,
    allsvc_downs integer DEFAULT 0 NOT NULL,
    service_downs integer DEFAULT 0 NOT NULL
);


ALTER TABLE problems.daily_stats OWNER TO portal;

--
-- Name: TABLE daily_stats; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON TABLE daily_stats IS 'Statistics for the last 24h by hour';


--
-- Name: COLUMN daily_stats.timeout_time; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN daily_stats.timeout_time IS 'Combined downtime caused by timeouts';


--
-- Name: COLUMN daily_stats.allsvc_time; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN daily_stats.allsvc_time IS 'Combined downtime where all services were down but not considered timeout';


--
-- Name: COLUMN daily_stats.service_time; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN daily_stats.service_time IS 'Combined downtime of a service/s but not all services or ti';


--
-- Name: COLUMN daily_stats.timeout_downs; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN daily_stats.timeout_downs IS 'Combined downtimes caused by timeouts';


--
-- Name: COLUMN daily_stats.allsvc_downs; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN daily_stats.allsvc_downs IS 'Combined downtimes where all services were down';


--
-- Name: COLUMN daily_stats.service_downs; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN daily_stats.service_downs IS 'Combined downtimes where a service/s but not all services were down';


--
-- Name: daily_stats_id_seq; Type: SEQUENCE; Schema: problems; Owner: portal
--

CREATE SEQUENCE daily_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE problems.daily_stats_id_seq OWNER TO portal;

--
-- Name: daily_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: problems; Owner: portal
--

ALTER SEQUENCE daily_stats_id_seq OWNED BY daily_stats.id;


--
-- Name: dur_24h_id_seq; Type: SEQUENCE; Schema: problems; Owner: portal
--

CREATE SEQUENCE dur_24h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE problems.dur_24h_id_seq OWNER TO portal;

--
-- Name: dur_24h_id_seq; Type: SEQUENCE OWNED BY; Schema: problems; Owner: portal
--

ALTER SEQUENCE dur_24h_id_seq OWNED BY durations_24h.id;


--
-- Name: problems_durations_archive; Type: TABLE; Schema: problems; Owner: portal; Tablespace: 
--

CREATE TABLE problems_durations_archive (
    id integer NOT NULL,
    duration integer,
    type integer,
    description text,
    srv_id integer,
    services integer[],
    sys_comment text,
    start_time timestamp without time zone,
    end_time timestamp without time zone
);


ALTER TABLE problems.problems_durations_archive OWNER TO portal;

--
-- Name: TABLE problems_durations_archive; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON TABLE problems_durations_archive IS 'Archive of all problems along with their durations';


--
-- Name: COLUMN problems_durations_archive.id; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN problems_durations_archive.id IS 'The id from problems.durations_24h';


--
-- Name: COLUMN problems_durations_archive.duration; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN problems_durations_archive.duration IS 'How long the service(s) have been down';


--
-- Name: COLUMN problems_durations_archive.type; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN problems_durations_archive.type IS 'Type of the down';


--
-- Name: COLUMN problems_durations_archive.description; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN problems_durations_archive.description IS 'The description of the down added by the admins';


--
-- Name: COLUMN problems_durations_archive.srv_id; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN problems_durations_archive.srv_id IS 'The ID of the server whose service(s) have been down';


--
-- Name: COLUMN problems_durations_archive.services; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN problems_durations_archive.services IS 'The list of the services that were down';


--
-- Name: COLUMN problems_durations_archive.sys_comment; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN problems_durations_archive.sys_comment IS 'The system comments for the particular down';


--
-- Name: COLUMN problems_durations_archive.start_time; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN problems_durations_archive.start_time IS 'Time when the problem was detected';


--
-- Name: COLUMN problems_durations_archive.end_time; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN problems_durations_archive.end_time IS 'Time when the problem was fixed';


--
-- Name: service_downs; Type: TABLE; Schema: problems; Owner: portal; Tablespace: 
--

CREATE TABLE service_downs (
    id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    services integer[] NOT NULL
);


ALTER TABLE problems.service_downs OWNER TO portal;

--
-- Name: TABLE service_downs; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON TABLE service_downs IS 'Lists of services which were down in different periods of time';


--
-- Name: COLUMN service_downs.id; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN service_downs.id IS 'ID of the registered down';


--
-- Name: COLUMN service_downs.date; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN service_downs.date IS 'Time when the services were detected as down';


--
-- Name: COLUMN service_downs.services; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON COLUMN service_downs.services IS 'List of services which were detected as down';


--
-- Name: show_active_downs; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_active_downs AS
    SELECT durations_24h.id, durations_24h.start_time, durations_24h.end_time, durations_24h.duration, durations_24h.type, durations_24h.description, durations_24h.srv_id, durations_24h.services, durations_24h.sys_comment FROM durations_24h WHERE (durations_24h.end_time IS NULL) ORDER BY durations_24h.srv_id;


ALTER TABLE problems.show_active_downs OWNER TO portal;

--
-- Name: VIEW show_active_downs; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON VIEW show_active_downs IS 'Select all downs that have not finished yet';


--
-- Name: show_active_durations; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_active_durations AS
    SELECT s.server, d.type, round((date_part('epoch'::text, now()) - date_part('epoch'::text, d.start_time))) AS duration, d.description, d.services, d.sys_comment FROM durations_24h d, servers.list s WHERE ((d.srv_id = s.id) AND (d.end_time IS NULL)) ORDER BY d.srv_id;


ALTER TABLE problems.show_active_durations OWNER TO portal;

--
-- Name: show_active_durations_with_server_group; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_active_durations_with_server_group AS
    SELECT l.server, o.group_id AS server_group, round((date_part('epoch'::text, now()) - date_part('epoch'::text, d.start_time))) AS duration, d.type, d.services FROM durations_24h d, servers.list l, servers.options o WHERE ((((d.end_time IS NULL) AND (round((date_part('epoch'::text, now()) - date_part('epoch'::text, d.start_time))) > (20)::double precision)) AND (l.id = d.srv_id)) AND (l.id = o.srv_id)) ORDER BY round((date_part('epoch'::text, now()) - date_part('epoch'::text, d.start_time))) DESC;


ALTER TABLE problems.show_active_durations_with_server_group OWNER TO portal;

--
-- Name: VIEW show_active_durations_with_server_group; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON VIEW show_active_durations_with_server_group IS 'For all active downs shows:
    - server name
    - server group
    - duration
    - type of the down
    - array of services that are down';


--
-- Name: show_downs_without_comments; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_downs_without_comments AS
    SELECT d.id, l.server, o.group_id AS server_group, d.duration, d.start_time, d.end_time, d.services, d.sys_comment FROM durations_24h d, servers.list l, servers.options o WHERE (((((((o.srv_id = d.srv_id) AND (l.id = d.srv_id)) AND (d.duration IS NOT NULL)) AND ((d.type = 0) OR ((d.type = 2) AND (((0 = ANY (d.services)) OR (1 = ANY (d.services))) OR (19 = ANY (d.services)))))) AND (d.duration >= 60)) AND (o.group_id = ANY (ARRAY[1, 2]))) AND (d.description IS NULL)) UNION ALL SELECT d.id, l.server, o.group_id AS server_group, round((date_part('epoch'::text, now()) - date_part('epoch'::text, d.start_time))) AS duration, d.start_time, d.end_time, d.services, d.sys_comment FROM durations_24h d, servers.list l, servers.options o WHERE (((((((o.srv_id = d.srv_id) AND (l.id = d.srv_id)) AND (d.duration IS NULL)) AND ((d.type = 0) OR ((d.type = 2) AND (((0 = ANY (d.services)) OR (1 = ANY (d.services))) OR (19 = ANY (d.services)))))) AND (round((date_part('epoch'::text, now()) - date_part('epoch'::text, d.start_time))) >= (60)::double precision)) AND (o.group_id = ANY (ARRAY[1, 2]))) AND (d.description IS NULL));


ALTER TABLE problems.show_downs_without_comments OWNER TO portal;

--
-- Name: VIEW show_downs_without_comments; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON VIEW show_downs_without_comments IS 'Shows all downs without admin comments';


--
-- Name: show_downtimes; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_downtimes AS
    SELECT l.server, ((p.timeout_time + p.allsvc_time) + p.service_time) AS total_time, ((p.timeout_downs + p.allsvc_downs) + p.service_downs) AS total_downs FROM servers.list l, daily_stats p WHERE ((l.id = p.srv_id) AND (((p.timeout_time + p.allsvc_time) + p.service_time) > 1500)) ORDER BY ((p.timeout_time + p.allsvc_time) + p.service_time) DESC;


ALTER TABLE problems.show_downtimes OWNER TO portal;

--
-- Name: show_last24h_downs; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_last24h_downs AS
    SELECT l.server, d.duration, date_trunc('seconds'::text, d.start_time) AS start_time, date_trunc('seconds'::text, d.end_time) AS end_time, CASE WHEN (d.services = '{}'::integer[]) THEN NULL::integer[] ELSE d.services END AS services, d.sys_comment, d.description, d.type, o.group_id FROM durations_24h d, servers.list l, servers.options o WHERE (((l.id = d.srv_id) AND (o.srv_id = d.srv_id)) AND (d.duration > 20));


ALTER TABLE problems.show_last24h_downs OWNER TO portal;

--
-- Name: show_last24h_downs_by_server; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_last24h_downs_by_server AS
    -- SELECT l.server, o.group_id AS server_group, count(p.srv_id) AS count, (sum(CASE WHEN (p.duration IS NULL) THEN round((date_part('epoch'::text, now()) - date_part('epoch'::text, p.start_time))) ELSE (p.duration)::double precision END))::bigint AS total_time FROM durations_24h p, servers.list l, servers.options o WHERE ((((p.duration > 20) AND ((((p.type = 0) OR (p.type = 1)) OR (0 = ANY (p.services))) OR (1 = ANY (p.services)))) AND (p.srv_id = l.id)) AND (p.srv_id = o.srv_id)) GROUP BY l.server, o.group_id;
	SELECT l.server, o.group_id AS server_group, count(p.srv_id) AS count, (sum(CASE WHEN (p.duration IS NULL) THEN round((date_part('epoch'::text, now()) - date_part('epoch'::text, p.start_time))) ELSE (p.duration)::double precision END))::bigint AS total_time, (sum(CASE WHEN ((((p."type" = 0) OR (p."type" = 1)) OR (0 = ANY (p.services))) OR (1 = ANY (p.services))) THEN (p.duration)::double precision ELSE (0)::double precision END))::bigint AS web_time FROM durations_24h p, servers.list l, servers.options o WHERE (((p.duration > 20) AND (p.srv_id = l.id)) AND (p.srv_id = o.srv_id)) GROUP BY l.server, o.group_id;


ALTER TABLE problems.show_last24h_downs_by_server OWNER TO portal;

--
-- Name: VIEW show_last24h_downs_by_server; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON VIEW show_last24h_downs_by_server IS 'For each server shows its group, count of downs made today and the sum of the total time the server was down.';


--
-- Name: show_last24h_downs_by_server_and_type; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_last24h_downs_by_server_and_type AS
    SELECT l.server, o.group_id AS server_group, d.type, count(d.type) AS count FROM durations_24h d, servers.list l, servers.options o WHERE ((((d.duration > 20) AND ((d.start_time)::date >= ((now() - '1 day'::interval))::date)) AND (l.id = d.srv_id)) AND (o.srv_id = d.srv_id)) GROUP BY l.server, o.group_id, d.type;


ALTER TABLE problems.show_last24h_downs_by_server_and_type OWNER TO portal;

--
-- Name: VIEW show_last24h_downs_by_server_and_type; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON VIEW show_last24h_downs_by_server_and_type IS 'Shows count of downs from the last 24h grouped by server and type of the down. Shows group_id of the server along with each down.';


--
-- Name: show_last24h_downs_by_server_group_and_type; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_last24h_downs_by_server_group_and_type AS
    SELECT o.group_id AS server_group, d.type, count(d.id) AS count, (sum(CASE WHEN (d.duration IS NULL) THEN round((date_part('epoch'::text, now()) - date_part('epoch'::text, d.start_time))) ELSE (d.duration)::double precision END))::bigint AS total_time FROM durations_24h d, servers.options o WHERE ((d.srv_id = o.srv_id) AND (d.duration > 20)) GROUP BY o.group_id, d.type;


ALTER TABLE problems.show_last24h_downs_by_server_group_and_type OWNER TO portal;

--
-- Name: VIEW show_last24h_downs_by_server_group_and_type; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON VIEW show_last24h_downs_by_server_group_and_type IS 'Shows count of downs, sum of time down from last 24h grouped by server_group and type.';


--
-- Name: show_last24h_downs_by_server_id; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_last24h_downs_by_server_id AS
    SELECT l.id AS server_id, 0 AS downs FROM servers.list l, servers.options o WHERE (((l.id = o.srv_id) AND (o.group_id = ANY (ARRAY[1, 2]))) AND (NOT (l.id IN (SELECT durations_24h.srv_id FROM durations_24h WHERE (durations_24h.duration > 20))))) UNION SELECT d.srv_id AS server_id, count(d.srv_id) AS downs FROM durations_24h d, servers.options o WHERE (((d.duration > 20) AND (d.srv_id = o.srv_id)) AND (o.group_id = ANY (ARRAY[1, 2]))) GROUP BY d.srv_id;


ALTER TABLE problems.show_last24h_downs_by_server_id OWNER TO portal;

--
-- Name: VIEW show_last24h_downs_by_server_id; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON VIEW show_last24h_downs_by_server_id IS 'For each server in group id 1,2 shows its id and count of downs made today.';


--
-- Name: show_last24h_downs_by_server_id_OLD; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW "show_last24h_downs_by_server_id_OLD" AS
    SELECT l.id AS server_id, (SELECT count(durations_24h.srv_id) AS count FROM durations_24h WHERE ((durations_24h.duration > 20) AND (durations_24h.srv_id = l.id))) AS downs FROM servers.list l, servers.options o WHERE ((l.id = o.srv_id) AND (o.group_id = ANY (ARRAY[1, 2])));


ALTER TABLE problems."show_last24h_downs_by_server_id_OLD" OWNER TO portal;

--
-- Name: VIEW "show_last24h_downs_by_server_id_OLD"; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON VIEW "show_last24h_downs_by_server_id_OLD" IS 'For each server in group id 1,2 shows its id and count of downs made today.';


--
-- Name: show_last24h_downs_local; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_last24h_downs_local AS
    SELECT l.server, d.duration, date_trunc('seconds'::text, d.start_time) AS start_time, date_trunc('seconds'::text, d.end_time) AS end_time, CASE WHEN (d.services = '{}'::integer[]) THEN NULL::integer[] ELSE d.services END AS services, d.sys_comment, d.description, d.type, o.group_id FROM durations_24h d, servers.list l, servers.options o WHERE (((l.id = d.srv_id) AND (o.srv_id = d.srv_id)) AND (d.duration > 20));


ALTER TABLE problems.show_last24h_downs_local OWNER TO portal;

--
-- Name: show_old_downs; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_old_downs AS
    SELECT l.server, d.duration, date_trunc('seconds'::text, d.start_time) AS start_time, date_trunc('seconds'::text, d.end_time) AS end_time, CASE WHEN (d.services = '{}'::integer[]) THEN NULL::integer[] ELSE d.services END AS services, d.sys_comment, d.description, d.type, o.group_id FROM problems_durations_archive d, servers.list l, servers.options o WHERE (((l.id = d.srv_id) AND (o.srv_id = d.srv_id)) AND (d.duration > 20));


ALTER TABLE problems.show_old_downs OWNER TO portal;

--
-- Name: show_old_downs_by_date_and_server; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_old_downs_by_date_and_server AS
--    SELECT (p.start_time)::date AS date, l.server, o.group_id AS server_group, count(p.srv_id) AS count, sum(p.duration) AS total_time FROM problems_durations_archive p, servers.list l, servers.options o WHERE ((((p.duration > 20) AND ((((p.type = 0) OR (p.type = 1)) OR (0 = ANY (p.services))) OR (1 = ANY (p.services)))) AND (p.srv_id = l.id)) AND (p.srv_id = o.srv_id)) GROUP BY (p.start_time)::date, l.server, o.group_id;
	SELECT (p.start_time)::date AS date, l.server, o.group_id AS server_group, count(p.srv_id) AS count, sum(p.duration) AS total_time, sum(CASE WHEN ((((p."type" = 0) OR (p."type" = 1)) OR (0 = ANY (p.services))) OR (1 = ANY (p.services))) THEN (p.duration)::double precision ELSE (0)::double precision END) AS web_time FROM problems_durations_archive p, servers.list l, servers.options o WHERE (((p.duration > 20) AND (p.srv_id = l.id)) AND (p.srv_id = o.srv_id)) GROUP BY (p.start_time)::date, l.server, o.group_id;


ALTER TABLE problems.show_old_downs_by_date_and_server OWNER TO portal;

--
-- Name: VIEW show_old_downs_by_date_and_server; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON VIEW show_old_downs_by_date_and_server IS 'Shows count of downs and total time down from archive grouped by date and server. Shows server group along with each server.';


--
-- Name: show_old_downs_by_date_server_and_type; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_old_downs_by_date_server_and_type AS
    SELECT (d.start_time)::date AS date, l.server, o.group_id AS server_group, d.type, count(d.type) AS count FROM problems_durations_archive d, servers.list l, servers.options o WHERE (((d.duration > 20) AND (l.id = d.srv_id)) AND (o.srv_id = d.srv_id)) GROUP BY (d.start_time)::date, l.server, o.group_id, d.type;


ALTER TABLE problems.show_old_downs_by_date_server_and_type OWNER TO portal;

--
-- Name: VIEW show_old_downs_by_date_server_and_type; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON VIEW show_old_downs_by_date_server_and_type IS 'Shows count of downs older than 24h grouped by date, server and type.';


--
-- Name: show_old_downs_by_date_server_group_and_type; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_old_downs_by_date_server_group_and_type AS
    SELECT (d.start_time)::date AS date, o.group_id AS server_group, d.type, count(d.id) AS count, sum(d.duration) AS total_time FROM problems_durations_archive d, servers.options o WHERE ((d.duration > 20) AND (d.srv_id = o.srv_id)) GROUP BY (d.start_time)::date, o.group_id, d.type;


ALTER TABLE problems.show_old_downs_by_date_server_group_and_type OWNER TO portal;

--
-- Name: VIEW show_old_downs_by_date_server_group_and_type; Type: COMMENT; Schema: problems; Owner: portal
--

COMMENT ON VIEW show_old_downs_by_date_server_group_and_type IS 'Shows count of downs and total time down from the archive grouped by date, server_group and type.';


--
-- Name: show_old_downs_local; Type: VIEW; Schema: problems; Owner: portal
--

CREATE VIEW show_old_downs_local AS
    SELECT l.server, d.duration, date_trunc('seconds'::text, d.start_time) AS start_time, date_trunc('seconds'::text, d.end_time) AS end_time, CASE WHEN (d.services = '{}'::integer[]) THEN NULL::integer[] ELSE d.services END AS services, d.sys_comment, d.description, d.type, o.group_id FROM problems_durations_archive d, servers.list l, servers.options o WHERE (((l.id = d.srv_id) AND (o.srv_id = d.srv_id)) AND (d.duration > 20));


ALTER TABLE problems.show_old_downs_local OWNER TO portal;

SET search_path = quotastats, pg_catalog;

--
-- Name: disk_usage; Type: TABLE; Schema: quotastats; Owner: portal; Tablespace: 
--

CREATE TABLE disk_usage (
    date timestamp without time zone,
    srv_id integer NOT NULL,
    gb double precision NOT NULL,
    percent integer NOT NULL,
    inodes integer DEFAULT 0 NOT NULL,
    mountpoint integer NOT NULL
);


ALTER TABLE quotastats.disk_usage OWNER TO portal;

--
-- Name: TABLE disk_usage; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON TABLE disk_usage IS 'Disk usage table';


--
-- Name: COLUMN disk_usage.date; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON COLUMN disk_usage.date IS 'Date';


--
-- Name: COLUMN disk_usage.srv_id; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON COLUMN disk_usage.srv_id IS 'Server ID';


--
-- Name: COLUMN disk_usage.gb; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON COLUMN disk_usage.gb IS 'Usage, GB';


--
-- Name: COLUMN disk_usage.percent; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON COLUMN disk_usage.percent IS 'Usage, %';


--
-- Name: COLUMN disk_usage.inodes; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON COLUMN disk_usage.inodes IS 'Inodes';


--
-- Name: COLUMN disk_usage.mountpoint; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON COLUMN disk_usage.mountpoint IS 'Mountpoint';


--
-- Name: disk_min_max_values; Type: VIEW; Schema: quotastats; Owner: portal
--

CREATE VIEW disk_min_max_values AS
    SELECT l.server, min(u.gb) AS min_usage, max(u.gb) AS max_usage, min(u.percent) AS min_perc, max(u.percent) AS max_perc, sum(u.gb) AS usage_sum, sum(u.percent) AS percent_sum FROM disk_usage u, servers.list l WHERE ((u.mountpoint = 1) AND (u.srv_id = l.id)) GROUP BY l.server;


ALTER TABLE quotastats.disk_min_max_values OWNER TO portal;

--
-- Name: VIEW disk_min_max_values; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON VIEW disk_min_max_values IS 'Disk usage';


--
-- Name: user_usage; Type: TABLE; Schema: quotastats; Owner: portal; Tablespace: 
--

CREATE TABLE user_usage (
    srv_id integer NOT NULL,
    username character varying NOT NULL,
    block_used double precision NOT NULL,
    inodes_used integer NOT NULL
);


ALTER TABLE quotastats.user_usage OWNER TO portal;

--
-- Name: TABLE user_usage; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON TABLE user_usage IS 'User disk usage stats';


--
-- Name: COLUMN user_usage.srv_id; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON COLUMN user_usage.srv_id IS 'Server ID';


--
-- Name: COLUMN user_usage.username; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON COLUMN user_usage.username IS 'Username';


--
-- Name: COLUMN user_usage.block_used; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON COLUMN user_usage.block_used IS 'Block used';


--
-- Name: COLUMN user_usage.inodes_used; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON COLUMN user_usage.inodes_used IS 'Inodes used';


--
-- Name: user_min_max_values; Type: VIEW; Schema: quotastats; Owner: portal
--

CREATE VIEW user_min_max_values AS
    SELECT l.server, min(u.block_used) AS min_usage, max(u.block_used) AS max_usage, sum(u.block_used) AS usage_sum FROM user_usage u, servers.list l WHERE (u.srv_id = l.id) GROUP BY l.server;


ALTER TABLE quotastats.user_min_max_values OWNER TO portal;

--
-- Name: VIEW user_min_max_values; Type: COMMENT; Schema: quotastats; Owner: portal
--

COMMENT ON VIEW user_min_max_values IS 'User usage';


SET search_path = servers, pg_catalog;

--
-- Name: disk_usage; Type: TABLE; Schema: servers; Owner: portal; Tablespace: 
--

CREATE TABLE disk_usage (
    servid integer,
    du integer,
    date timestamp without time zone
);


ALTER TABLE servers.disk_usage OWNER TO portal;

--
-- Name: TABLE disk_usage; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON TABLE disk_usage IS 'Servers disk usage table';


--
-- Name: COLUMN disk_usage.servid; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN disk_usage.servid IS 'Server ID';


--
-- Name: COLUMN disk_usage.du; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN disk_usage.du IS 'Disk usage (%)';


--
-- Name: COLUMN disk_usage.date; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN disk_usage.date IS 'Date updated';


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: servers; Owner: portal
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE servers.groups_id_seq OWNER TO portal;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: servers; Owner: portal
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: list_id_seq; Type: SEQUENCE; Schema: servers; Owner: portal
--

CREATE SEQUENCE list_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE servers.list_id_seq OWNER TO portal;

--
-- Name: list_id_seq; Type: SEQUENCE OWNED BY; Schema: servers; Owner: portal
--

ALTER SEQUENCE list_id_seq OWNED BY list.id;


--
-- Name: lpr; Type: TABLE; Schema: servers; Owner: portal; Tablespace: 
--

CREATE TABLE lpr (
    servid integer,
    date timestamp without time zone
);


ALTER TABLE servers.lpr OWNER TO portal;

--
-- Name: TABLE lpr; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON TABLE lpr IS 'List of all servers which were LPR in the past 24h';


--
-- Name: COLUMN lpr.servid; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN lpr.servid IS 'Server''s ID';


--
-- Name: COLUMN lpr.date; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN lpr.date IS 'Date added';


--
-- Name: lpr_history; Type: TABLE; Schema: servers; Owner: portal; Tablespace: 
--

CREATE TABLE lpr_history (
    id integer NOT NULL,
    srv_id integer NOT NULL,
    from_date timestamp without time zone NOT NULL,
    to_date timestamp without time zone
);


ALTER TABLE servers.lpr_history OWNER TO portal;

--
-- Name: TABLE lpr_history; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON TABLE lpr_history IS 'LPR History';


--
-- Name: COLUMN lpr_history.id; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN lpr_history.id IS 'Primary key';


--
-- Name: COLUMN lpr_history.srv_id; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN lpr_history.srv_id IS 'Server ID';


--
-- Name: COLUMN lpr_history.from_date; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN lpr_history.from_date IS 'From date';


--
-- Name: COLUMN lpr_history.to_date; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON COLUMN lpr_history.to_date IS 'To date';


--
-- Name: lpr_history_id_seq; Type: SEQUENCE; Schema: servers; Owner: portal
--

CREATE SEQUENCE lpr_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE servers.lpr_history_id_seq OWNER TO portal;

--
-- Name: lpr_history_id_seq; Type: SEQUENCE OWNED BY; Schema: servers; Owner: portal
--

ALTER SEQUENCE lpr_history_id_seq OWNED BY lpr_history.id;


--
-- Name: server_options_and_properties; Type: VIEW; Schema: servers; Owner: portal
--

CREATE VIEW server_options_and_properties AS
    SELECT l.id, g.name AS group_name, l.server AS server_name, l.ip, o.enabled, o.disabled_services, o.backup_type, l.type, l.s_id, o.date_added FROM list l, options o, groups g WHERE ((g.id = o.group_id) AND (l.id = o.srv_id));


ALTER TABLE servers.server_options_and_properties OWNER TO portal;

--
-- Name: VIEW server_options_and_properties; Type: COMMENT; Schema: servers; Owner: portal
--

COMMENT ON VIEW server_options_and_properties IS 'Shows all the information we have for each server.';


--
-- Name: show_groups_with_server_counts; Type: VIEW; Schema: servers; Owner: portal
--

CREATE VIEW show_groups_with_server_counts AS
    SELECT g.id, g.name, g.enabled, count(o.srv_id) AS server_count, sum(CASE WHEN o.enabled THEN 1 ELSE 0 END) AS enabled_count FROM (groups g LEFT JOIN options o ON ((g.id = o.group_id))) GROUP BY g.id, g.name, g.enabled;


ALTER TABLE servers.show_groups_with_server_counts OWNER TO portal;

--
-- Name: show_servers_with_options; Type: VIEW; Schema: servers; Owner: portal
--

CREATE VIEW show_servers_with_options AS
    SELECT o.srv_id, l.server, o.disabled_services, o.enabled, o.group_id FROM options o, list l WHERE (l.id = o.srv_id);


ALTER TABLE servers.show_servers_with_options OWNER TO portal;

SET search_path = servers_history, pg_catalog;

--
-- Name: group_delete_reasons; Type: TABLE; Schema: servers_history; Owner: portal; Tablespace: 
--

CREATE TABLE group_delete_reasons (
    h_id integer NOT NULL,
    comment text NOT NULL
);


ALTER TABLE servers_history.group_delete_reasons OWNER TO portal;

--
-- Name: TABLE group_delete_reasons; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON TABLE group_delete_reasons IS 'Contains the reasons for deleting groups.';


--
-- Name: COLUMN group_delete_reasons.h_id; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN group_delete_reasons.h_id IS 'history id';


--
-- Name: COLUMN group_delete_reasons.comment; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN group_delete_reasons.comment IS 'reason for deletion';


--
-- Name: groups; Type: TABLE; Schema: servers_history; Owner: portal; Tablespace: 
--

CREATE TABLE groups (
    h_id integer NOT NULL,
    h_date timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    enabled boolean NOT NULL,
    disabled_services integer[]
);


ALTER TABLE servers_history.groups OWNER TO portal;

--
-- Name: TABLE groups; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON TABLE groups IS 'Contains history for the servers.groups tables.';


--
-- Name: COLUMN groups.h_id; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN groups.h_id IS 'history id';


--
-- Name: COLUMN groups.h_date; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN groups.h_date IS 'date of the record';


--
-- Name: COLUMN groups.id; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN groups.id IS 'servers.groups id';


--
-- Name: COLUMN groups.name; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN groups.name IS 'servers.groups name';


--
-- Name: COLUMN groups.description; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN groups.description IS 'servers.groups description';


--
-- Name: COLUMN groups.enabled; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN groups.enabled IS 'servers.groups enabled';


--
-- Name: COLUMN groups.disabled_services; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN groups.disabled_services IS 'servers.groups disabled_services';


--
-- Name: groups_h_id_seq; Type: SEQUENCE; Schema: servers_history; Owner: portal
--

CREATE SEQUENCE groups_h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE servers_history.groups_h_id_seq OWNER TO portal;

--
-- Name: groups_h_id_seq; Type: SEQUENCE OWNED BY; Schema: servers_history; Owner: portal
--

ALTER SEQUENCE groups_h_id_seq OWNED BY groups.h_id;


--
-- Name: internal_reasons_table; Type: TABLE; Schema: servers_history; Owner: portal; Tablespace: 
--

CREATE TABLE internal_reasons_table (
    server_reason text,
    group_reason text
);


ALTER TABLE servers_history.internal_reasons_table OWNER TO portal;

--
-- Name: TABLE internal_reasons_table; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON TABLE internal_reasons_table IS 'Internal table containing the delete reasons for the next server to be deleted and the next group to be deleted. It must contain only one row.';


--
-- Name: COLUMN internal_reasons_table.server_reason; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN internal_reasons_table.server_reason IS 'Reason to delete the next server';


--
-- Name: COLUMN internal_reasons_table.group_reason; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN internal_reasons_table.group_reason IS 'Reason to delete the next group';


--
-- Name: list; Type: TABLE; Schema: servers_history; Owner: portal; Tablespace: 
--

CREATE TABLE list (
    h_id integer NOT NULL,
    h_date timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    server character varying(30) NOT NULL,
    type integer,
    ip inet NOT NULL,
    s_id integer
);


ALTER TABLE servers_history.list OWNER TO portal;

--
-- Name: TABLE list; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON TABLE list IS 'Contains history for the servers.list table.';


--
-- Name: COLUMN list.h_id; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN list.h_id IS 'history id';


--
-- Name: COLUMN list.h_date; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN list.h_date IS 'date added to history';


--
-- Name: COLUMN list.id; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN list.id IS 'servers.list id';


--
-- Name: COLUMN list.server; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN list.server IS 'server name from the list table';


--
-- Name: COLUMN list.type; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN list.type IS 'servers.list type';


--
-- Name: COLUMN list.ip; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN list.ip IS 'server.list ip';


--
-- Name: COLUMN list.s_id; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN list.s_id IS 'server.list s_id';


--
-- Name: list_h_id_seq; Type: SEQUENCE; Schema: servers_history; Owner: portal
--

CREATE SEQUENCE list_h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE servers_history.list_h_id_seq OWNER TO portal;

--
-- Name: list_h_id_seq; Type: SEQUENCE OWNED BY; Schema: servers_history; Owner: portal
--

ALTER SEQUENCE list_h_id_seq OWNED BY list.h_id;


--
-- Name: server_delete_reasons; Type: TABLE; Schema: servers_history; Owner: portal; Tablespace: 
--

CREATE TABLE server_delete_reasons (
    h_id integer NOT NULL,
    comment text NOT NULL
);


ALTER TABLE servers_history.server_delete_reasons OWNER TO portal;

--
-- Name: TABLE server_delete_reasons; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON TABLE server_delete_reasons IS 'Contains reasons for deleting servers';


--
-- Name: COLUMN server_delete_reasons.h_id; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN server_delete_reasons.h_id IS 'history id';


--
-- Name: COLUMN server_delete_reasons.comment; Type: COMMENT; Schema: servers_history; Owner: portal
--

COMMENT ON COLUMN server_delete_reasons.comment IS 'reason for deletion';


SET search_path = stats, pg_catalog;

--
-- Name: servers_traffic; Type: TABLE; Schema: stats; Owner: portal; Tablespace: 
--

CREATE TABLE servers_traffic (
    date date NOT NULL,
    server_id integer NOT NULL,
    in_pck bigint NOT NULL,
    out_pck bigint NOT NULL,
    in_bytes bigint NOT NULL,
    out_bytes bigint NOT NULL,
    in_usr bigint NOT NULL,
    out_usr bigint NOT NULL
);


ALTER TABLE stats.servers_traffic OWNER TO portal;

--
-- Name: TABLE servers_traffic; Type: COMMENT; Schema: stats; Owner: portal
--

COMMENT ON TABLE servers_traffic IS 'Contains information for the traffic of each of the servers for the last 30 days. Meant to be updated once a day with the values for the last 24 hours.';


--
-- Name: COLUMN servers_traffic.date; Type: COMMENT; Schema: stats; Owner: portal
--

COMMENT ON COLUMN servers_traffic.date IS 'date of the record';


--
-- Name: COLUMN servers_traffic.server_id; Type: COMMENT; Schema: stats; Owner: portal
--

COMMENT ON COLUMN servers_traffic.server_id IS 'id of the server for which the record is';


--
-- Name: COLUMN servers_traffic.in_pck; Type: COMMENT; Schema: stats; Owner: portal
--

COMMENT ON COLUMN servers_traffic.in_pck IS 'packets recieved';


--
-- Name: COLUMN servers_traffic.out_pck; Type: COMMENT; Schema: stats; Owner: portal
--

COMMENT ON COLUMN servers_traffic.out_pck IS 'packets sent';


--
-- Name: COLUMN servers_traffic.in_bytes; Type: COMMENT; Schema: stats; Owner: portal
--

COMMENT ON COLUMN servers_traffic.in_bytes IS 'bytes recieved';


--
-- Name: COLUMN servers_traffic.out_bytes; Type: COMMENT; Schema: stats; Owner: portal
--

COMMENT ON COLUMN servers_traffic.out_bytes IS 'bytes sent';


--
-- Name: COLUMN servers_traffic.in_usr; Type: COMMENT; Schema: stats; Owner: portal
--

COMMENT ON COLUMN servers_traffic.in_usr IS 'incomming user traffic';


--
-- Name: COLUMN servers_traffic.out_usr; Type: COMMENT; Schema: stats; Owner: portal
--

COMMENT ON COLUMN servers_traffic.out_usr IS 'outgoing user traffic';


SET search_path = monitoring, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: monitoring; Owner: portal
--

ALTER TABLE svc_status ALTER COLUMN id SET DEFAULT nextval('services_status_id_seq'::regclass);


SET search_path = problems, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: problems; Owner: portal
--

ALTER TABLE daily_stats ALTER COLUMN id SET DEFAULT nextval('daily_stats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: problems; Owner: portal
--

ALTER TABLE durations_24h ALTER COLUMN id SET DEFAULT nextval('dur_24h_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: problems; Owner: portal
--

ALTER TABLE durations_daily ALTER COLUMN id SET DEFAULT nextval('daily_dur_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: problems; Owner: portal
--

ALTER TABLE stats_24h ALTER COLUMN id SET DEFAULT nextval('"24h_stats_id_seq"'::regclass);


SET search_path = servers, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: servers; Owner: portal
--

ALTER TABLE groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: servers; Owner: portal
--

ALTER TABLE list ALTER COLUMN id SET DEFAULT nextval('list_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: servers; Owner: portal
--

ALTER TABLE lpr_history ALTER COLUMN id SET DEFAULT nextval('lpr_history_id_seq'::regclass);


SET search_path = servers_history, pg_catalog;

--
-- Name: h_id; Type: DEFAULT; Schema: servers_history; Owner: portal
--

ALTER TABLE groups ALTER COLUMN h_id SET DEFAULT nextval('groups_h_id_seq'::regclass);


--
-- Name: h_id; Type: DEFAULT; Schema: servers_history; Owner: portal
--

ALTER TABLE list ALTER COLUMN h_id SET DEFAULT nextval('list_h_id_seq'::regclass);


SET search_path = cpustats, pg_catalog;

--
-- Name: cpu_stats_date_key; Type: CONSTRAINT; Schema: cpustats; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY cpu_stats
    ADD CONSTRAINT cpu_stats_date_key UNIQUE (date, srv_id, stype);


--
-- Name: user_stats_server_key; Type: CONSTRAINT; Schema: cpustats; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY user_stats
    ADD CONSTRAINT user_stats_server_key UNIQUE (srv_id, username, stype);


SET search_path = hawk, pg_catalog;

--
-- Name: hourly_info_date_server_ukey; Type: CONSTRAINT; Schema: hawk; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY hourly_info
    ADD CONSTRAINT hourly_info_date_server_ukey UNIQUE (date, srv_id);


SET search_path = monitoring, pg_catalog;

--
-- Name: lags_pkey; Type: CONSTRAINT; Schema: monitoring; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY lags
    ADD CONSTRAINT lags_pkey PRIMARY KEY (srv_id);


--
-- Name: services_status_pkey; Type: CONSTRAINT; Schema: monitoring; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY svc_status
    ADD CONSTRAINT services_status_pkey PRIMARY KEY (id);


--
-- Name: svc_status_server_id_key; Type: CONSTRAINT; Schema: monitoring; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY svc_status
    ADD CONSTRAINT svc_status_server_id_key UNIQUE (srv_id);


SET search_path = problems, pg_catalog;

--
-- Name: 24h_stats_pkey; Type: CONSTRAINT; Schema: problems; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY stats_24h
    ADD CONSTRAINT "24h_stats_pkey" PRIMARY KEY (id);


--
-- Name: problems_durations_archive_pkey; Type: CONSTRAINT; Schema: problems; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY problems_durations_archive
    ADD CONSTRAINT problems_durations_archive_pkey PRIMARY KEY (id);


--
-- Name: service_downs_pkey; Type: CONSTRAINT; Schema: problems; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY service_downs
    ADD CONSTRAINT service_downs_pkey PRIMARY KEY (id);


SET search_path = servers, pg_catalog;

--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: servers; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: list_id; Type: CONSTRAINT; Schema: servers; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY list
    ADD CONSTRAINT list_id UNIQUE (id);


--
-- Name: list_pkey; Type: CONSTRAINT; Schema: servers; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY list
    ADD CONSTRAINT list_pkey PRIMARY KEY (id);


--
-- Name: list_server_id; Type: CONSTRAINT; Schema: servers; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY list
    ADD CONSTRAINT list_server_id UNIQUE (id, server);


--
-- Name: lpr_history_pkey; Type: CONSTRAINT; Schema: servers; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY lpr_history
    ADD CONSTRAINT lpr_history_pkey PRIMARY KEY (id);


--
-- Name: options_pkey; Type: CONSTRAINT; Schema: servers; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY options
    ADD CONSTRAINT options_pkey PRIMARY KEY (srv_id);


SET search_path = servers_history, pg_catalog;

--
-- Name: group_delete_reasons_pkey; Type: CONSTRAINT; Schema: servers_history; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY group_delete_reasons
    ADD CONSTRAINT group_delete_reasons_pkey PRIMARY KEY (h_id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: servers_history; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (h_id);


--
-- Name: list_pkey; Type: CONSTRAINT; Schema: servers_history; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY list
    ADD CONSTRAINT list_pkey PRIMARY KEY (h_id);


--
-- Name: server_delete_reasons_pkey; Type: CONSTRAINT; Schema: servers_history; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY server_delete_reasons
    ADD CONSTRAINT server_delete_reasons_pkey PRIMARY KEY (h_id);


SET search_path = stats, pg_catalog;

--
-- Name: date_server_id_ukey; Type: CONSTRAINT; Schema: stats; Owner: portal; Tablespace: 
--

ALTER TABLE ONLY servers_traffic
    ADD CONSTRAINT date_server_id_ukey UNIQUE (date, server_id);


SET search_path = hawk, pg_catalog;

--
-- Name: hourly_info_date_idx; Type: INDEX; Schema: hawk; Owner: portal; Tablespace: 
--

CREATE INDEX hourly_info_date_idx ON hourly_info USING btree (date);


--
-- Name: hourly_info_failed_brutes_blocked_idx; Type: INDEX; Schema: hawk; Owner: portal; Tablespace: 
--

CREATE INDEX hourly_info_failed_brutes_blocked_idx ON hourly_info USING btree (failed, brutes, blocked);


--
-- Name: hourly_info_server_idx; Type: INDEX; Schema: hawk; Owner: portal; Tablespace: 
--

CREATE INDEX hourly_info_server_idx ON hourly_info USING btree (srv_id);


SET search_path = monitoring, pg_catalog;

--
-- Name: srv_srv_index; Type: INDEX; Schema: monitoring; Owner: portal; Tablespace: 
--

CREATE INDEX srv_srv_index ON srv_status USING btree (srv_id);


SET search_path = problems, pg_catalog;

--
-- Name: active_down; Type: INDEX; Schema: problems; Owner: portal; Tablespace: 
--

CREATE INDEX active_down ON durations_24h USING btree (id, end_time);


--
-- Name: active_srv_down; Type: INDEX; Schema: problems; Owner: portal; Tablespace: 
--

CREATE INDEX active_srv_down ON durations_24h USING btree (srv_id, end_time);


--
-- Name: down_id; Type: INDEX; Schema: problems; Owner: portal; Tablespace: 
--

CREATE INDEX down_id ON durations_24h USING btree (id);


--
-- Name: durations_24h_date_idx; Type: INDEX; Schema: problems; Owner: portal; Tablespace: 
--

CREATE INDEX durations_24h_date_idx ON durations_24h USING btree (((start_time)::date));


--
-- Name: problems_durations_archive_date_idx; Type: INDEX; Schema: problems; Owner: portal; Tablespace: 
--

CREATE INDEX problems_durations_archive_date_idx ON problems_durations_archive USING btree (((start_time)::date));


--
-- Name: problems_durations_archive_srv_id_idx; Type: INDEX; Schema: problems; Owner: portal; Tablespace: 
--

CREATE INDEX problems_durations_archive_srv_id_idx ON problems_durations_archive USING btree (srv_id);


--
-- Name: problems_durations_archive_start_time_idx; Type: INDEX; Schema: problems; Owner: portal; Tablespace: 
--

CREATE INDEX problems_durations_archive_start_time_idx ON problems_durations_archive USING btree (start_time);


--
-- Name: problems_durations_archive_start_time_srv_id_idx; Type: INDEX; Schema: problems; Owner: portal; Tablespace: 
--

CREATE INDEX problems_durations_archive_start_time_srv_id_idx ON problems_durations_archive USING btree (start_time, srv_id);


--
-- Name: server_down_index; Type: INDEX; Schema: problems; Owner: portal; Tablespace: 
--

CREATE INDEX server_down_index ON durations_24h USING btree (srv_id);


--
-- Name: srv_id_index; Type: INDEX; Schema: problems; Owner: portal; Tablespace: 
--

CREATE INDEX srv_id_index ON daily_stats USING btree (srv_id);


SET search_path = servers, pg_catalog;

--
-- Name: genabled; Type: INDEX; Schema: servers; Owner: portal; Tablespace: 
--

CREATE INDEX genabled ON options USING btree (group_id, enabled);


--
-- Name: group_enabled; Type: INDEX; Schema: servers; Owner: portal; Tablespace: 
--

CREATE INDEX group_enabled ON groups USING btree (id, enabled);


--
-- Name: id; Type: INDEX; Schema: servers; Owner: portal; Tablespace: 
--

CREATE INDEX id ON list USING btree (id);


--
-- Name: lpr_date; Type: INDEX; Schema: servers; Owner: portal; Tablespace: 
--

CREATE INDEX lpr_date ON lpr USING btree (date);


--
-- Name: lpr_servid; Type: INDEX; Schema: servers; Owner: portal; Tablespace: 
--

CREATE INDEX lpr_servid ON lpr USING btree (servid);


--
-- Name: lpr_servid_date; Type: INDEX; Schema: servers; Owner: portal; Tablespace: 
--

CREATE INDEX lpr_servid_date ON lpr USING btree (servid, date);


--
-- Name: options.group_id_index; Type: INDEX; Schema: servers; Owner: portal; Tablespace: 
--

CREATE INDEX "options.group_id_index" ON options USING btree (group_id);


--
-- Name: options.srv_id_index; Type: INDEX; Schema: servers; Owner: portal; Tablespace: 
--

CREATE INDEX "options.srv_id_index" ON options USING btree (srv_id);


--
-- Name: server_index; Type: INDEX; Schema: servers; Owner: portal; Tablespace: 
--

CREATE INDEX server_index ON list USING btree (server);


--
-- Name: type; Type: INDEX; Schema: servers; Owner: portal; Tablespace: 
--

CREATE INDEX type ON list USING btree (type);


SET search_path = stats, pg_catalog;

--
-- Name: servers_traffic_date_idx; Type: INDEX; Schema: stats; Owner: portal; Tablespace: 
--

CREATE INDEX servers_traffic_date_idx ON servers_traffic USING btree (date);


--
-- Name: servers_traffic_server_id_idx; Type: INDEX; Schema: stats; Owner: portal; Tablespace: 
--

CREATE INDEX servers_traffic_server_id_idx ON servers_traffic USING btree (server_id);


SET search_path = monitoring, pg_catalog;

--
-- Name: update_lag; Type: TRIGGER; Schema: monitoring; Owner: portal
--

CREATE TRIGGER update_lag
    BEFORE UPDATE ON srv_status
    FOR EACH ROW
    EXECUTE PROCEDURE calc_delay();


SET search_path = servers, pg_catalog;

--
-- Name: log_history; Type: TRIGGER; Schema: servers; Owner: portal
--

CREATE TRIGGER log_history
    BEFORE DELETE OR UPDATE ON list
    FOR EACH ROW
    EXECUTE PROCEDURE maintain_list_hstory();


--
-- Name: log_history; Type: TRIGGER; Schema: servers; Owner: portal
--

CREATE TRIGGER log_history
    BEFORE DELETE OR UPDATE ON groups
    FOR EACH ROW
    EXECUTE PROCEDURE maintain_groups_history();


--
-- Name: lpr_history_trigger; Type: TRIGGER; Schema: servers; Owner: portal
--

CREATE TRIGGER lpr_history_trigger
    BEFORE INSERT OR UPDATE ON lpr
    FOR EACH ROW
    EXECUTE PROCEDURE lpr_history();


SET search_path = monitoring, pg_catalog;

--
-- Name: status_server_id_fkey; Type: FK CONSTRAINT; Schema: monitoring; Owner: portal
--

ALTER TABLE ONLY srv_status
    ADD CONSTRAINT status_server_id_fkey FOREIGN KEY (srv_id) REFERENCES servers.list(id) ON DELETE CASCADE;


SET search_path = problems, pg_catalog;

--
-- Name: durations_24h_srv_id_fkey; Type: FK CONSTRAINT; Schema: problems; Owner: portal
--

ALTER TABLE ONLY durations_24h
    ADD CONSTRAINT durations_24h_srv_id_fkey FOREIGN KEY (srv_id) REFERENCES servers.list(id) ON DELETE CASCADE;


--
-- Name: stats_24h_server_id_fkey; Type: FK CONSTRAINT; Schema: problems; Owner: portal
--

ALTER TABLE ONLY stats_24h
    ADD CONSTRAINT stats_24h_server_id_fkey FOREIGN KEY (server_id) REFERENCES servers.list(id) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = servers, pg_catalog;

--
-- Name: disk_usage_servid_fkey; Type: FK CONSTRAINT; Schema: servers; Owner: portal
--

ALTER TABLE ONLY disk_usage
    ADD CONSTRAINT disk_usage_servid_fkey FOREIGN KEY (servid) REFERENCES list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lpr_servid_fkey; Type: FK CONSTRAINT; Schema: servers; Owner: portal
--

ALTER TABLE ONLY lpr
    ADD CONSTRAINT lpr_servid_fkey FOREIGN KEY (servid) REFERENCES list(id) ON DELETE CASCADE;


--
-- Name: options_group_id_fkey; Type: FK CONSTRAINT; Schema: servers; Owner: portal
--

ALTER TABLE ONLY options
    ADD CONSTRAINT options_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: options_srv_id_fkey; Type: FK CONSTRAINT; Schema: servers; Owner: portal
--

ALTER TABLE ONLY options
    ADD CONSTRAINT options_srv_id_fkey FOREIGN KEY (srv_id) REFERENCES list(id) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = servers_history, pg_catalog;

--
-- Name: history_id_fkey; Type: FK CONSTRAINT; Schema: servers_history; Owner: portal
--

ALTER TABLE ONLY group_delete_reasons
    ADD CONSTRAINT history_id_fkey FOREIGN KEY (h_id) REFERENCES groups(h_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: history_id_fkey; Type: FK CONSTRAINT; Schema: servers_history; Owner: portal
--

ALTER TABLE ONLY server_delete_reasons
    ADD CONSTRAINT history_id_fkey FOREIGN KEY (h_id) REFERENCES list(h_id) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = stats, pg_catalog;

--
-- Name: server_id_fkey; Type: FK CONSTRAINT; Schema: stats; Owner: portal
--

ALTER TABLE ONLY servers_traffic
    ADD CONSTRAINT server_id_fkey FOREIGN KEY (server_id) REFERENCES servers.list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cpustats; Type: ACL; Schema: -; Owner: portal
--

REVOKE ALL ON SCHEMA cpustats FROM PUBLIC;
REVOKE ALL ON SCHEMA cpustats FROM portal;
GRANT ALL ON SCHEMA cpustats TO portal;
GRANT USAGE ON SCHEMA cpustats TO cpustats;


--
-- Name: hawk; Type: ACL; Schema: -; Owner: portal
--

REVOKE ALL ON SCHEMA hawk FROM PUBLIC;
REVOKE ALL ON SCHEMA hawk FROM portal;
GRANT ALL ON SCHEMA hawk TO portal;
GRANT USAGE ON SCHEMA hawk TO hawk;


--
-- Name: monitoring; Type: ACL; Schema: -; Owner: portal
--

REVOKE ALL ON SCHEMA monitoring FROM PUBLIC;
REVOKE ALL ON SCHEMA monitoring FROM portal;
GRANT ALL ON SCHEMA monitoring TO portal;
GRANT USAGE ON SCHEMA monitoring TO web_mon;
GRANT USAGE ON SCHEMA monitoring TO lprstats;


--
-- Name: problems; Type: ACL; Schema: -; Owner: portal
--

REVOKE ALL ON SCHEMA problems FROM PUBLIC;
REVOKE ALL ON SCHEMA problems FROM portal;
GRANT ALL ON SCHEMA problems TO portal;
GRANT USAGE ON SCHEMA problems TO downstats;


--
-- Name: public; Type: ACL; Schema: -; Owner: portal
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM portal;
GRANT ALL ON SCHEMA public TO portal;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: quotastats; Type: ACL; Schema: -; Owner: portal
--

REVOKE ALL ON SCHEMA quotastats FROM PUBLIC;
REVOKE ALL ON SCHEMA quotastats FROM portal;
GRANT ALL ON SCHEMA quotastats TO portal;
GRANT USAGE ON SCHEMA quotastats TO quotastats;


--
-- Name: servers; Type: ACL; Schema: -; Owner: portal
--

REVOKE ALL ON SCHEMA servers FROM PUBLIC;
REVOKE ALL ON SCHEMA servers FROM portal;
GRANT ALL ON SCHEMA servers TO portal;
GRANT USAGE ON SCHEMA servers TO lprstats;
GRANT USAGE ON SCHEMA servers TO web_mon;
GRANT USAGE ON SCHEMA servers TO downstats;
GRANT USAGE ON SCHEMA servers TO cpustats;
GRANT USAGE ON SCHEMA servers TO quotastats;
GRANT USAGE ON SCHEMA servers TO hawk;


--
-- Name: servers_history; Type: ACL; Schema: -; Owner: portal
--

REVOKE ALL ON SCHEMA servers_history FROM PUBLIC;
REVOKE ALL ON SCHEMA servers_history FROM portal;
GRANT ALL ON SCHEMA servers_history TO portal;


--
-- Name: stats; Type: ACL; Schema: -; Owner: portal
--

REVOKE ALL ON SCHEMA stats FROM PUBLIC;
REVOKE ALL ON SCHEMA stats FROM portal;
GRANT ALL ON SCHEMA stats TO portal;
GRANT USAGE ON SCHEMA stats TO lprstats;


SET search_path = monitoring, pg_catalog;

--
-- Name: calc_delay(); Type: ACL; Schema: monitoring; Owner: portal
--

REVOKE ALL ON FUNCTION calc_delay() FROM PUBLIC;
REVOKE ALL ON FUNCTION calc_delay() FROM portal;
GRANT ALL ON FUNCTION calc_delay() TO portal;
GRANT ALL ON FUNCTION calc_delay() TO PUBLIC;


--
-- Name: disable_server(integer); Type: ACL; Schema: monitoring; Owner: portal
--

REVOKE ALL ON FUNCTION disable_server(server integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION disable_server(server integer) FROM portal;
GRANT ALL ON FUNCTION disable_server(server integer) TO portal;
GRANT ALL ON FUNCTION disable_server(server integer) TO PUBLIC;


SET search_path = problems, pg_catalog;

--
-- Name: end_down(integer); Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON FUNCTION end_down(srv integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION end_down(srv integer) FROM portal;
GRANT ALL ON FUNCTION end_down(srv integer) TO portal;
GRANT ALL ON FUNCTION end_down(srv integer) TO PUBLIC;


--
-- Name: get_server_type_averages(date, integer[], integer, integer, character varying, character varying); Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON FUNCTION get_server_type_averages(search_date date, server_groups integer[], page_start integer, page_limit integer, searched_server character varying, sort_column character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION get_server_type_averages(search_date date, server_groups integer[], page_start integer, page_limit integer, searched_server character varying, sort_column character varying) FROM portal;
GRANT ALL ON FUNCTION get_server_type_averages(search_date date, server_groups integer[], page_start integer, page_limit integer, searched_server character varying, sort_column character varying) TO portal;
GRANT ALL ON FUNCTION get_server_type_averages(search_date date, server_groups integer[], page_start integer, page_limit integer, searched_server character varying, sort_column character varying) TO PUBLIC;
GRANT ALL ON FUNCTION get_server_type_averages(search_date date, server_groups integer[], page_start integer, page_limit integer, searched_server character varying, sort_column character varying) TO downstats;


SET search_path = servers, pg_catalog;

--
-- Name: delete_group(integer[], text); Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON FUNCTION delete_group(group_ids integer[], reason text) FROM PUBLIC;
REVOKE ALL ON FUNCTION delete_group(group_ids integer[], reason text) FROM portal;
GRANT ALL ON FUNCTION delete_group(group_ids integer[], reason text) TO portal;
GRANT ALL ON FUNCTION delete_group(group_ids integer[], reason text) TO PUBLIC;


--
-- Name: delete_server(integer[], text); Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON FUNCTION delete_server(srv_ids integer[], reason text) FROM PUBLIC;
REVOKE ALL ON FUNCTION delete_server(srv_ids integer[], reason text) FROM portal;
GRANT ALL ON FUNCTION delete_server(srv_ids integer[], reason text) TO portal;
GRANT ALL ON FUNCTION delete_server(srv_ids integer[], reason text) TO PUBLIC;


--
-- Name: import_group(character varying, text, boolean, integer[]); Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON FUNCTION import_group(group_name character varying, group_description text, is_enabled boolean, disabled_svcs integer[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION import_group(group_name character varying, group_description text, is_enabled boolean, disabled_svcs integer[]) FROM portal;
GRANT ALL ON FUNCTION import_group(group_name character varying, group_description text, is_enabled boolean, disabled_svcs integer[]) TO portal;
GRANT ALL ON FUNCTION import_group(group_name character varying, group_description text, is_enabled boolean, disabled_svcs integer[]) TO PUBLIC;


--
-- Name: import_server(integer, character varying, inet, boolean, integer, integer, integer, integer[]); Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON FUNCTION import_server(grp_id integer, srv_name character varying, srv_ip inet, is_enabled boolean, srv_backup_type integer, srv_type integer, srv_s_id integer, disabled_svcs integer[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION import_server(grp_id integer, srv_name character varying, srv_ip inet, is_enabled boolean, srv_backup_type integer, srv_type integer, srv_s_id integer, disabled_svcs integer[]) FROM portal;
GRANT ALL ON FUNCTION import_server(grp_id integer, srv_name character varying, srv_ip inet, is_enabled boolean, srv_backup_type integer, srv_type integer, srv_s_id integer, disabled_svcs integer[]) TO portal;
GRANT ALL ON FUNCTION import_server(grp_id integer, srv_name character varying, srv_ip inet, is_enabled boolean, srv_backup_type integer, srv_type integer, srv_s_id integer, disabled_svcs integer[]) TO PUBLIC;


--
-- Name: insert_machine(integer, integer, character varying, character varying, inet, character varying, inet, integer, integer, inet, character varying, character varying); Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON FUNCTION insert_machine(rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, r_ip inet, r_user character varying, r_pass character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION insert_machine(rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, r_ip inet, r_user character varying, r_pass character varying) FROM portal;
GRANT ALL ON FUNCTION insert_machine(rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, r_ip inet, r_user character varying, r_pass character varying) TO portal;
GRANT ALL ON FUNCTION insert_machine(rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, r_ip inet, r_user character varying, r_pass character varying) TO PUBLIC;


--
-- Name: update_machine(integer, integer, integer, character varying, character varying, inet, character varying, inet, integer, integer, text, inet, character varying, character varying); Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON FUNCTION update_machine(machine_id integer, rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, srv_whm text, r_ip inet, r_user character varying, r_pass character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION update_machine(machine_id integer, rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, srv_whm text, r_ip inet, r_user character varying, r_pass character varying) FROM portal;
GRANT ALL ON FUNCTION update_machine(machine_id integer, rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, srv_whm text, r_ip inet, r_user character varying, r_pass character varying) TO portal;
GRANT ALL ON FUNCTION update_machine(machine_id integer, rack_id integer, slot_num integer, server_name character varying, ns1name character varying, ns1ip inet, ns2name character varying, ns2ip inet, srv_type integer, srv_usb integer, srv_whm text, r_ip inet, r_user character varying, r_pass character varying) TO PUBLIC;


SET search_path = cpustats, pg_catalog;

--
-- Name: cpu_stats; Type: ACL; Schema: cpustats; Owner: portal
--

REVOKE ALL ON TABLE cpu_stats FROM PUBLIC;
REVOKE ALL ON TABLE cpu_stats FROM portal;
GRANT ALL ON TABLE cpu_stats TO portal;
GRANT ALL ON TABLE cpu_stats TO cpustats;


SET search_path = servers, pg_catalog;

--
-- Name: list; Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON TABLE list FROM PUBLIC;
REVOKE ALL ON TABLE list FROM portal;
GRANT ALL ON TABLE list TO portal;
GRANT SELECT ON TABLE list TO lprstats;
GRANT SELECT,REFERENCES ON TABLE list TO web_mon;
GRANT SELECT ON TABLE list TO downstats;
GRANT SELECT ON TABLE list TO cpustats;
GRANT SELECT ON TABLE list TO quotastats;
GRANT SELECT ON TABLE list TO hawk;


SET search_path = cpustats, pg_catalog;

--
-- Name: daily_min_max_values; Type: ACL; Schema: cpustats; Owner: portal
--

REVOKE ALL ON TABLE daily_min_max_values FROM PUBLIC;
REVOKE ALL ON TABLE daily_min_max_values FROM portal;
GRANT ALL ON TABLE daily_min_max_values TO portal;
GRANT ALL ON TABLE daily_min_max_values TO cpustats;


--
-- Name: user_stats; Type: ACL; Schema: cpustats; Owner: portal
--

REVOKE ALL ON TABLE user_stats FROM PUBLIC;
REVOKE ALL ON TABLE user_stats FROM portal;
GRANT ALL ON TABLE user_stats TO portal;
GRANT ALL ON TABLE user_stats TO cpustats;


--
-- Name: user_min_max_values; Type: ACL; Schema: cpustats; Owner: portal
--

REVOKE ALL ON TABLE user_min_max_values FROM PUBLIC;
REVOKE ALL ON TABLE user_min_max_values FROM portal;
GRANT ALL ON TABLE user_min_max_values TO portal;
GRANT ALL ON TABLE user_min_max_values TO cpustats;


SET search_path = hawk, pg_catalog;

--
-- Name: hourly_info; Type: ACL; Schema: hawk; Owner: portal
--

REVOKE ALL ON TABLE hourly_info FROM PUBLIC;
REVOKE ALL ON TABLE hourly_info FROM portal;
GRANT ALL ON TABLE hourly_info TO portal;
GRANT ALL ON TABLE hourly_info TO hawk;


--
-- Name: daily_min_max_values; Type: ACL; Schema: hawk; Owner: portal
--

REVOKE ALL ON TABLE daily_min_max_values FROM PUBLIC;
REVOKE ALL ON TABLE daily_min_max_values FROM portal;
GRANT ALL ON TABLE daily_min_max_values TO portal;
GRANT ALL ON TABLE daily_min_max_values TO hawk;


--
-- Name: stats_all_servers; Type: ACL; Schema: hawk; Owner: portal
--

REVOKE ALL ON TABLE stats_all_servers FROM PUBLIC;
REVOKE ALL ON TABLE stats_all_servers FROM portal;
GRANT ALL ON TABLE stats_all_servers TO portal;
GRANT ALL ON TABLE stats_all_servers TO hawk;


SET search_path = monitoring, pg_catalog;

--
-- Name: lags; Type: ACL; Schema: monitoring; Owner: portal
--

REVOKE ALL ON TABLE lags FROM PUBLIC;
REVOKE ALL ON TABLE lags FROM portal;
GRANT ALL ON TABLE lags TO portal;


SET search_path = servers, pg_catalog;

--
-- Name: groups; Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON TABLE groups FROM PUBLIC;
REVOKE ALL ON TABLE groups FROM portal;
GRANT ALL ON TABLE groups TO portal;
GRANT SELECT,REFERENCES ON TABLE groups TO web_mon;


--
-- Name: options; Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON TABLE options FROM PUBLIC;
REVOKE ALL ON TABLE options FROM portal;
GRANT ALL ON TABLE options TO portal;
GRANT SELECT,INSERT,UPDATE ON TABLE options TO lprstats;
GRANT SELECT ON TABLE options TO downstats;
GRANT SELECT ON TABLE options TO cpustats;
GRANT SELECT ON TABLE options TO quotastats;
GRANT SELECT ON TABLE options TO hawk;


SET search_path = monitoring, pg_catalog;

--
-- Name: servers; Type: ACL; Schema: monitoring; Owner: portal
--

REVOKE ALL ON TABLE servers FROM PUBLIC;
REVOKE ALL ON TABLE servers FROM portal;
GRANT ALL ON TABLE servers TO portal;


--
-- Name: svc_status; Type: ACL; Schema: monitoring; Owner: portal
--

REVOKE ALL ON TABLE svc_status FROM PUBLIC;
REVOKE ALL ON TABLE svc_status FROM portal;
GRANT ALL ON TABLE svc_status TO portal;
GRANT SELECT,REFERENCES ON TABLE svc_status TO web_mon;


--
-- Name: services_status_id_seq; Type: ACL; Schema: monitoring; Owner: portal
--

REVOKE ALL ON SEQUENCE services_status_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE services_status_id_seq FROM portal;
GRANT ALL ON SEQUENCE services_status_id_seq TO portal;


--
-- Name: srv_status; Type: ACL; Schema: monitoring; Owner: portal
--

REVOKE ALL ON TABLE srv_status FROM PUBLIC;
REVOKE ALL ON TABLE srv_status FROM portal;
GRANT ALL ON TABLE srv_status TO portal;
GRANT SELECT,REFERENCES ON TABLE srv_status TO web_mon;
GRANT SELECT ON TABLE srv_status TO lprstats;


--
-- Name: sg_statuses; Type: ACL; Schema: monitoring; Owner: portal
--

REVOKE ALL ON TABLE sg_statuses FROM PUBLIC;
REVOKE ALL ON TABLE sg_statuses FROM portal;
GRANT ALL ON TABLE sg_statuses TO portal;
GRANT SELECT,REFERENCES,TRIGGER ON TABLE sg_statuses TO web_mon;


--
-- Name: sg_statuses2; Type: ACL; Schema: monitoring; Owner: portal
--

REVOKE ALL ON TABLE sg_statuses2 FROM PUBLIC;
REVOKE ALL ON TABLE sg_statuses2 FROM portal;
GRANT ALL ON TABLE sg_statuses2 TO portal;
GRANT SELECT,REFERENCES ON TABLE sg_statuses2 TO web_mon;


SET search_path = problems, pg_catalog;

--
-- Name: durations_24h; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE durations_24h FROM PUBLIC;
REVOKE ALL ON TABLE durations_24h FROM portal;
GRANT ALL ON TABLE durations_24h TO portal;
GRANT SELECT,DELETE,UPDATE ON TABLE durations_24h TO downstats;


SET search_path = monitoring, pg_catalog;

--
-- Name: show_problems; Type: ACL; Schema: monitoring; Owner: portal
--

REVOKE ALL ON TABLE show_problems FROM PUBLIC;
REVOKE ALL ON TABLE show_problems FROM portal;
GRANT ALL ON TABLE show_problems TO portal;
GRANT SELECT,REFERENCES ON TABLE show_problems TO web_mon;


--
-- Name: show_problems2; Type: ACL; Schema: monitoring; Owner: portal
--

REVOKE ALL ON TABLE show_problems2 FROM PUBLIC;
REVOKE ALL ON TABLE show_problems2 FROM portal;
GRANT ALL ON TABLE show_problems2 TO portal;
GRANT SELECT,REFERENCES ON TABLE show_problems2 TO web_mon;


SET search_path = problems, pg_catalog;

--
-- Name: stats_24h; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE stats_24h FROM PUBLIC;
REVOKE ALL ON TABLE stats_24h FROM portal;
GRANT ALL ON TABLE stats_24h TO portal;


--
-- Name: 24h_stats_id_seq; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON SEQUENCE "24h_stats_id_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "24h_stats_id_seq" FROM portal;
GRANT ALL ON SEQUENCE "24h_stats_id_seq" TO portal;


--
-- Name: durations_daily; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE durations_daily FROM PUBLIC;
REVOKE ALL ON TABLE durations_daily FROM portal;
GRANT ALL ON TABLE durations_daily TO portal;


--
-- Name: daily_dur_id_seq; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON SEQUENCE daily_dur_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE daily_dur_id_seq FROM portal;
GRANT ALL ON SEQUENCE daily_dur_id_seq TO portal;


--
-- Name: daily_stats; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE daily_stats FROM PUBLIC;
REVOKE ALL ON TABLE daily_stats FROM portal;
GRANT ALL ON TABLE daily_stats TO portal;


--
-- Name: daily_stats_id_seq; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON SEQUENCE daily_stats_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE daily_stats_id_seq FROM portal;
GRANT ALL ON SEQUENCE daily_stats_id_seq TO portal;


--
-- Name: dur_24h_id_seq; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON SEQUENCE dur_24h_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dur_24h_id_seq FROM portal;
GRANT ALL ON SEQUENCE dur_24h_id_seq TO portal;


--
-- Name: problems_durations_archive; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE problems_durations_archive FROM PUBLIC;
REVOKE ALL ON TABLE problems_durations_archive FROM portal;
GRANT ALL ON TABLE problems_durations_archive TO portal;
GRANT SELECT,INSERT ON TABLE problems_durations_archive TO downstats;


--
-- Name: service_downs; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE service_downs FROM PUBLIC;
REVOKE ALL ON TABLE service_downs FROM portal;
GRANT ALL ON TABLE service_downs TO portal;


--
-- Name: show_active_durations_with_server_group; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_active_durations_with_server_group FROM PUBLIC;
REVOKE ALL ON TABLE show_active_durations_with_server_group FROM portal;
GRANT ALL ON TABLE show_active_durations_with_server_group TO portal;
GRANT SELECT ON TABLE show_active_durations_with_server_group TO downstats;


--
-- Name: show_downs_without_comments; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_downs_without_comments FROM PUBLIC;
REVOKE ALL ON TABLE show_downs_without_comments FROM portal;
GRANT ALL ON TABLE show_downs_without_comments TO portal;
GRANT SELECT ON TABLE show_downs_without_comments TO downstats;


--
-- Name: show_last24h_downs; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_last24h_downs FROM PUBLIC;
REVOKE ALL ON TABLE show_last24h_downs FROM portal;
GRANT ALL ON TABLE show_last24h_downs TO portal;
GRANT SELECT ON TABLE show_last24h_downs TO downstats;


--
-- Name: show_last24h_downs_by_server; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_last24h_downs_by_server FROM PUBLIC;
REVOKE ALL ON TABLE show_last24h_downs_by_server FROM portal;
GRANT ALL ON TABLE show_last24h_downs_by_server TO portal;
GRANT SELECT ON TABLE show_last24h_downs_by_server TO downstats;
GRANT SELECT ON TABLE show_last24h_downs_by_server TO lprstats;


--
-- Name: show_last24h_downs_by_server_and_type; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_last24h_downs_by_server_and_type FROM PUBLIC;
REVOKE ALL ON TABLE show_last24h_downs_by_server_and_type FROM portal;
GRANT ALL ON TABLE show_last24h_downs_by_server_and_type TO portal;
GRANT SELECT ON TABLE show_last24h_downs_by_server_and_type TO downstats;


--
-- Name: show_last24h_downs_by_server_group_and_type; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_last24h_downs_by_server_group_and_type FROM PUBLIC;
REVOKE ALL ON TABLE show_last24h_downs_by_server_group_and_type FROM portal;
GRANT ALL ON TABLE show_last24h_downs_by_server_group_and_type TO portal;
GRANT SELECT ON TABLE show_last24h_downs_by_server_group_and_type TO downstats;


--
-- Name: show_last24h_downs_by_server_id; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_last24h_downs_by_server_id FROM PUBLIC;
REVOKE ALL ON TABLE show_last24h_downs_by_server_id FROM portal;
GRANT ALL ON TABLE show_last24h_downs_by_server_id TO portal;


--
-- Name: show_last24h_downs_local; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_last24h_downs_local FROM PUBLIC;
REVOKE ALL ON TABLE show_last24h_downs_local FROM portal;
GRANT ALL ON TABLE show_last24h_downs_local TO portal;
GRANT ALL ON TABLE show_last24h_downs_local TO downstats;


--
-- Name: show_old_downs; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_old_downs FROM PUBLIC;
REVOKE ALL ON TABLE show_old_downs FROM portal;
GRANT ALL ON TABLE show_old_downs TO portal;
GRANT ALL ON TABLE show_old_downs TO downstats;


--
-- Name: show_old_downs_by_date_and_server; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_old_downs_by_date_and_server FROM PUBLIC;
REVOKE ALL ON TABLE show_old_downs_by_date_and_server FROM portal;
GRANT ALL ON TABLE show_old_downs_by_date_and_server TO portal;
GRANT SELECT ON TABLE show_old_downs_by_date_and_server TO downstats;


--
-- Name: show_old_downs_by_date_server_and_type; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_old_downs_by_date_server_and_type FROM PUBLIC;
REVOKE ALL ON TABLE show_old_downs_by_date_server_and_type FROM portal;
GRANT ALL ON TABLE show_old_downs_by_date_server_and_type TO portal;
GRANT SELECT ON TABLE show_old_downs_by_date_server_and_type TO downstats;


--
-- Name: show_old_downs_by_date_server_group_and_type; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_old_downs_by_date_server_group_and_type FROM PUBLIC;
REVOKE ALL ON TABLE show_old_downs_by_date_server_group_and_type FROM portal;
GRANT ALL ON TABLE show_old_downs_by_date_server_group_and_type TO portal;
GRANT SELECT ON TABLE show_old_downs_by_date_server_group_and_type TO downstats;


--
-- Name: show_old_downs_local; Type: ACL; Schema: problems; Owner: portal
--

REVOKE ALL ON TABLE show_old_downs_local FROM PUBLIC;
REVOKE ALL ON TABLE show_old_downs_local FROM portal;
GRANT ALL ON TABLE show_old_downs_local TO portal;
GRANT ALL ON TABLE show_old_downs_local TO downstats;


SET search_path = quotastats, pg_catalog;

--
-- Name: disk_usage; Type: ACL; Schema: quotastats; Owner: portal
--

REVOKE ALL ON TABLE disk_usage FROM PUBLIC;
REVOKE ALL ON TABLE disk_usage FROM portal;
GRANT ALL ON TABLE disk_usage TO portal;
GRANT ALL ON TABLE disk_usage TO quotastats;


--
-- Name: disk_min_max_values; Type: ACL; Schema: quotastats; Owner: portal
--

REVOKE ALL ON TABLE disk_min_max_values FROM PUBLIC;
REVOKE ALL ON TABLE disk_min_max_values FROM portal;
GRANT ALL ON TABLE disk_min_max_values TO portal;
GRANT ALL ON TABLE disk_min_max_values TO quotastats;


--
-- Name: user_usage; Type: ACL; Schema: quotastats; Owner: portal
--

REVOKE ALL ON TABLE user_usage FROM PUBLIC;
REVOKE ALL ON TABLE user_usage FROM portal;
GRANT ALL ON TABLE user_usage TO portal;
GRANT ALL ON TABLE user_usage TO quotastats;


--
-- Name: user_min_max_values; Type: ACL; Schema: quotastats; Owner: portal
--

REVOKE ALL ON TABLE user_min_max_values FROM PUBLIC;
REVOKE ALL ON TABLE user_min_max_values FROM portal;
GRANT ALL ON TABLE user_min_max_values TO portal;
GRANT ALL ON TABLE user_min_max_values TO quotastats;


SET search_path = servers, pg_catalog;

--
-- Name: disk_usage; Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON TABLE disk_usage FROM PUBLIC;
REVOKE ALL ON TABLE disk_usage FROM portal;
GRANT ALL ON TABLE disk_usage TO portal;


--
-- Name: groups_id_seq; Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON SEQUENCE groups_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE groups_id_seq FROM portal;
GRANT ALL ON SEQUENCE groups_id_seq TO portal;


--
-- Name: list_id_seq; Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON SEQUENCE list_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE list_id_seq FROM portal;
GRANT ALL ON SEQUENCE list_id_seq TO portal;


--
-- Name: lpr; Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON TABLE lpr FROM PUBLIC;
REVOKE ALL ON TABLE lpr FROM portal;
GRANT ALL ON TABLE lpr TO portal;


--
-- Name: lpr_history; Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON TABLE lpr_history FROM PUBLIC;
REVOKE ALL ON TABLE lpr_history FROM portal;
GRANT ALL ON TABLE lpr_history TO portal;


--
-- Name: lpr_history_id_seq; Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON SEQUENCE lpr_history_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE lpr_history_id_seq FROM portal;
GRANT ALL ON SEQUENCE lpr_history_id_seq TO portal;


--
-- Name: server_options_and_properties; Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON TABLE server_options_and_properties FROM PUBLIC;
REVOKE ALL ON TABLE server_options_and_properties FROM portal;
GRANT ALL ON TABLE server_options_and_properties TO portal;


--
-- Name: show_groups_with_server_counts; Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON TABLE show_groups_with_server_counts FROM PUBLIC;
REVOKE ALL ON TABLE show_groups_with_server_counts FROM portal;
GRANT ALL ON TABLE show_groups_with_server_counts TO portal;


--
-- Name: show_servers_with_options; Type: ACL; Schema: servers; Owner: portal
--

REVOKE ALL ON TABLE show_servers_with_options FROM PUBLIC;
REVOKE ALL ON TABLE show_servers_with_options FROM portal;
GRANT ALL ON TABLE show_servers_with_options TO portal;


SET search_path = servers_history, pg_catalog;

--
-- Name: group_delete_reasons; Type: ACL; Schema: servers_history; Owner: portal
--

REVOKE ALL ON TABLE group_delete_reasons FROM PUBLIC;
REVOKE ALL ON TABLE group_delete_reasons FROM portal;
GRANT ALL ON TABLE group_delete_reasons TO portal;


--
-- Name: groups; Type: ACL; Schema: servers_history; Owner: portal
--

REVOKE ALL ON TABLE groups FROM PUBLIC;
REVOKE ALL ON TABLE groups FROM portal;
GRANT ALL ON TABLE groups TO portal;


--
-- Name: groups_h_id_seq; Type: ACL; Schema: servers_history; Owner: portal
--

REVOKE ALL ON SEQUENCE groups_h_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE groups_h_id_seq FROM portal;
GRANT ALL ON SEQUENCE groups_h_id_seq TO portal;


--
-- Name: internal_reasons_table; Type: ACL; Schema: servers_history; Owner: portal
--

REVOKE ALL ON TABLE internal_reasons_table FROM PUBLIC;
REVOKE ALL ON TABLE internal_reasons_table FROM portal;
GRANT ALL ON TABLE internal_reasons_table TO portal;


--
-- Name: list; Type: ACL; Schema: servers_history; Owner: portal
--

REVOKE ALL ON TABLE list FROM PUBLIC;
REVOKE ALL ON TABLE list FROM portal;
GRANT ALL ON TABLE list TO portal;


--
-- Name: list_h_id_seq; Type: ACL; Schema: servers_history; Owner: portal
--

REVOKE ALL ON SEQUENCE list_h_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE list_h_id_seq FROM portal;
GRANT ALL ON SEQUENCE list_h_id_seq TO portal;


--
-- Name: server_delete_reasons; Type: ACL; Schema: servers_history; Owner: portal
--

REVOKE ALL ON TABLE server_delete_reasons FROM PUBLIC;
REVOKE ALL ON TABLE server_delete_reasons FROM portal;
GRANT ALL ON TABLE server_delete_reasons TO portal;


SET search_path = stats, pg_catalog;

--
-- Name: servers_traffic; Type: ACL; Schema: stats; Owner: portal
--

REVOKE ALL ON TABLE servers_traffic FROM PUBLIC;
REVOKE ALL ON TABLE servers_traffic FROM portal;
GRANT ALL ON TABLE servers_traffic TO portal;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE servers_traffic TO lprstats;


--
-- PostgreSQL database dump complete
--

