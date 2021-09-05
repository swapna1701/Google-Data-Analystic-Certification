# Setup my environment
# Importing libraries

library(tidyverse)
library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)

# load data files
trip_202004 <- read.csv("202004-divvy-tripdata.csv")
trip_202005 <- read.csv("202005-divvy-tripdata.csv")
trip_202006 <- read.csv("202006-divvy-tripdata.csv")
trip_202007 <- read.csv("202007-divvy-tripdata.csv")
trip_202008 <- read.csv("202008-divvy-tripdata.csv")
trip_202009 <- read.csv("202009-divvy-tripdata.csv")
trip_202010 <- read.csv("202010-divvy-tripdata.csv")
trip_202011 <- read.csv("202011-divvy-tripdata.csv")
trip_202012 <- read.csv("202012-divvy-tripdata.csv")
trip_202101 <- read.csv("202101-divvy-tripdata.csv")
trip_202102 <- read.csv("202102-divvy-tripdata.csv")
trip_202103 <- read.csv("202103-divvy-tripdata.csv")

# Combining all data in one file

trip_data <- rbind(trip_202004, trip_202005, trip_202006, trip_202007, trip_202008, trip_202009, trip_202010, trip_202011, trip_202012, trip_202101, trip_202102, trip_202103)

glimpse(trip_data)

# Convert started_at and end_at into date/time

trip_data$started_at<-ymd_hms(as.character(trip_data$started_at))
trip_data$ended_at<-ymd_hms(as.character(trip_data$ended_at))

# Replace "casual" to "Non Subscriber" and "member" to "Subscriber" in member_casual column

trip_data$member_casual[trip_data$member_casual=="casual"]<-"Non Subscriber"
trip_data$member_casual[trip_data$member_casual=="member"]<-"Subscriber"

# Analysis missing values and NA:

colSums(is.na(trip_data))

cleaned_data <- trip_data[complete.cases(trip_data), ]

# filter start_date < end_date:

cleaned_data<-cleaned_data %>% 
  filter(cleaned_data$started_at < cleaned_data$ended_at)


# Remove unwanted columns

cleaned_data <- cleaned_data %>% 
  select(-c(start_lat, start_lng, end_lat, end_lng))


# Create new column "ride_length"

cleaned_data$ride_length <- cleaned_data$ended_at - cleaned_data$started_at
cleaned_data$ride_length <- hms::hms(seconds_to_period(cleaned_data$ride_length))

# Create new column "day_of_week"

cleaned_data$day_of_week <- wday(cleaned_data$started_at)

# Create new Column "month"

cleaned_data$month <- month(cleaned_data$started_at)


# mean, max, min of ride_length & mode of day_of_week

ride_length_mean <- cleaned_data %>% 
  summarise(mean(ride_length))

ride_length_max <- cleaned_data %>% 
  summarise(max(ride_length))

ride_length_min <- cleaned_data %>% 
  summarise(min(ride_length))

day_of_week_mode <- cleaned_data %>% 
  summarise(mode(day_of_week))

# Average ride_length for users by day_of_week
Avg_ride_length <- cleaned_data %>% 
  group_by(day_of_week) %>% 
  summarise(mean(ride_length))

# the number of rides for users by day_of_week

Avg_ride_length_user <-cleaned_data %>% 
  mutate(week_day = wday(started_at, label=TRUE)) %>% 
  group_by(member_casual, week_day) %>% 
  summarise(number_of_rides = n(), average_duration = mean(ride_length)) %>% 
  arrange(member_casual,week_day)

# visualizing number of rides by rider types

cleaned_data %>% 
  mutate(week_day = wday(started_at,label = TRUE)) %>% 
  group_by(member_casual, week_day) %>% 
  summarise(number_of_rides = n()/1000) %>% 
  arrange(member_casual,week_day) %>% 
  ggplot(aes(x=week_day, y=number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") + 
  labs(title = "Number of Rides by Days and Ridertype", subtitle = "Subscriber Vs Non Subscriber") +
  ylab("Number of Rides (Thousand)") + 
  xlab("Day of Week")

# visualize number of rides by rider type Month wise

cleaned_data %>% 
  mutate(month = month(started_at, label = TRUE)) %>% 
  group_by(member_casual, month) %>% 
  summarize(number_of_rides = n()/1000) %>% 
  arrange(member_casual, month) %>% 
  ggplot(aes(x = month, y = number_of_rides, fill = member_casual)) + 
  geom_col(position = "dodge") +
  labs(title = "Number of Rides by Month and Rider type", subtitle = "Subscriber Vs Non Subscriber") +
  ylab("Number of Rides (Thousand)") + 
  xlab("Month")

# visualize Time duration by Days & Rider type

cleaned_data %>% 
  mutate(months = month(started_at,label = TRUE)) %>% 
  group_by(months, member_casual) %>% 
  ggplot(aes(x=months, y=ride_length, fill = member_casual)) +
  geom_col(position = "dodge") + 
  labs(title = "Time Duration by Riders", y = "Time Duration (HH:MM:SS)", x ="Months") +
  theme(plot.title = element_text(face="bold", size = 18))

# Visualize Time duration by Rider type and Day of week

cleaned_data %>% 
  mutate(week_day = wday(started_at, label = TRUE)) %>%
  group_by(week_day, ride_length) %>%
  ggplot(aes(x = week_day, y = ride_length, fill = member_casual)) + 
  geom_col(position = "dodge") +
  labs(title = "Time duration by Rider type and Day of week ", subtitle = "Subscriber Vs Non Subscriber", y = "Time Duration (HH:MM:SS)", x = "Day of Week") +
  theme(plot.title = element_text(face="bold", size = 18))

# Visualize Number of Rides by Day of Week and Types of Bikes

cleaned_data %>% 
  mutate(week_day = wday(started_at,label = TRUE)) %>% 
  group_by(member_casual, week_day, rideable_type) %>% 
  summarise(number_of_rides = n()/1000) %>% 
  arrange(member_casual,week_day) %>% 
  ggplot(aes(x=week_day, y=number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") + 
  labs(title = "Number of Rides by Day of Week", subtitle = "Riders Vs Types of Bike", y = "Number of Rides (in Thousands)", x ="Months") +
  theme(plot.title = element_text(face="bold", size = 18))+
  facet_wrap(~rideable_type, ncol = 3)
