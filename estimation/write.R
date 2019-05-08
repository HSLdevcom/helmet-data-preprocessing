# -*- coding: windows-1252-dos -*-
library(strafica)

write_alogit = function(x, fname, sep=" ", accuracy=0.01) {
    x = round(as.matrix(x), digits=2)
    x = t(apply(x, 1, formatC, format="fg"))
    write.table(x,
                file=fname,
                quote=FALSE,
                sep=sep,
                row.names=FALSE,
                col.names=FALSE)
    return(invisible())
}
