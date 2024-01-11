from paddlenlp import Taskflow

ddp = Taskflow("dependency_parsing", use_pos=True)
ddp("百度是一家高科技公司")

ddp(["百度是一家高科技公司", "他送了一本书"])
