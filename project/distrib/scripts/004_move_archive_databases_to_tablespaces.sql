ALTER DATABASE acc_3_stat_archive SET TABLESPACE v81c_data \g
\c acc_3_stat_archive
ALTER INDEX ALL IN TABLESPACE v81c_data SET TABLESPACE v81c_index \g

ALTER DATABASE stat_hrm_2 SET TABLESPACE v81c_data \g
\c stat_hrm_2
ALTER INDEX ALL IN TABLESPACE v81c_data SET TABLESPACE v81c_index \g

ALTER DATABASE trade_stat_archive SET TABLESPACE v81c_data \g
\c trade_stat_archive 
ALTER INDEX ALL IN TABLESPACE v81c_data SET TABLESPACE v81c_index \g
