###############################################################################
# Run HP on different percentage length of genome length (evaluation set)
###############################################################################

# 90% species
xmsub -W group_list=pr_phage -A pr_phage \
-l nodes=1:ppn=2,mem=10gb,walltime=1:00:00:00 \
-d /home/projects/pr_phage/people/juliav/HP_general \
-N HP_90 \
-de -r y HostPhinder_general/scripts_gen/run_wrap_HP_eval_varLength.sh \
-t species -p 90 -o eval_percentages/90
#861449              C 0             tor  48.67      1.0  -    juliav   juliav  risoe-r03-cn030     2    00:02:13   Tue Mar  8 13:22:59

# 10% to 90% species
for i in `seq 10 10 90`; do xmsub -W group_list=pr_phage -A pr_phage \
-l nodes=1:ppn=2,mem=10gb,walltime=1:00:00:00 \
-d /home/projects/pr_phage/people/juliav/HP_general \
-N HP_$i \
-de -r y HostPhinder_general/scripts_gen/run_wrap_HP_eval_varLength.sh \
-t species -p $i -o eval_percentages/$i; done
#861465              C 0             tor  48.52      1.0  -    juliav   juliav  risoe-r03-cn024     2     8:08:29   Tue Mar  8 22:42:11
#861459              C 0             tor  48.79      1.0  -    juliav   juliav  risoe-r03-cn028     2     8:11:42   Tue Mar  8 22:45:24
#861460              C 0             tor  48.97      1.0  -    juliav   juliav  risoe-r03-cn025     2     8:14:54   Tue Mar  8 22:48:36
#861463              C 0             tor  48.98      1.0  -    juliav   juliav  risoe-r03-cn025     2     8:17:03   Tue Mar  8 22:50:45
#861461              C 0             tor  48.98      1.0  -    juliav   juliav  risoe-r03-cn025     2     8:17:35   Tue Mar  8 22:51:17
#861464              C 0             tor  48.98      1.0  -    juliav   juliav  risoe-r03-cn025     2     8:18:07   Tue Mar  8 22:51:49
#861462              C 0             tor  48.97      1.0  -    juliav   juliav  risoe-r03-cn025     2     8:18:39   Tue Mar  8 22:52:21
#861457              C 0             tor  48.90      1.0  -    juliav   juliav  risoe-r03-cn030     2     8:27:10   Tue Mar  8 23:00:52
#861458              C 0             tor  48.86      1.0  -    juliav   juliav  risoe-r03-cn030     2     8:27:42   Tue Mar  8 23:01:24

# 10% to 90% genus
for i in `seq 10 10 90`; do xmsub -W group_list=pr_phage -A pr_phage \
-l nodes=1:ppn=2,mem=10gb,walltime=1:00:00:00 \
-d /home/projects/pr_phage/people/juliav/HP_general \
-N HP_$i \
-de -r y HostPhinder_general/scripts_gen/run_wrap_HP_eval_varLength.sh \
-t genus -p $i -o eval_percentages/$i; sleep 10; done
#861595              C 0             tor  48.74      1.0  -    juliav   juliav  risoe-r03-cn020     2    13:04:03   Wed Mar  9 22:51:46
#861594              C 0             tor  48.76      1.0  -    juliav   juliav  risoe-r03-cn020     2    13:06:06   Wed Mar  9 22:53:22
#861599              C 0             tor  48.96      1.0  -    juliav   juliav  risoe-r03-cn020     2    13:05:38   Wed Mar  9 22:53:54
#861596              C 0             tor  48.73      1.0  -    juliav   juliav  risoe-r03-cn020     2    13:06:43   Wed Mar  9 22:54:26
#861592              C 0             tor  48.02      1.0  -    juliav   juliav  risoe-r03-cn020     2    13:07:10   Wed Mar  9 22:54:26
#861597              C 0             tor  48.74      1.0  -    juliav   juliav  risoe-r03-cn020     2    13:07:15   Wed Mar  9 22:54:58
#861593              C 0             tor  48.05      1.0  -    juliav   juliav  risoe-r03-cn020     2    13:08:14   Wed Mar  9 22:55:30
#861598              C 0             tor  48.80      1.0  -    juliav   juliav  risoe-r03-cn020     2    13:09:54   Wed Mar  9 22:58:10
#861591              C 0             tor  48.38      1.0  -    juliav   juliav  risoe-r03-cn030     2    14:11:13   Wed Mar  9 23:57:57
