packages_list <- c("dplyr", "magrittr", "stringr", "rvest")
packages_not_installed <- packages_list[!packages_list %in% installed.packages()]
install.packages(packages_not_installed)
lapply(packages_list, require, character.only = TRUE)

new_dir <- "tw_legislator"
new_dir_path <- paste0("./own_project/", new_dir)
setwd(new_dir_path)
ifelse(!dir.exists("./src/assets/data"), dir.create("./src/assets/data"), FALSE)
ifelse(!dir.exists("./src/assets/image"), dir.create("./src/assets/image"), FALSE)
ifelse(!dir.exists("./src/assets/image/raw"), dir.create("./src/assets/image/raw"), FALSE)
ifelse(!dir.exists("./src/assets/image/grayscale"), dir.create("./src/assets/image/grayscale"), FALSE)
ifelse(!dir.exists("./src/assets/image/resized"), dir.create("./src/assets/image/resized"), FALSE)
ifelse(!dir.exists("./src/assets/image/thumbnail"), dir.create("./src/assets/image/thumbnail"), FALSE)
ifelse(!dir.exists("./src/assets/image/rename"), dir.create("./src/assets/image/rename"), FALSE)
ifelse(!dir.exists("./src/assets/image/colorize"), dir.create("./src/assets/image/colorize"), FALSE)

image_links <- read_html("https://www.ly.gov.tw/Pages/List.aspx?nodeid=37075#") %>%
  html_nodes(".img-responsive") %>% html_attr("src")

base_url <- "https://www.ly.gov.tw"

image_links %<>% str_replace_all("\\.\\.", base_url)

for(i in seq_along(image_links)) {
  file_name <- image_links[i] %>% str_extract("\\d{5}.+") %>%
    str_remove("\\d{5}") %>% str_remove("\\.jpg")
  file_path <- paste0("./src/assets/image/raw/", file_name, ".jpg")
  download.file(URLencode(image_links[i]), file_path)
}

image_path <- "./src/assets/image/"

image_list <- list.files(paste0(image_path, "raw"))

for(i in seq_along(image_list)) {
  system(paste0("convert ", image_path, "raw/", image_list[i], " -set colorspace Gray -separate -average ",
                image_path, "grayscale/", image_list[i]))
}

image_size <- vector("character", length(image_list))

for(i in seq_along(image_list)) {
  image_size[i] <- system(paste0("identify -format '%wx%h' ", image_path, "grayscale/", image_list[i]), intern = TRUE)
}

View(table(image_size))

for(i in seq_along(image_list)) {
  if (image_size[i] != "413x531") {
    system(paste0("convert ", image_path, "grayscale/", image_list[i], " -resize 413x531! ",
                  image_path, "resized/", image_list[i]))
    print("Resized!")
  } else {
    file.copy(paste0(image_path, "grayscale/", image_list[i]),
              paste0(image_path, "resized/", image_list[i]))
  }
}

for(i in seq_along(image_list)) {
  image_size[i] <- system(paste0("identify -format '%wx%h' ", image_path, "resized/", image_list[i]), intern = TRUE)
}

View(table(image_size))

for(i in seq_along(image_list)) {
  system(paste0("convert -size 412x432 xc:none -fill ", image_path, "resized/", image_list[i], " -draw 'circle 206,226 0,226' ", image_path, "thumbnail/", str_sub(image_list[i], 1, -5), ".png"))
  system(paste0("convert ", image_path, "thumbnail/", str_sub(image_list[i], 1, -5), ".png", " -crop 412x412+0+20 ", image_path, "thumbnail/", str_sub(image_list[i], 1, -5), ".png"))
  system(paste0("convert ", image_path, "thumbnail/", str_sub(image_list[i], 1, -5), ".png", " -resize 200x200! ", image_path, "thumbnail/", str_sub(image_list[i], 1, -5), ".png"))
}

problematic_images <- c("魯明哲.jpg", "陳超明.jpg", "陳秀寳.jpg", "陳柏惟.jpg", "陳以信.jpg", "鄭麗文.jpg", "鄭運鵬.jpg", "邱議瑩.jpg", "趙天麟.jpg", "許淑華.jpg", "蔡易餘.jpg", "蔡其昌.jpg", "葉毓蘭.jpg", "莊瑞雄.jpg", "翁重鈞.jpg", "羅明才.jpg", "洪申翰.jpg", "楊瓊瓔.jpg", "林淑芬.jpg", "李貴敏.jpg", "徐志榮.jpg", "張宏陸.jpg", "廖國棟Sufin‧Siluko.jpg", "周春米.jpg", "劉世芳.jpg", "余天.jpg", "伍麗華Saidhai．Tahovecahe.jpg", "羅致政.jpg")

for(i in seq_along(problematic_images)) {
  system(paste0("convert ", image_path, "resized/", problematic_images[i], " -crop 412x412+0+40 ", image_path, "thumbnail/", str_sub(problematic_images[i], 1, -5), ".png"))
  system(paste0("convert -size 412x412 xc:none -fill ", image_path, "thumbnail/", str_sub(problematic_images[i], 1, -5), ".png", " -draw 'circle 206,206 0,206' ", image_path, "thumbnail/", str_sub(problematic_images[i], 1, -5), ".png"))
  system(paste0("convert ", image_path, "thumbnail/", str_sub(problematic_images[i], 1, -5), ".png", " -resize 200x200! ", image_path, "thumbnail/", str_sub(problematic_images[i], 1, -5), ".png"))
}

image_list <- list.files(paste0(image_path, "thumbnail"), pattern = "png$")

legislator <- data.frame(name = image_links %>% str_extract("\\d{5}.+") %>%
                           str_remove("\\d{5}") %>% str_remove("\\.jpg"),
                         id = image_links %>% str_extract("\\d{5}"),
                         stringsAsFactors = F)

for(i in seq_along(image_list)) {
  file_id <- filter(legislator, name == str_remove(image_list[i], "\\.png"))$id
  file.copy(paste0(image_path, "thumbnail/", image_list[i]),
            paste0(image_path, "rename/", file_id, ".png"), overwrite = T)
}

legislator$name[c(1, 5, 46, 69, 83, 96)] <- c("孔文吉Yosi Takun", "伍麗華Saidhai Tahovecahe", "高金素梅Ciwas Ali", "陳瑩Asenay Daliyalrep", "廖國棟Sufin Siluko", "鄭天財Sra Kacaw")
legislator$name[c(60, 75, 106)] <- c("陳秀寶", "黃世傑", "謝衣鳳")

legislator %<>% inner_join(read.csv("./src/assets/data/legislator.csv", stringsAsFactors = F))

image_list <- list.files("./src/assets/image/rename/")

for(i in seq_along(image_list)) {
  specific_party <- filter(legislator, id == str_remove(image_list[i], "\\.png"))$party
  if(specific_party == "中國國民黨") {
    system(paste0("convert ", paste0(image_path, "rename/", image_list[i]), " -colorspace gray -fill blue4 -tint 60 ", paste0(image_path, "colorize/", image_list[i])))
  } else if (specific_party == "民主進步黨") {
    system(paste0("convert ", paste0(image_path, "rename/", image_list[i]), " -colorspace gray -fill green -tint 70 ", paste0(image_path, "colorize/", image_list[i])))
  } else if (specific_party == "台灣民眾黨") {
    system(paste0("convert ", paste0(image_path, "rename/", image_list[i]), " -colorspace gray -fill 'rgb(73,187,195)' -tint 70 ", paste0(image_path, "colorize/", image_list[i])))
  } else if (specific_party == "時代力量") {
    system(paste0("convert ", paste0(image_path, "rename/", image_list[i]), " -colorspace gray -fill yellow -tint 90 ", paste0(image_path, "colorize/", image_list[i])))
  } else if (specific_party == "台灣基進") {
    system(paste0("convert ", paste0(image_path, "rename/", image_list[i]), " -colorspace gray -fill purple -tint 70 ", paste0(image_path, "colorize/", image_list[i])))
  } else {
    system(paste0("convert ", paste0(image_path, "rename/", image_list[i]), " -colorspace gray -fill grey -tint 70 ", paste0(image_path, "colorize/", image_list[i])))
  }
}

write.csv(legislator, "./src/assets/data/legislator_full.csv", row.names = F)
