# Part-of-Speech tagging

Nguồn: https://www.biaodianfu.com/pos-tagging-set.html

## PFR 人民日报标注语料库 (Nhân dân nhật báo)

| Code | Từ loại     | Nghĩa Việt       | Bỏ qua |
| ---- | ----------- | ---------------- | ------ |
| a    | 形容词      | Tính từ          |        |
| ad   | 副形词      | Trạng từ         |        |
| Ag   | 形语素      | Tính ngữ tố      |        |
| an   | 名形词      | Tính + danh      |        |
| b    | 区别词      | Khu biệt         |        |
| Bg   | 区别语素    | Khu biệt ngữ tố  |        |
| c    | 连词        | Liên từ          |        |
| d    | 副词        | Phó từ           |        |
| Dg   | 副语素      | Phó ngữ tố       |        |
| e    | 叹词        | Thán từ          |        |
| f    | 方位词      | Phương vị        |        |
| g    | 语素        | Hình vị          |        |
| h    | 前接成分    | Tiền tố          | x      |
| i    | 成语        | Thành ngữ        |        |
| j    | 简称略语    | Viết tắt         | x      |
| k    | 后接成分    | Hậu tố           | x      |
| l    | 习用语      | Quen dùng        |        |
| m    | 数词        | Số từ            |        |
| Mg   | 数语素      | Số ngữ tố        |        |
| n    | 名词        | Danh từ          |        |
| Ng   | 名语素      | Danh ngữ tố      |        |
| nr   | 人名        | Tên người        |        |
| ns   | 地名        | Địa danh         |        |
| nt   | 机构团体    | Tổ chức          |        |
| nx   | 字母专名    | Tên tắt          |        |
| nz   | 其他专名    | Tên khác         |        |
| o    | 拟声词      | Tượng thanh      |        |
| p    | 介词        | Giới từ          |        |
| q    | 量词        | Lượng từ         |        |
| Qg   | 量语素      | Lượng ngữ tố     |        |
| r    | 代词        | Đại từ           |        |
| Rg   | 代语素      | Đại ngữ tố       |        |
| s    | 处所词      | Nơi chốn         |        |
| t    | 时间词      | Thời gian        |        |
| Tg   | 时语素      | Thì ngữ tố       |        |
| u    | 助词        | Trợ từ           |        |
| Ug   | 时态助词    | Trợ từ thì thái  |        |
| ud   | 结构助词 得 | Trợ từ `得`      |        |
| uj   | 结构助词 的 | Trợ từ `的`      |        |
| ul   | 时态助词 了 | Trợ từ `了`      |        |
| uv   | 结构助词 地 | Trợ từ `地`      |        |
| uz   | 时态助词 着 | Trợ từ `着`      |        |
| v    | 动词        | Động từ          |        |
| vd   | 副动词      | Động từ nối tiếp |        |
| Vg   | 动语素      | Động ngữ tố      |        |
| vn   | 名动词      | Danh + động      |        |
| w    | 标点符号    | Dấu câu          |        |
| x    | 非语素字    | Hư từ            |        |
| y    | 语气词      | Ngữ khí          |        |
| Yg   | 语气词      | Ngữ khí ngữ tố   |        |
| z    | 状态词      | Trạng thái       |        |

## pkuseg

| Code | Từ loại  | Nghĩa Việt        |
| ---- | -------- | ----------------- |
| n    | 名词     | danh từ           |
| t    | 时间词   | thời gian         |
| s    | 处所词   | nơi chốn          |
| f    | 方位词   | phương vị         |
| m    | 数词     | số từ             |
| q    | 量词     | lượng từ          |
| b    | 区别词   | khu biệt          |
| r    | 代词     | đại từ            |
| v    | 动词     | động từ           |
| a    | 形容词   | tính từ           |
| z    | 状态词   | trạng thái        |
| d    | 副词     | phó từ            |
| p    | 介词     | giới từ           |
| c    | 连词     | liên từ           |
| u    | 助词     | trợ từ            |
| y    | 语气词   | ngữ khí           |
| e    | 叹词     | thán từ           |
| o    | 拟声词   | tượng thanh       |
| i    | 成语     | thành ngữ         |
| l    | 习惯用语 | quán ngữ          |
| j    | 简称     | viết tắt          |
| h    | 前接成分 | tiền tố           |
| k    | 后接成分 | hậu tố            |
| g    | 语素     | hình vị           |
| x    | 非语素字 | hư từ khác        |
| w    | 标点符号 | dấu câu           |
| nr   | 人名     | tên người         |
| ns   | 地名     | địa danh          |
| nt   | 机构名称 | tổ chức           |
| nx   | 外文字符 | ngoại văn         |
| nz   | 其它专名 | tên riêng khác    |
| vd   | 副动词   | động từ nối       |
| vn   | 名动词   | danh động từ      |
| vx   | 形式动词 | động từ hình thái |
| ad   | 副形词   | phó hình từ       |
| an   | 名形词   | danh hình từ      |

## Jieba

https://github.com/fxsjy/jieba

| Code | Từ loại            | Nghĩa Việt             |
| ---- | ------------------ | ---------------------- |
| a    | 形容词             | Tính từ                |
| ad   | 副形词             | Trạng từ               |
| ag   | 形容词性语素       | Tính từ + hình vị      |
| an   | 名形词             | Danh động từ           |
| b    | 区别词             | Khu biệt               |
| c    | 连词               | Liên từ                |
| d    | 副词               | Phó từ                 |
| df   | `不要`             | ?                      |
| dg   | 副语素             | Phó từ + hình vị       |
| e    | 叹词               | Thán từ                |
| f    | 方位名词           | Phương vị              |
| g    | 语素               | Hình vị                |
| h    | 前接成分           | Tiền tố                |
| i    | 成语               | Thành ngữ              |
| j    | 简称略语           | Viết tắt               |
| k    | 后接成分           | Hậu tố                 |
| l    | 习用语             | Quen dùng              |
| m    | 数量词             | Số từ                  |
| mg   | -                  | Số từ + hình vị        |
| mq   | 数量词             | Số lượng từ            |
| n    | 普通名词           | Danh từ                |
| nr   | 人名               | Tên người              |
| nrfg | Tên người/Định ngữ |
| nrt  | 人名/机构名        | Tên người hoặc tổ chức |
| ns   | 地名               | Địa danh               |
| nt   | 机构名             | Tổ chức                |
| nw   | 作品名             | Tác phẩm               |
| nz   | 其他专名           | Tên khác               |
| o    | 拟声词             | Tượng thanh            |
| p    | 介词               | Giới từ                |
| q    | 量词               | Lượng từ               |
| r    | 代词               | Đại từ                 |
| rg   | 代词性语素         | Đại từ + hình vị       |
| rr   | 人称代词           | Đại từ nhân xưng       |
| rz   | 指示代词           | Đại từ chỉ thị         |
| s    | 处所名词           | Nơi chốn               |
| t    | 时间               | Thời gian              |
| tg   | 时间+              | Thời gian + hình vị    |
| u    | 助词               | Trợ từ                 |
| ud   | 结构助词 得        | Trợ từ kết cấu         |
| ug   | 时态助词           | Trợ từ thì thái        |
| uj   | 结构助词 的        | Trợ từ `的`            |
| ul   | 时态助词 了        | Trợ từ `了`            |
| uv   | 结构助词 地        | Trợ từ `地`            |
| uz   | 时态助词 着        | Trợ từ `着`            |
| v    | 普通动词           | Động từ                |
| vd   | 动副词             | Động phó từ            |
| vg   | 动语素             | Dộng từ + hình vị      |
| vi   | 不及物动词         |
| vn   | 名动词             | Danh động từ           |
| vq   |
| w    | 标点符号           | Dấu câu                |
| x    | 非语素字           | Hư từ                  |
| y    | 语气词             | Ngữ khí                |
| z    | 状态词             | Trạng thái             |

## THULAC

http://thulac.thunlp.org/

## Baidu LAC

| 标签 | 含义     | 标签 | 含义     | 标签 | 含义     | 标签 | 含义     |
| ---- | -------- | ---- | -------- | ---- | -------- | ---- | -------- |
| n    | 普通名词 | f    | 方位名词 | s    | 处所名词 | nw   | 作品名   |
| nz   | 其他专名 | v    | 普通动词 | vd   | 动副词   | vn   | 名动词   |
| a    | 形容词   | ad   | 副形词   | an   | 名形词   | d    | 副词     |
| m    | 数量词   | q    | 量词     | r    | 代词     | p    | 介词     |
| c    | 连词     | u    | 助词     | xc   | 其他虚词 | w    | 标点符号 |
| PER  | 人名     | LOC  | 地名     | ORG  | 机构名   | TIME | 时间     |
