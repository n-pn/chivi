require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "现在她屁股上的黑色Tback，别说包住臀肉了，苏荆还要用手指挑开柔软白嫩的臀瓣才能看见那一条细细的布料。没有别的可能，穿这样的内裤只为了
献给那一个能够脱下它的男人看。"

test = "苏萝喝水呛到了，猛地咳嗽起来，苏荆温柔地拍她的背。"

test = "在幻象与幻象的重叠中，二人的心智互相牵引，被对方构建的世界所吸引，到最后竟然不可自控地开始度过幻想中的人生。除了一次次放荡夸张的性爱，甚至还模拟出了怀孕的幻觉，人生故事一路失控，向着越来越崩坏的方向前进。"
test = "我也不会"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s
