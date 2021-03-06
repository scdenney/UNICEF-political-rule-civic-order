## Imputation, as discussed in Appendix of report


## load packages
library(tidyverse)
library(mice)
#library(VIM)

#### prepare main2 #### 
## for imputation, from 'main' dataset (see "Asian_Barometer.R") 

main2 <- main
main2_c <- main2 %>%
  select(idnumber, country_name, q26n, q27n, q28n,
         q8n, q9n, q11n, q12n, q13n, q14n, q15n, q16n, q17n,
         q139n, q142n, q143n, q144n, q145n, q146n, q147n, q148n, q149n,
         q69an, q72an, q73an, q74an, q75an,
         q110n, q111n, q112n, 
         q130n, q131n, q132n, q133n,
         female, age, university, religious, married, urban, ses,
         w) 

#### Impute ####
## with default settings from 'mice'
tempdf <- mice(main2_c, meth='pmm')

## new imputed df
main2_c <- complete(tempdf,1)
main2 <- main2_c

#### Indices and new variables #### 
main2$trust <- ( (main2$q26n +
                   main2$q27n +
                   main2$q28n) / 9) ##

main2$trust_inst <-   ( (main2$q8n +
                          main2$q9n +
                          main2$q11n +
                          main2$q12n +
                          main2$q13n +
                          main2$q14n +
                          main2$q15n + #
                          main2$q16n + 
                          main2$q17n) / 27 ) 

main2$demo_value <-   ((main2$q139n +
                          main2$q142n +
                          main2$q143n +
                          main2$q144n +
                          main2$q145n +
                          main2$q146n +
                          main2$q147n +
                          main2$q148n +
                          main2$q149n) / 27 )

main2$pol_part <- ( (main2$q69an +
                      main2$q72an +
                      main2$q73an +
                      main2$q74an +
                      main2$q75an) / 15 ) 

main2$qual_gov2 <- ( (main2$q110n +
                       main2$q111n +
                       main2$q112n) / 9 )

main2$regime_pref <- ( (main2$q130n +
                         main2$q131n +
                         main2$q132n +
                         main2$q133n) / 12 )

## year bins 
main2$abins[main2$age <25]="18-24"
main2$abins[main2$age >=25 & main2$age <=29]="25-29"
main2$abins[main2$age >=30 & main2$age <=34]="30-34"
main2$abins[main2$age >=35 & main2$age <=39]="35-39"
main2$abins[main2$age >=40 & main2$age <=44]="40-44"
main2$abins[main2$age >=45 & main2$age <=49]="45-49"
main2$abins[main2$age >=50 & main2$age <=54]="50-54"
main2$abins[main2$age >=55 & main2$age <=59]="55-59"
main2$abins[main2$age >=60]="60+"

main2$abinsf<-as.factor(main2$abins)

## new vars ##
main2$political_values <- ((main2$demo_value+main2$regime_pref) / 2)
main2$political_society <- ((main2$trust+main$trust_inst+main2$qual_gov2) / 3)


#### Political Values & Trust and Social Values ####
## models

#lm models_all
impute_alldf_m1 <- lm(scale(political_values) ~ abinsf + female + university + religious + married + urban + ses + country_name, data=main2, weights=w) # RC1
impute_alldf_m2 <- lm(scale(political_society) ~ abinsf + female + university + religious + married + urban + ses + country_name, data=main2, weights=w) # RC2

#marginal effects_all
impute_pr_political_values <- ggpredict(impute_alldf_m1, c("country_name"))
impute_pr_political_values$group <- rep("All",nrow(impute_pr_political_values))
impute_pr_political_society <- ggpredict(impute_alldf_m2, c("country_name"))
impute_pr_political_society$group <- rep("All",nrow(impute_pr_political_society))

#lm models_youth
impute_youthdf_m1 <- subset(main2, youth==1) %>% lm(scale(political_values) ~ abinsf + female + university + religious + married + urban + ses + country_name, data=., weights=w) # RC1
impute_youthdf_m2 <- subset(main2, youth==1) %>% lm(scale(political_society) ~ abinsf + female + university + religious + married + urban + ses + country_name, data=., weights=w) # RC2

#marginal effects_youth
impute_pr_political_values_youth <- ggpredict(impute_youthdf_m1, c("country_name"))
impute_pr_political_society_youth <- ggpredict(impute_youthdf_m2, c("country_name"))

#marginal effects_all
impute_pr_political_values_youth <- ggpredict(impute_youthdf_m1, c("country_name"))
impute_pr_political_values_youth$group <- rep("Youth",nrow(pr_political_values_youth))
impute_pr_political_society_youth <- ggpredict(impute_youthdf_m2, c("country_name"))
impute_pr_political_society_youth$group <- rep("Youth",nrow(pr_political_society_youth))

## rbind it
impute_pr_political_values_both <- rbind(impute_pr_political_values, impute_pr_political_values_youth)
impute_pr_political_society_both <- rbind(impute_pr_political_society, impute_pr_political_society_youth)

## Political values: plotted ##
impute_move_it_pol <- position_dodge(0.3)
impute_pr_political_values_both$group <- factor(impute_pr_political_values_both$group, levels = c("All", "Youth"))
impute_pr_political_society_both$group <- factor(impute_pr_political_society_both$group, levels = c("All", "Youth"))


## changes
impute_pr_political_values_both <- impute_pr_political_values_both %>% rename(country_name=x)
impute_pr_political_values_both <- left_join(impute_pr_political_values_both, dem_ep, by="country_name")
impute_pr_political_values_both <- impute_pr_political_values_both %>% mutate(country_name=recode(country_name, 
                                                                                 "Korea" = "South Korea",
                                                                                 "Myanmar" = "Burma/Myanmar"))

impute_pr_political_society_both <- impute_pr_political_society_both %>% rename(country_name=x)
impute_pr_political_society_both <- left_join(impute_pr_political_society_both, dem_ep, by="country_name")
impute_pr_political_society_both <- impute_pr_political_society_both %>% mutate(country_name=recode(country_name, 
                                                                                   "Korea" = "South Korea",
                                                                                   "Myanmar" = "Burma/Myanmar"))
##
impute_pr_political_values_both2 <- impute_pr_political_values_both %>% 
  filter(group != "Youth") %>%
  mutate(group=recode(group, 
                          "All" = "Imputed"))

pr_political_values_both2 <- pr_political_values_both %>% 
  filter(group != "Youth") %>%
  mutate(group=recode(group, 
                      "All" = "With missing values"))

  
pr_political_values_joined2 <- rbind(impute_pr_political_values_both2, pr_political_values_both2)

##
impute_pr_political_society_both <- impute_pr_political_society_both %>% 
  filter(group != "Youth") %>%
  mutate(group=recode(group, 
                      "All" = "Imputed"))

pr_political_society_both2 <- pr_political_society_both %>% 
  filter(group != "Youth") %>%
  mutate(group=recode(group, 
                      "All" = "With missing values"))

pr_political_society_joined2 <- rbind(impute_pr_political_society_both, pr_political_society_both2)

#### Plot ####

## political values
pr_political_values_plot_impute <- ggplot(pr_political_values_joined2, aes(x=reorder(country_name, predicted), y=predicted, colour=group)) +
  geom_hline(yintercept = 0, color="#707D85") +
  geom_point(position=move_it_pol, size=1.8, aes(shape=group, fill=group)) +
  geom_errorbar(position=move_it_pol, aes(ymin=conf.low, ymax=conf.high, linetype=group), width=0) + 
  theme_light() +
  labs(title="Figure A.1 - Imputed Values: Political Norms and Values Scale", x="", y="<< more authoritarian, more democratic >>\nstandardized score",
       subtitle="Select Asia Pacific Countries, 2014-2016",
       caption="Sources: Asian Barometer, Fourth Wave (2014-2016) & Varieties of Democracy, Ver. 10\n Confidence intervals at 95%.") +
  scale_y_continuous(breaks=c(-1,-.50,0,.50,1), limits=c(-1.07,1.1)) +
  scale_colour_manual(values=wes_palette(n=2, name="BottleRocket1")) +
  #facet_grid(~v2x_regime_f, switch = "x", scales = "free_x", space = "free_x") +
  theme(legend.position = "top",
        text=element_text(family="Times New Roman"),
        axis.text.x = element_text(angle = 45, hjust=1),
        strip.text.x = element_text(size=7.5),
        axis.ticks.x = element_line(),
        axis.ticks.y = element_line(),
        axis.title.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        axis.text.x.bottom=element_text(size=10),
        strip.text=element_text(size=10),
        plot.title=element_text(size=12, face="bold.italic"),
        plot.caption=element_text(size=10, face="italic"),
        legend.text=element_text(size=10),
        legend.title=element_blank())

ggsave("fig_appendix pr_political_values_plot.pdf", pr_political_values_plot_impute,
       device=cairo_pdf, width = 7, height=6)

## society plot
pr_political_society_plot_impute <- ggplot(data=pr_political_society_joined2, aes(x=reorder(country_name, predicted), y=predicted, colour=group)) +
  geom_hline(yintercept = 0, color="#707D85") +
  geom_point(position=move_it_pol, size=1.8, aes(shape=group, fill=group)) +
  geom_errorbar(position=move_it_pol, aes(ymin=conf.low, ymax=conf.high, linetype=group), width=0) + 
  theme_light()+
  labs(title="Figure A.2 - Imputed Values: Trust and Good Governance Scale", x="", y="<< less trusthworthy, more trustworthy >>\nstandardized score",
       subtitle="Select Asia Pacific Countries, 2014-2016",
       caption="Sources: Asian Barometer, Fourth Wave (2014-2016) & Varieties of Democracy, Ver. 10\nConfidence intervals at 95%.") +
  scale_colour_manual(values=wes_palette(n=2, name="BottleRocket1")) +
  #facet_grid(~v2x_regime_f, switch = "x", scales = "free_x", space = "free_x") +
  scale_y_continuous(breaks=c(-1,-.50,0,.50,1), limits=c(-1,1)) +
  theme(legend.position = "top",
        text=element_text(family="Times New Roman"),
        axis.text.x = element_text(angle = 45, hjust=1),
        strip.text.x = element_text(size=7.5),
        axis.ticks.x = element_line(),
        axis.ticks.y = element_line(),
        axis.title.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        axis.text.x.bottom=element_text(size=10),
        strip.text=element_text(size=10),
        plot.title=element_text(size=12, face="bold.italic"),
        plot.caption=element_text(size=10, face="italic"),
        legend.text=element_text(size=10),
        legend.title=element_blank())

ggsave("fig_appendix pr_political_society_plot.pdf", pr_political_society_plot_impute,
       device=cairo_pdf, width = 7, height=6)


#### Save datasets ####

## weighted means, round to 2nd decimal place
#original
w.mean.all.vars <- df_avg %>%
  group_by(country_name) %>%
  summarise_at(vars("trust","trust_inst","demo_value","pol_part","qual_gov2","regime_pref"),
               funs(weighted.mean(., w=w)), na.rm=T)
#imputed

w.mean.all.vars.impute <- main2 %>%
  group_by(country_name) %>%
  summarise_at(vars("trust","trust_inst","demo_value","pol_part","qual_gov2","regime_pref"),
               funs(weighted.mean(., w=w)))

write.csv(w.mean.all.vars.impute, "w.mean.all.vars.impute.csv")



