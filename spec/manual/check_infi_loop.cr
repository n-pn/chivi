require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "现在她屁股上的黑色Tback，别说包住臀肉了，苏荆还要用手指挑开柔软白嫩的臀瓣才能看见那一条细细的布料。没有别的可能，穿这样的内裤只为了
献给那一个能够脱下它的男人看。"

test = "苏萝喝水呛到了，猛地咳嗽起来，苏荆温柔地拍她的背。"

test = "在幻象与幻象的重叠中，二人的心智互相牵引，被对方构建的世界所吸引，到最后竟然不可自控地开始度过幻想中的人生。除了一次次放荡夸张的性爱，甚至还模拟出了怀孕的幻觉，人生故事一路失控，向着越来越崩坏的方向前进。"
test = "“那我们去采购，这次我娘她们也让我给她们捎带一些，我可以大花一笔了。”"

test = "“哈哈哈哈……没了万喻楼，还会有第二个万喻楼……可没了雨化田，这世上不会再有第二个……赵怀安，你自命侠义，殊不知，你的所作所为，是何等的可笑。哈哈哈哈……”"

test = "暗啐一声。"

test = "很有风情按住被风吹起的头发。"

test = "说到这，中年人顿了顿，转头去看穆英杰，穆英杰赶紧说：“长约五尺，宽约两尺，外表如同一个箱子一样，外侧有兽头花纹，木制，镶有青铜、玉石！”"
test = "就算我可爱、美丽、是乱开在云霞之间的美丽山樱，是举世无双的美人，你也不用这么盯着我看吧？"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s
