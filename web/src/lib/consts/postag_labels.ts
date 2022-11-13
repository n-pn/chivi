export const labels = {
  E: {
    group: 'Tên riêng',
    short: 'Riêng',
    items: {
      Eh_x: 'Tên họ người',
      Es_p: 'Tên địa danh',
      Es_i: 'Tên tổ chức',
      // Es_: 'Nơi sở thuộc',
      // Es_g: 'Tên khu vực',
      Ez_w: 'Tên tác phẩm',
      Ez_b: 'Tên nhãn hiệu',
      // Ez_k: 'Tên chiêu thức',
      // Ez_r: 'Tên tộc loại',
      Ez_x: 'Tên riêng khác',
    },
  },

  N: {
    group: 'Danh từ',
    short: 'Danh',
    items: {
      Nh: 'Xưng hô',
      Nr_: 'Cá nhân',
      Ns_: 'Nơi chốn',
      Nt_: 'Thời gian',
      Na: 'Thuộc tính',
      Nb: 'Trừu tượng',
      No_: 'Vật đếm được',
      Nx: 'Danh từ khác',
      // Nx_l: 'Cụm chất danh từ',
    },
  },

  V: {
    label: 'Động từ',
    short: 'Động',
    items: {
      Vt_: 'Ngoại động từ',
      Vi_: 'Nội động từ',
      Vd: 'Phó động từ',
      Vn: 'Danh động từ',
      // Vp: 'Động từ tâm lý',
      // Vx: 'Động từ hình thức',
      // Vc: 'Động từ khởi phát',
      // Vm_: 'Động từ năng nguyện',
      Vr: 'Động từ so sánh',
      Vs_: 'Động từ đặc biệt',
    },
  },

  A: {
    group: 'Tính từ',
    short: 'Tính',
    items: {
      Aa_: 'Từ hình dung',
      Ab_: 'Từ khu biệt',
      An: 'Danh hình từ',
      Ad: 'Phó hình từ',
      Al_: 'Cụm chất tính từ',
      // As: 'Tính từ đặc biệt',
      // Az: 'Trạng thái từ',
    },
  },

  R: {
    label: 'Đại từ',
    short: 'Đại',
    items: {
      Rr_: 'Đại từ nhân xưng',
      Rz_: 'Đại từ chỉ thị',
      Ry_: 'Đại từ nghi vấn',
      // 'Rs_': 'Đại từ đặc biệt',
      Rx: 'Đại từ khác',
    },
  },

  M: {
    label: 'Số lượng',
    short: 'Số',
    items: {
      Mn_: 'Số từ thường',
      Mnf: 'Số không lượng',

      Mqn_: 'Danh lượng từ',
      Mqv_: 'Động lượng từ',
      Mqt_: 'Thời lượng từ',

      Mfn_: 'Số + lượng (danh)',
      Mfv_: 'Số + lượng (động)',
      Mft_: 'Số + lượng (thời)',

      Mh: 'Tiền tố số lượng',
      Mk: 'Hậu tố số lượng',
    },
  },

  // C: {
  //   label: 'Bổ ngữ', // bổ ngữ cho động từ/tính từ
  //   short: 'Bổ',

  //   items: {
  //     Cr: 'Bổ ngữ kết quả',
  //     Cg: 'Bổ ngữ trình độ',
  //     Cs: 'Bổ ngữ trạng thái',
  //     Cd: 'Bổ ngữ xu hướng',
  //     Cq: 'Bổ ngữ số lượng',
  //     Ct: 'Bổ ngữ thời lượng',
  //     Cp: 'Bổ ngữ khả năng',
  //   },
  // },

  F: {
    label: 'Hư từ',
    short: 'Hư',

    items: {
      Fv_: 'Bổ ngữ',
      Fd_: 'Phó từ',
      Fc_: 'Liên từ',
      Fcc: 'Liên từ liệt kê',
      Fp_: 'Giới từ',
      // Fcp: 'Giới từ so sánh',
      Fu_: 'Trợ từ',
      Fy_: 'Ngữ khí',
      Fo_: 'Thán từ',
      // Fo_o: 'Tượng thanh',
      Fg_: 'Ngữ tố',
    },
  },

  // G: {
  //   label: 'Ngữ tố',
  //   short: 'Tố',

  //   items: {
  //     Ghm: 'Tiền tố số lượng',
  //     Ghs: 'Tiền tố đặc biệt',

  //     Giv: 'Trung tố động từ',
  //     Gia: 'Trung tố tính từ',

  //     Gkm: 'Hậu tố số lượng',
  //     Gkt: 'Hậu tố thời gian',
  //     Gkn: 'Hậu tố danh từ',
  //     Gkb: 'Hậu tố thuộc tính',
  //     Gkv: 'Hậu tố động từ',
  //     Gka: 'Hậu tố tính từ',
  //     Gkz: 'Cụm 之 + hậu ngữ',
  //     Gks: 'Hậu tố đặc biệt',
  //   },
  // },

  X: {
    label: 'Loại khác',
    short: 'Khác',

    items: {
      Xv: 'Ly hợp: Động',
      Xo: 'Ly hợp: Tân',

      Xp_q: 'Trích thơ văn',
      Xp_t: 'Đoạn dịch tay',
      Xp_i: 'Ngữ cố định',

      Xs_e: 'Kaomoji',
      Xs_: 'Ký tự khác',

      Xw: 'Dấu câu',
      Xp_b: 'Chưa phân loại',
    },
  },

  // P: {
  //   label: 'Cấu trúc', // cấu trúc ngữ pháp
  //   short: 'Cấu',
  //   items: {
  //     Ppn: 'Cụm giới danh',
  //     Psv: 'Cụm chủ động',
  //     Psa: 'Cụm chủ tính',
  //     Pdp: 'Cụm định ngữ',
  //     Pdr: 'Cụm trạng ngữ',
  //     Pdv: 'Cụm bổ ngữ',
  //   },
  // },
}
