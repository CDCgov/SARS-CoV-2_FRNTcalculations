#R Console Script for calculating

#install.packages('tidyverse')
#install.packages('drc')
#install.packages('reshape')
#install.packages('Hmisc')



#Packages needed
library("tidyverse")
library("drc")
library("reshape")
library("Hmisc")

#If you run into errors here, you need to install some packages, starting with the ones above, and any others the console throws in error


##Set the working directory:
#Change this to the parent directory that will hold the input and output folders
setwd("//cdc.gov/project/OID_VSDB_VPT/COVID-19_Projects/Plaque_Assay/2021-10-20_FRNT_Titration")


#Change this to match the folder created to export data
outdir = "./Output/"

#Change this to match the folder containing only valid CSV files.
indir = "./CSV/"

parse_file <- function(filename) {
  df1 = read.csv(filename, header = FALSE, skip = 1, stringsAsFactors = FALSE)

  df1_firstrow <- read.csv(filename,nrows=1, header=FALSE, stringsAsFactors = FALSE)

  Virus = as.character(df1_firstrow[1,2])
  Serum1 = df1_firstrow[1,4]
  Serum2 = df1_firstrow[1,6]
  StartConc = df1_firstrow[1,8]
  DiluFactor = df1_firstrow[1,10]
  PlateID = df1_firstrow[1,12]
  DateID = df1_firstrow[1,14]
  PassageID = df1_firstrow[1,16]
 
  Concentrations = c(StartConc/DiluFactor^(0:6), 0)

  df11 <- cbind(Concentrations, df1[, 1:6])
  colnames(df11) <- c("Concentration", "Rep1", "Rep2", "Rep3", "Rep4", "Rep5", "Rep6")
  df12 = melt(df11, id=c("Concentration"))
  colnames(df12) = c("Concentration", "Rep", "Titers")
  df12
  df13 = cbind(Virus, Serum1, PlateID, DateID, PassageID, df12)
  colnames(df13) = c("Virus", "Serum", "PlateID", "DateID", "PassageID", "Concentration", "Rep", "Titers")
  df21 <- cbind(Concentrations, df1[, 7:12])
  colnames(df21) <- c("Concentration", "Rep1", "Rep2", "Rep3", "Rep4", "Rep5", "Rep6")
  df22 = melt(df21, id=c("Concentration"))
  colnames(df22) = c("Concentration", "Rep", "Titers")
  df22
  df23 = cbind(Virus, Serum2, PlateID, DateID, PassageID, df22)
  colnames(df23) = c("Virus", "Serum", "PlateID", "DateID", "PassageID", "Concentration", "Rep", "Titers")

  df1_all = rbind(df13, df23)
  return(df1_all)
 }

file_list = list.files(path = indir, pattern = ".csv", full.names = TRUE)
file_list
df <- data.frame(Virus=character(), Serum=character(), PlateID = character(), DateID=numeric(), PassageID=character(), Concentration=numeric(), Rep=character(),Titers=numeric(), stringsAsFactors=FALSE)
    for (i in file_list){
        print(i)
        file1 = parse_file(i)
        df = rbind(df, file1)
    }
    
    df$SerumDate = paste0(df$Serum, "-", df$DateID)
    head(df)

final_ec50 = data.frame(Serum=character(), Virus=numeric(), PassageID=character(), PlateID=character(), SerumDate=character(), PlateMinConc=numeric(), PlateMaxConc=numeric(), ec50=numeric(), hill=numeric(), max=numeric(), Report=character(), stringsAsFactors=FALSE)

    Serum_uniq = unique(df$SerumDate)
    for (i in Serum_uniq){
        print(paste0("Serum: ", i))
        df_serum_set = subset(df, SerumDate == i)
        Virus_uniq = unique(df_serum_set$Virus)
        #print(Virus_uniq)
        for (j in Virus_uniq){
            df_serum_virus_set = subset(df_serum_set, Virus == j)
            min_conc <- min(df_serum_virus_set$Concentration[!df_serum_virus_set$Concentration == 0])
            max_conc <- max(df_serum_virus_set$Concentration)
            print(paste0("Virus: ", j))
            curve_fit <- drm(formula = Titers ~ Concentration, data = df_serum_virus_set, fct = LL.3(names = c("hill", "max_value", "ec_50")))
            parameters = data.frame(Serum=df_serum_virus_set$Serum[1], 
                                    Virus=j,
                                    PassageID=df_serum_virus_set$PassageID[1],
                                    PlateID=df_serum_virus_set$PlateID[1],
                                    SerumDate=i, PlateMinConc=min_conc, PlateMaxConc=max_conc, 
                                    ec50=as.numeric(curve_fit$coef[3]), hill=as.numeric(curve_fit$coef[1]), max = as.numeric(curve_fit$coef[2]), Report=round(1/as.numeric(curve_fit$coef[3])))
            if(as.numeric(curve_fit$coef[1]) < 0.5 | as.numeric(curve_fit$coef[1]) > 2){
                curve_fit <- drm(formula = Titers ~ Concentration, data = df_serum_virus_set, fct = LL.3(fixed = c(1, NA, NA), names = c("hill", "max_value", "ec_50")))
                parameters = data.frame(Serum=df_serum_virus_set$Serum[1],
                                    Virus=j,
                                    PassageID=df_serum_virus_set$PassageID[1],
                                    PlateID=df_serum_virus_set$PlateID[1],
                                    SerumDate=i, PlateMinConc=min_conc, PlateMaxConc=max_conc,
                                    ec50=as.numeric(curve_fit$coef[2]), hill=1, max = as.numeric(curve_fit$coef[1]), Report=round(1/as.numeric(curve_fit$coef[2])))
                #print("refitting")
                #print(i)
                #print(j)
            }
            if(parameters$ec50 > 0.75 * max(df_serum_virus_set$Concentration)){
                parameters$Report=paste0("< ", round(1/(0.75 * max(df_serum_virus_set$Concentration))))
            }
            #print(paste0("min_conc:", min_conc))
            #print(paste0("ec50 :", parameters$ec50))
            if(parameters$ec50 < 1.25 * min_conc){
            #print("less than reached")
            #parameters$OutOfRange="Lowest Concentration of Serum is not low enough to get accurate EC50 measure"
               parameters$Report=paste0("> ", round(1/(1.25 * min_conc)))
            }
            final_ec50 = rbind(final_ec50, parameters)
        }
    }

head(final_ec50)
ec80 = (80/20)^(1/final_ec50$hill)*final_ec50$ec50
ec60 = (60/40)^(1/final_ec50$hill)*final_ec50$ec50
ec70 = (70/30)^(1/final_ec50$hill)*final_ec50$ec50
final_ec50 = cbind(final_ec50, ec60, ec70, ec80)
final_ec50 = final_ec50[,c(1,2,3,4,5,6,7,8,12,13,14,9,10,11)]
head(final_ec50)
write.csv(final_ec50, file = paste0(outdir, "final_ec50.csv"), row.names = FALSE)

df_scale = merge(df, final_ec50, by = c("Serum", "Virus", "PassageID", "PlateID", "SerumDate"))
df_scale$Percent = (df_scale$Titers/df_scale$max) * 100
df_scale$Virus = as.character(df_scale$Virus)
head(df_scale)

df_serum_set = subset(df_scale , Serum == unique(df_scale$Serum)[1])
    df_serum_set = subset(df_serum_set, Concentration != 0)
    head(df_serum_set)

g = ggplot(df_serum_set, aes(x = log2(Concentration), y = Percent, color =SerumDate)) +
      theme_bw() +
      stat_summary(geom = 'point', fun = mean) +
      stat_summary(fun.data = mean_se, geom = 'errorbar') +
      stat_smooth(method = 'drm', mapping = aes(color = as.character(SerumDate)), method.args = list(fct = L.3()), se = FALSE)

g = g + coord_cartesian(ylim=c(100, 0)) + scale_x_reverse(breaks = rev(seq(floor(range(log2(df_serum_set$Concentration))[1]), ceiling(range(log2(df_serum_set$Concentration))[2]), 1)),
                           labels = -rev(seq(floor(range(log2(df_serum_set$Concentration))[1]), ceiling(range(log2(df_serum_set$Concentration))[2]), 1))) +
      scale_y_continuous(breaks = seq(0, 100, 10),
                         labels = 100 - seq(0, 100, 10)) +
      geom_hline(yintercept=50, linetype='dashed', color = 'red', size=0.5) + 
      ylab('Percent Neutralization') + xlab('log[Dilution]') + ggtitle(Serum_uniq[1]) +
      theme(plot.title = element_text(hjust = 0.5))

g

for(Serum_uniq in unique(df_scale$SerumDate)){
        print(Serum_uniq)
        df_serum_set = subset(df_scale , SerumDate == Serum_uniq[1])
        df_serum_set = subset(df_serum_set, Concentration != 0)
        g = ggplot(df_serum_set, aes(x = log2(Concentration), y = Percent, color = Virus)) +
          theme_bw() +
          stat_summary(geom = 'point', fun = mean) +
          stat_summary(fun.data = mean_se, geom = 'errorbar') +
          stat_smooth(method = 'drm', mapping = aes(color = as.character(Virus)), method.args = list(fct = L.3()), se = FALSE)
        
	g = g + coord_cartesian(ylim=c(100, 0)) + scale_x_reverse(breaks = rev(seq(floor(range(log2(df_serum_set$Concentration))[1]), ceiling(range(log2(df_serum_set$Concentration))[2]), 1)),
                           labels = -rev(seq(floor(range(log2(df_serum_set$Concentration))[1]), ceiling(range(log2(df_serum_set$Concentration))[2]), 1))) +
              scale_y_continuous(breaks = seq(0, 100, 10), labels = 100 - seq(0, 100, 10)) +
              geom_hline(yintercept=50, linetype='dashed', color = 'red', size=0.5) + 
      ylab('Percent Neutralization') + xlab('log[Dilution]') + ggtitle(Serum_uniq[1]) +
      theme(plot.title = element_text(hjust = 0.5))
        ggsave(paste0(outdir, Serum_uniq, '.png'))
        }
