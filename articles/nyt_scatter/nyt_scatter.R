library(tidyr)
library(dplyr)
library(readr)
library(scales)
library(ggplot2) 
setwd("/Users/ethen/Business-Analytics/articles/nyt_scatter")


file <- "nytimes_vote.tsv"
if( !file.exists(file) ) {
	url <- "https://static01.nyt.com/newsgraphics/2016/04/21/undervote/ad8bd3e44231c1091e75621b9f27fe31d116999f/data.tsv"
	download.file(url, file)
}

# convert to more informative column name
df <- read_tsv(file)
df <- df %>% rename("Someone else" = undervt, 
					"Hilary Clinton" = clintonpct, 
					"Bernie Sanders" = sanderspct)

df <- gather( select(df, -tvotes), party, pct, -ratio, -fips )
df <- arrange(df, fips, ratio)
df <- df %>% mutate( 
	party = factor( party, levels = c("Hilary Clinton", "Bernie Sanders", "Someone else") )
)
df

# 1. point shape = 21 is a doughnut circle
# 2. scale_fill_manual( name = "" ) gets rid of the legend title
# 3. theme's legend.key control the boxes around the legend's shape
fill_color <- c( 
	"Hilary Clinton" = "#5fa0d6",
	"Bernie Sanders" = "#83BC57",
	"Someone else" = "#d65454" 
)

ggplot( df, aes(x = ratio, y = pct) ) + 
geom_point( aes(fill = party), size = 3, alpha = 0.8, color = "white", shape = 21 ) + 
scale_fill_manual(name = "", values = fill_color) +
theme_bw( base_family = "Arial Narrow" ) + 
scale_y_continuous( label = percent, limits = c(0, 1.05) ) +
scale_x_continuous( limits = c(0, 4.5), breaks = seq(0, 4.5, 0.5) ) +
geom_text( data = data.frame(label = "↑ Share of 2016 primary vote"),
		   aes(x = 0, y = 1, label = label), vjust = -1, hjust = 0, size = 3,
		   fontface = "bold", family = "Arial Narrow" ) + 
labs( x = "Ratio of registered Democrats to Obama voters →", 
	  y = NULL, title = "The Kinds of Places Sanders Beats Clinton",
	  subtitle = "Each dot on this chart represents the share of a county's vote for a candidate in the 2016 Democratic primary" ) +
theme( legend.key = element_blank(), 
	   legend.position = "top",
	   plot.title = element_text(face = "bold"),
	   axis.ticks = element_blank(),
	   axis.text = element_text(size = 8),
	   axis.title.x = element_text(hjust = 1, face = "bold", size = 9),
	   panel.grid.minor = element_blank(),
	   panel.grid.major = element_line(linetype = "dotted", size = 0.5),
	   panel.border = element_blank(),
	   plot.margin = margin(t = 10, r = 10, b = 10, l = 10) )

