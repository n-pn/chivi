
import jiagu

text = '“我来把人分配一下吧！”蓝易计算着，“现在在线的有346人，城里九个地方每处30人就行了，山谷这边入口较大，人得多些，剩下的就全留这里吧！” 茫茫的莽莽点点头：“记得每个地方都配牧师，这是关键。”'
words = jiagu.seg(text) # 分词
pos = jiagu.pos(words) # 词性标注

for i, tag in enumerate(pos):
  print(words[i] + '/' + tag, end=' ')
