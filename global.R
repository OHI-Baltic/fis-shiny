library(shiny)
library(dplyr)
library(ggplot2)
library(viridis)

dataset <- read.csv("data.csv")

gridFscore <- expand.grid(
  ffmsy = seq(0, 6, length.out = 120), 
  bbmsy = seq(0, 5, length.out = 120)
)

pal <- tibble(
  stock = c("cod_SDs22_24", "cod_SDs24_32", "herring_SD_28.1", "herring_SDs20_24", "herring_SDs25_29_32", "herring_SDs30_31"),
  values = c("lightsteelblue", "navy", "coral", "tomato2", "firebrick4", "salmon")
)

calc_Bscores <- function(dataset, lowerB = 0.95, upperB1 = 1.3, upperB2 = 5){
  
  B_scores <- dataset %>%
    mutate(
      score_type = "B_score",
      
      score = ifelse(
        bbmsy < lowerB, (1/lowerB)*bbmsy,
        ifelse(
          lowerB <= bbmsy & bbmsy < upperB1, 1,
          ifelse(
            bbmsy >= upperB1,
            (bbmsy - upperB2)/(upperB1-upperB2), NA
          )
        )
      )
    ) %>%
    mutate(
      score = ifelse(
        score <= 0.1, 0.1,
        ifelse(score > 1, 1, score)
      )
    )
  return(B_scores)
} 

calc_Fscores <- function(dataset, lowerB = 0.95, upperB1 = 1.3, upperB2 = 5, lowerF = 0.5, upperF1 = 1, upperF2 = 4.5){
  
  m <- (upperF2-1)/lowerB
  
  norm1 = pracma::cross(
    c(lowerB, upperF1, 1) - c(0, 1, 0),
    c(lowerB, upperF2, 0) - c(0, 1, 0)
  )
  norm2 = pracma::cross(
    c(lowerB, 0, (upperF2-lowerF-1)/(upperF2-1)) - c(lowerB, lowerF, 1),
    c(0, 1-(upperF2-lowerF), 1) - c(lowerB, lowerF, 1)
  )
  
  F_scores <- dataset %>%
    mutate(
      score_type = "F_score",
      
      score = ifelse(
        ## when bbmsy < lowerB :
        bbmsy < lowerB,
        
        ## will be space near zero where scores start going back down from 1:
        ## on y-axis towards zero if upperF2-lowerF < 1, on x-axis towards zero if upperF2-upperF1 > 1
        ifelse(
          ffmsy > m*bbmsy + 1, 0,
          ifelse(
            m*bbmsy + 1 >= ffmsy & ffmsy > m*bbmsy + (1-(upperF2-upperF1)),
            ## http://mathworld.wolfram.com/Plane.html n1x + n2y + n3z - (n1x0 + n2y0 + n3z0) = 0
            (norm1[2] - norm1[1]*bbmsy - norm1[2]*ffmsy)/norm1[3],
            ifelse(
              m*bbmsy + (1-(upperF2-upperF1)) >= ffmsy & ffmsy > m*bbmsy + (1-(upperF2-lowerF)), 1,
              ((norm2[1]*lowerB + norm2[2]*lowerF + norm2[3]) - (norm2[1]*bbmsy + norm2[2]*ffmsy))/norm2[3]
            )
          )
        ),
        ## when bbmsy >= lowerB :
        ifelse(
          ffmsy > upperF1,
          (upperF2-ffmsy)/(upperF2-upperF1),
          ifelse(
            upperF1 >= ffmsy & ffmsy > lowerF,
            1,
            ffmsy/(upperF2-1) + (upperF2-lowerF-1)/(upperF2-1)
          )
        )
      )
    ) %>%
    ## set scores less than 0.1 to 0.1, greater than 1 to 1
    ## 0.1 rather than zero because one zero w/ geometric mean results in a zero score
    mutate(
      score = ifelse(
        score <= 0.1, 0.1,
        ifelse(score > 1, 1, score)
      )
    )
  return(F_scores)
} 
