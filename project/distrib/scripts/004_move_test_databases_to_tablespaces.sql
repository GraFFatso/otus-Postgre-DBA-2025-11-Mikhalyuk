\timing on
\echo 'move stat_acc_other'
ALTER DATABASE stat_acc_other 			SET TABLESPACE v81c_data \g
\c stat_acc_other
ALTER INDEX ALL IN TABLESPACE v81c_data 	SET TABLESPACE v81c_index \g


\echo 'move stat_alfa_invent'
ALTER DATABASE stat_alfa_invent 		SET TABLESPACE v81c_data \g
\c stat_alfa_invent
ALTER INDEX ALL IN TABLESPACE v81c_data 	SET TABLESPACE v81c_index \g

\echo 'move stat_erp_demo'
ALTER DATABASE stat_erp_demo			SET TABLESPACE v81c_data \g
\c stat_erp_demo
ALTER INDEX ALL IN TABLESPACE v81c_data 	SET TABLESPACE v81c_index \g

\echo 'move test'
ALTER DATABASE test			SET TABLESPACE v81c_data \g
\c test
ALTER INDEX ALL IN TABLESPACE v81c_data 	SET TABLESPACE v81c_index \g

\echo 'move test_stat_acc_3'
ALTER DATABASE test_stat_acc_3			SET TABLESPACE v81c_data \g
\c test_stat_acc_3
ALTER INDEX ALL IN TABLESPACE v81c_data 	SET TABLESPACE v81c_index \g

\echo 'move test_stat_alfa'
ALTER DATABASE test_stat_alfa			SET TABLESPACE v81c_data \g
\c test_stat_alfa
ALTER INDEX ALL IN TABLESPACE v81c_data 	SET TABLESPACE v81c_index \g


\echo 'move test_stat_hrm_3'
ALTER DATABASE test_stat_hrm_3			SET TABLESPACE v81c_data \g
\c test_stat_hrm_3
ALTER INDEX ALL IN TABLESPACE v81c_data 	SET TABLESPACE v81c_index \g

\echo 'move test_sync_stat_acc_3'
ALTER DATABASE test_sync_stat_acc_3			SET TABLESPACE v81c_data \g
\c test_stat_acc_3
ALTER INDEX ALL IN TABLESPACE v81c_data 	SET TABLESPACE v81c_index \g

\echo 'move test_sync_stat_alfa'
ALTER DATABASE test_sync_stat_alfa			SET TABLESPACE v81c_data \g
\c test_sync_stat_alfa
ALTER INDEX ALL IN TABLESPACE v81c_data 	SET TABLESPACE v81c_index \g

\timing off