# -*- coding: utf-8-unix -*-

# Install the newest version of devtools
install.packages("devtools")

require(devtools)
cran = "https://ftp.eenet.ee/pub/cran/"

# strafica dependencies
install_version("data.table", version="1.12.2", repos=cran)
install_version("ggplot2", version="3.1.1", repos=cran)
install_version("scales", version="1.0.0", repos=cran)
install_version("DBI", version="1.0.0", repos=cran)
install_version("plyr", version="1.8.4", repos=cran)
install_version("png", version="0.1-7", repos=cran)
install_version("rgdal", version="1.4-3", repos=cran)
install_version("rgeos", version="0.4-3", repos=cran)
install_version("sp", version="1.3-1", repos=cran)
install_version("magrittr", version="1.5", repos=cran)

# helmet-data-preprocessing -specific dependencies
install_version("readxl", version="1.3.1", repos=cran)
install_version("lubridate", version="1.7.4", repos=cran)
install_version("tidyr", version="0.8.3", repos=cran)
install_version("writexl", version="1.1", repos=cran)
