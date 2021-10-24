require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "“我想回家。”“你可能回不去了。”“为什么？”“因为这里离你家很远。”“有多远？”“一千二百多年那么远。”许青看着眼前来自唐朝的少女，脸上带有一丝同情：“你所熟悉的一切，都已经变成历史。”亲朋，好友，敌人，全部沉寂在一千二百年前。———日常文，单女主（已有完本精品，质量保证。）新书《黎明之劫》已发。"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s
