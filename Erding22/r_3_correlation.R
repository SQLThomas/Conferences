library(corrplot)

mtcars
corr <- round(cor(mtcars), digits = 2)
corr

corrplot(corr, type = 'upper')

col <- colorRampPalette(c('#BB4444', '#EE9988', '#FFFFFF', '#77AADD', '#4477AA'))
corrplot(corr, method = 'shade', shade.col = NA, tl.col = 'black', tl.srt = 45,
         col = col(200), addCoef.col = 'black', cl.pos = 'n', diag = FALSE, order = 'AOE')
corrplot(corr, method = 'ellipse', shade.col = NA, tl.col = 'black', tl.srt = 45,
         col = col(200), addCoef.col = 'black', cl.pos = 'n', order = 'AOE')
