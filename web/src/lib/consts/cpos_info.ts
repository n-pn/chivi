export default {
  X: {
    name: 'Không rõ',
    desc: 'Dùng chung cho các từ chưa được phân loại chuẩn',
    type: 'base',
  },
  AD: {
    name: 'Phó từ',
    desc: 'Các từ đặt trước động từ, tính từ làm trạng ngữ cho động/tính từ phía sau',
    type: 'word',
  },
  AS: {
    name: 'Động thái',
    desc: 'Các từ 了/过/在/着 đánh dấu thể/động thái (aspect) của động từ trong câu',
    type: 'word',
  },
  BA: {
    name: 'Giới từ 把',
    desc: 'Giới từ 把/将 trong cấu trúc đặc biệt dùng 把/将',
    type: 'word',
  },
  CC: {
    name: 'Liên kết',
    desc: 'Liên từ liệt kê (coordinating conjunction) kết nối từ với từ, cụm từ với cụm từ',
    type: 'word',
  },
  CD: {
    name: 'Số đếm',
    desc: 'Các từ chỉ số đếm như 1, hai, trăm triệu, vài...',
    type: 'word',
  },
  CS: {
    name: 'Liên từ',
    desc: 'Các từ để liên kết các cụm ngữ pháp trong câu hoặc giữa các đoạn văn (subordinating conjunction)',
    type: 'word',
  },
  DEC: {
    name: 'Bổ trợ 的',
    desc: 'Trợ từ 的/之 dùng để đánh dấu cụm vị ngữ/cụm chủ vị làm định ngữ cho danh từ (complementizer)',
    type: 'word',
  },
  DEG: {
    name: 'Thuộc cách 的',
    desc: 'Trợ từ 的/之 đánh dấu thuộc cách cho cụm danh từ/đại từ đằng trước (genitive marker)',
    type: 'word',
  },
  DER: {
    name: 'Nhân quả 得',
    desc: 'Trợ từ 得 đánh dấu bổ ngữ nhân quả cho động từ (đứng sau động từ)',
    type: 'word',
  },
  DEV: {
    name: 'Cách thức 地',
    desc: 'Trợ từ 地 đánh dấu trạng ngữ cách thức cho động từ phía sau',
    type: 'word',
  },
  DT: {
    name: 'Hạn định',
    desc: 'Các từ như 这(này), 那(kia) đứng đầu cụm danh từ, trước số lượng từ làm định ngữ',
    type: 'word',
  },
  ETC: {
    name: 'Liệt kê',
    desc: 'Các từ như 等/等等 đi sau danh từ/cụm danh từ mang ý nghĩa liệt kê',
    type: 'word',
  },
  EM: {
    name: 'Biểu tượng',
    desc: 'Các từ chỉ biểu tượng cảm xúc, biểu ngữ hình mặt (emoji, emoticon)',
    type: 'word',
  },
  FW: {
    name: 'Ngoại lai',
    desc: 'Các từ tiếng nước ngoài chưa có vai trò từ loại khác trong câu',
    type: 'word',
  },
  IJ: {
    name: 'Thán từ',
    desc: 'Từ biểu thị cảm thán, kêu gọi, hò hét, đối đáp',
    type: 'word',
  },
  JJ: {
    name: 'Khu biệt',
    desc: 'Tính từ phi vị ngữ, có thể làm định ngữ trực tiếp cho danh từ không cần 的',
    type: 'word',
  },
  LB: {
    name: '被 dài',
    desc: 'Từ 被 trong cấu trúc 被 + cụm trạng ngữ + động từ',
    type: 'word',
  },
  LC: {
    name: 'Phương vị',
    desc: 'Các danh từ chỉ phương hướng như phía trên, bên dưới, đằng sau, ở giữa"',
    type: 'word',
  },
  M: {
    name: 'Lượng từ',
    desc: 'Biểu thị đơn vị của sự vật hoặc động tác, ví dụ chiếc, con, quyển...',
    type: 'word',
  },
  MSP: {
    name: 'Trợ từ',
    desc: 'Các từ hay đứng trước động từ để bổ trợ cho tác dụng của động từ',
    type: 'word',
  },
  NOI: {
    name: 'Từ rác',
    desc: 'Các từ không đóng vai trò gì trong câu, thường do lỗi chính tả',
    type: 'word',
  },
  NN: {
    name: 'Danh từ',
    desc: 'Các danh từ chỉ động thực vật, đồ vật, địa điểm, khái niệm...',
    type: 'word',
  },
  NR: {
    name: 'Tên riêng',
    desc: 'Các từ thường viết hoa như tên người, tổ chức, địa danh, tác phẩm, chiêu thức...',
    type: 'word',
  },
  NT: {
    name: 'Thời gian',
    desc: 'Các từ chỉ thời gian như buổi sáng, 12 giờ, thứ hai, tháng 7, năm 2021',
    type: 'word',
  },
  OD: {
    name: 'Số thứ tự',
    desc: 'Các từ chỉ số thứ tự như thứ nhất, thứ hai',
    type: 'word',
  },
  ON: {
    name: 'Tượng thanh',
    desc: 'Các từ dùng để mô tả âm thanh, tiếng động',
    type: 'word',
  },
  P: {
    name: 'Giới từ',
    desc: 'Các từ có thể tổ hợp với danh từ làm cụm giới từ làm định ngữ hoặc trạng ngữ',
    type: 'word',
  },
  PN: {
    name: 'Đại từ',
    desc: 'Các loại đại từ: nhân xưng, chỉ thị, nghi vấn...',
    type: 'word',
  },
  PU: {
    name: 'Dấu câu',
    desc: 'Các loại dấu câu như chấm hỏi, chấm than, hai chấm...',
    type: 'word',
  },
  SB: {
    name: '被 ngắn',
    desc: 'Từ 被 trong cấu trúc 被 + động từ',
    type: 'word',
  },
  SP: {
    name: 'Ngữ khí',
    desc: 'Các trợ từ nằm ở cuối câu văn biểu thị nghi vấn, cảm xúc, khẳng định',
    type: 'word',
  },
  URL: {
    name: 'Đường link',
    desc: 'Các từ chỉ liên kết tới các trang web',
    type: 'word',
  },
  VA: {
    name: 'Hình dung',
    desc: 'Các từ mô tả hình dạng/tính chất của sự vật, hoặc trạng thái của hành vi',
    type: 'word',
  },
  VC: {
    name: 'Hệ từ 是',
    desc: 'Các động từ như 是/为/非 làm động từ liên hệ trong câu',
    type: 'word',
  },
  VE: {
    name: 'Tồn hiện 有',
    desc: 'Các động từ như 有/没有/无 làm động từ chính trong cấu trúc tồn hiện',
    type: 'word',
  },
  VV: {
    name: 'Động từ',
    desc: 'Các từ chỉ động tác, hành vi, biến hoá, phát triển.',
    type: 'word',
  },
  ADJP: {
    name: 'Cụm tính từ',
    desc: 'Cụm từ hình dung/khu biệt kết hợp với DEC làm định ngữ cho danh từ phía sau',
    type: 'phrase',
  },
  ADVP: {
    name: 'Cụm trạng ngữ',
    desc: 'Cụm từ kết hợp thời gian/phó từ/động từ với DEV làm trạng ngữ cho động từ phía sau',
    type: 'phrase',
  },
  CLP: {
    name: 'Cụm số lượng',
    desc: 'Các cụm từ chỉ số lượng của sự vật sự việc, kết hợp giữa số từ và lượng từ',
    type: 'phrase',
  },
  CP: {
    name: 'Cụm bổ ngữ',
    desc: 'Cụm từ ngắn dùng để bổ sung ý nghĩa cho các cụm từ khác trong câu',
    type: 'phrase',
  },
  DNP: {
    name: 'Cụm thuộc cách',
    desc: 'Kết hợp giữa danh từ với 的 đằng sau đánh dấu thuộc cách cho danh từ trung tâm',
    type: 'phrase',
  },
  DP: {
    name: 'Cụm hạn định',
    desc: 'Kết hợp giữa từ hạn định (này, kia) với cụm số lượng từ làm định ngữ cho danh từ',
    type: 'phrase',
  },
  DVP: {
    name: 'Cụm cách thức',
    desc: 'Kết hợp cụm từ (danh/tính, động) với trợ từ 地 làm bổ ngữ chỉ cách thức cho động từ',
    type: 'phrase',
  },
  FRAG: {
    name: 'Đoạn cụm từ',
    desc: 'Một cụm từ đứng riêng nhưng chưa thành cụm chủ vị hoàn chỉnh',
    type: 'phrase',
  },
  INTJ: {
    name: 'Cụm thán từ',
    desc: 'Cụm từ gộp bởi các thán từ đứng đầu câu',
    type: 'phrase',
  },
  IP: {
    name: 'Cụm chủ vị',
    desc: 'Cấu trúc cơ bản: chủ ngữ + vị ngữ',
    type: 'phrase',
  },
  LCP: {
    name: 'Cụm phương vị',
    desc: 'Kết hợp cụm từ với từ chỉ phương vị phía sau làm định ngữ hoặc bổ ngữ',
    type: 'phrase',
  },
  LST: {
    name: 'Dấu danh sách',
    desc: 'Đánh dấu từ mang ý liệt kê danh sách trong bài văn',
    type: 'phrase',
  },
  NP: {
    name: 'Cụm danh từ',
    desc: 'Các cụm từ mang ý nghĩa là danh từ đóng vai trò làm chủ ngữ hoặc tân ngữ trong câu',
    type: 'phrase',
  },
  PP: {
    name: 'Cụm giới từ',
    desc: 'Cụm từ gồm giới từ + cụm danh từ/cụm chủ vị đằng sau làm bổ ngữ cho động từ',
    type: 'phrase',
  },
  PRN: {
    name: 'Cụm ngoặc đơn',
    desc: 'Cụm từ trong dấu ngoặc đơn hoặc ngoặc kép, thường đứng độc lập trong câu văn',
    type: 'phrase',
  },
  QP: {
    name: 'Cụm lượng từ',
    desc: 'Cụm lượng từ + các từ mang ý nghĩa xấp xỉ',
    type: 'phrase',
  },
  TOP: {
    name: 'Cả đoạn văn',
    desc: 'Đánh dấu bắt đầu đoạn văn, hợp cả câu văn',
    type: 'phrase',
  },
  UCP: {
    name: 'Đoản ngữ chưa rõ',
    desc: 'Chưa rõ ý nghĩa',
    type: 'phrase',
  },
  VCD: {
    name: 'Hợp động từ',
    desc: 'Cấu trúc động từ liên hợp',
    type: 'phrase',
  },
  VCP: {
    name: 'Động + 是',
    desc: 'Động từ với 是 làm bổ ngữ',
    type: 'phrase',
  },
  VNV: {
    name: 'Động 不/一 động',
    desc: 'Dạng lặp lại động từ + bất/nhất + động từ',
    type: 'phrase',
  },
  VP: {
    name: 'Cụm động từ',
    desc: 'Cụm từ thường đóng vai trò làm vị ngữ trong câu',
    type: 'phrase',
  },
  VPT: {
    name: 'Động 得 bổ',
    desc: 'Cụm động từ + bổ ngữ khả năng có 得 ở giữa',
    type: 'phrase',
  },
  VRD: {
    name: 'Động + bổ ngữ',
    desc: 'Động từ + bổ ngữ kết quả hoặc bổ ngữ xu hướng',
    type: 'phrase',
  },
  VSB: {
    name: 'Phụ ngữ + động',
    desc: 'Cụm từ đằng trước thường không có ý nghĩa',
    type: 'phrase',
  },
  OTH: {
    name: 'Các từ khác',
    desc: 'Các cụm từ khác không hợp với các loại từ còn lại',
    type: 'phrase',
  },

  NF: {
    name: 'Họ người',
    desc: 'Các từ dành cho họ của người, làm tên riêng đi kèm với danh xưng phía sau',
    type: 'word',
  },
  NS: {
    name: 'Danh xưng',
    desc: 'Xưng hô, nghề nghiệp của người như tỷ tỷ, muội muội, đại nhân, lão sư, tiểu thư',
    type: 'word',
  },
  NC: {
    name: 'Danh từ trung tâm',
    desc: 'Cụm danh từ khi có cụm định ngữ 的/之 phía trước',
    type: 'phrase',
  },
}
