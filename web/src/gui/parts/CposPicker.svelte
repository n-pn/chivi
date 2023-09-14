<script context="module" lang="ts">
  export const cpos_map = {
    _: {
      name: 'Không rõ',
      desc: 'Dành cho các từ chưa được phân loại chuẩn',
      type: 'base',
      used: true,
    },
    A: {
      name: 'Tính (chung)',
      desc: 'Nghĩa chung cho các từ loại tính từ',
      type: 'base',
      used: false,
    },
    N: {
      name: 'Danh (chung)',
      desc: 'Nghĩa chung cho các từ loại danh từ',
      type: 'base',
      used: false,
    },
    V: {
      name: 'Động (chung)',
      desc: 'Nghĩa chung cho các từ loại động từ',
      type: 'base',
      used: false,
    },
    X: {
      name: 'Khác (chung)',
      desc: 'Nghĩa chung cho các hư từ khác',
      type: 'base',
      used: false,
    },
    AD: {
      name: 'Phó từ',
      desc: 'Các từ đặt trước động từ, tính từ làm trạng ngữ cho động/tính từ phía sau',
      type: 'word',
      used: true,
    },
    AS: {
      name: 'Động thái',
      desc: 'Các từ 了/过/在/着 đánh dấu thể/động thái (aspect) của động từ trong câu',
      type: 'word',
      used: true,
    },
    BA: {
      name: 'Giới từ 把',
      desc: 'Giới từ 把/将 trong cấu trúc đặc biệt dùng 把/将',
      type: 'word',
      used: true,
    },
    CC: {
      name: 'Liên kết',
      desc: 'Liên từ liệt kê (coordinating conjunction) kết nối từ với từ, cụm từ với cụm từ',
      type: 'word',
      used: true,
    },
    CD: {
      name: 'Số đếm',
      desc: 'Các từ chỉ số đếm như 1, hai, trăm triệu, vài...',
      type: 'word',
      used: true,
    },
    CS: {
      name: 'Liên từ',
      desc: 'Các từ để liên kết các cụm ngữ pháp trong câu hoặc giữa các đoạn văn (subordinating conjunction)',
      type: 'word',
      used: true,
    },
    DEC: {
      name: 'Bổ trợ 的',
      desc: 'Trợ từ 的/之 dùng để đánh dấu cụm vị ngữ/cụm chủ vị làm định ngữ cho danh từ (complementizer)',
      type: 'word',
      used: true,
    },
    DEG: {
      name: 'Thuộc cách 的',
      desc: 'Trợ từ 的/之 đánh dấu thuộc cách cho cụm danh từ/đại từ đằng trước (genitive marker)',
      type: 'word',
      used: true,
    },
    DER: {
      name: 'Nhân quả 得',
      desc: 'Trợ từ 得 đánh dấu bổ ngữ nhân quả cho động từ (đứng sau động từ)',
      type: 'word',
      used: true,
    },
    DEV: {
      name: 'Cách thức 地',
      desc: 'Trợ từ 地 đánh dấu trạng ngữ cách thức cho động từ phía sau',
      type: 'word',
      used: true,
    },
    DT: {
      name: 'Hạn định',
      desc: 'Các từ như 这(này), 那(kia) đứng đầu cụm danh từ, trước số lượng từ làm định ngữ',
      type: 'word',
      used: true,
    },
    ETC: {
      name: 'Liệt kê',
      desc: 'Các từ như 等/等等 đi sau danh từ/cụm danh từ mang ý nghĩa liệt kê',
      type: 'word',
      used: true,
    },
    EM: {
      name: 'Biểu tượng',
      desc: 'Các từ chỉ biểu tượng cảm xúc, biểu ngữ hình mặt (emoji, emoticon)',
      type: 'word',
      used: true,
    },
    FW: {
      name: 'Ngoại lai',
      desc: 'Các từ tiếng nước ngoài chưa có vai trò từ loại khác trong câu',
      type: 'word',
      used: true,
    },
    IJ: {
      name: 'Thán từ',
      desc: 'Từ biểu thị cảm thán, kêu gọi, hò hét, đối đáp',
      type: 'word',
      used: true,
    },
    JJ: {
      name: 'Khu biệt',
      desc: '',
      type: 'word',
      used: true,
    },
    LB: {
      name: '被 dài',
      desc: 'Từ 被 trong cấu trúc 被 + cụm trạng ngữ + động từ',
      type: 'word',
      used: true,
    },
    LC: {
      name: 'Phương vị',
      desc: '',
      type: 'word',
      used: true,
    },
    M: {
      name: 'Lượng từ',
      desc: '',
      type: 'word',
      used: true,
    },
    MSP: {
      name: 'Trợ từ',
      desc: '',
      type: 'word',
      used: true,
    },
    NOI: {
      name: 'Từ rác',
      desc: 'Các từ không đóng vai trò gì trong câu, thường do lỗi chính tả',
      type: 'word',
      used: true,
    },
    NN: {
      name: 'Danh từ',
      desc: 'Các danh từ chỉ động thực vật, đồ vật, địa điểm, khái niệm...',
      type: 'word',
      used: true,
    },
    NR: {
      name: 'Tên riêng',
      desc: 'Các từ thường viết hoa như tên người, tổ chức, địa danh, tác phẩm, chiêu thức...',
      type: 'word',
      used: true,
    },
    NT: {
      name: 'Thời gian',
      desc: 'Các từ chỉ thời gian như buổi sáng, 12 giờ, thứ hai, tháng 7, năm 2021',
      type: 'word',
      used: true,
    },
    OD: {
      name: 'Số thứ tự',
      desc: '',
      type: 'word',
      used: true,
    },
    ON: {
      name: 'Tượng thanh',
      desc: 'Các từ dùng để mô tả âm thanh, tiếng động',
      type: 'word',
      used: true,
    },
    P: {
      name: 'Giới từ',
      desc: '',
      type: 'word',
      used: true,
    },
    PN: {
      name: 'Đại từ',
      desc: 'Các loại đại từ: nhân xưng, chỉ thị, nghi vấn...',
      type: 'word',
      used: true,
    },
    PU: {
      name: 'Dấu câu',
      desc: 'Các loại dấu câu như chấm hỏi, chấm than, hai chấm...',
      type: 'word',
      used: true,
    },
    SB: {
      name: '被 ngắn',
      desc: 'Từ 被 trong cấu trúc 被 + động từ',
      type: 'word',
      used: true,
    },
    SP: {
      name: 'Ngữ khí',
      desc: '',
      type: 'word',
      used: true,
    },
    URL: {
      name: 'Đường link',
      desc: 'Các từ chỉ ',
      type: 'word',
      used: true,
    },
    VA: {
      name: 'Hình dung',
      desc: '',
      type: 'word',
      used: true,
    },
    VC: {
      name: 'Hệ từ 是',
      desc: 'Các động từ như 是/为/非 làm động từ liên hệ trong câu',
      type: 'word',
      used: true,
    },
    VE: {
      name: 'Tồn hiện 有',
      desc: 'Các động từ như 有/没有/无 làm động từ chính trong cấu trúc tồn hiện',
      type: 'word',
      used: true,
    },
    VV: {
      name: 'Động từ',
      desc: 'Các từ chỉ động tác, hành vi, biến hoá, phát triển.',
      type: 'word',
      used: true,
    },
    ADJP: {
      name: 'Cụm tính từ',
      desc: 'Cụm từ hình dung/khu biệt kết hợp với DEC làm định ngữ cho danh từ phía sau',
      type: 'phrase',
      used: true,
    },
    ADVP: {
      name: 'Cụm trạng ngữ',
      desc: 'Cụm từ kết hợp thời gian/phó từ/động từ với DEV làm trạng ngữ cho động từ phía sau',
      type: 'phrase',
      used: true,
    },
    CLP: {
      name: 'Cụm số lượng',
      desc: '',
      type: 'phrase',
      used: true,
    },
    CP: {
      name: 'Cụm bổ ngữ',
      desc: '',
      type: 'phrase',
      used: true,
    },
    DNP: {
      name: 'Cụm thuộc cách',
      desc: '',
      type: 'phrase',
      used: true,
    },
    DP: {
      name: 'Cụm hạn định',
      desc: '',
      type: 'phrase',
      used: true,
    },
    DVP: {
      name: 'Cụm cách thức',
      desc: '',
      type: 'phrase',
      used: true,
    },
    FRAG: {
      name: 'Đoạn cụm từ',
      desc: '',
      type: 'phrase',
      used: true,
    },
    INTJ: {
      name: 'Cụm thán từ',
      desc: '',
      type: 'phrase',
      used: true,
    },
    IP: {
      name: 'Cụm chủ vị',
      desc: '',
      type: 'phrase',
      used: true,
    },
    LCP: {
      name: 'Cụm phương vị',
      desc: '',
      type: 'phrase',
      used: true,
    },
    LST: {
      name: 'Dấu danh sách',
      desc: '',
      type: 'phrase',
      used: true,
    },
    NP: {
      name: 'Cụm danh từ',
      desc: '',
      type: 'phrase',
      used: true,
    },
    PP: {
      name: 'Cụm giới từ',
      desc: '',
      type: 'phrase',
      used: true,
    },
    PRN: {
      name: 'Cụm ngoặc đơn',
      desc: '',
      type: 'phrase',
      used: true,
    },
    QP: {
      name: 'Cụm lượng từ',
      desc: '',
      type: 'phrase',
      used: true,
    },
    TOP: {
      name: 'Cả đoạn văn',
      desc: '',
      type: 'phrase',
      used: true,
    },
    UCP: {
      name: 'Đoản ngữ chưa rõ',
      desc: '',
      type: 'phrase',
      used: true,
    },
    VCD: {
      name: 'Hợp động từ',
      desc: '',
      type: 'phrase',
      used: true,
    },
    VCP: {
      name: 'Động + 是',
      desc: '',
      type: 'phrase',
      used: true,
    },
    VNV: {
      name: 'Động 不/一 động',
      desc: '',
      type: 'phrase',
      used: true,
    },
    VP: {
      name: 'Cụm động từ',
      desc: '',
      type: 'phrase',
      used: true,
    },
    VPT: {
      name: 'Động 得 bổ',
      desc: '',
      type: 'phrase',
      used: true,
    },
    VRD: {
      name: 'Động + bổ ngữ',
      desc: '',
      type: 'phrase',
      used: true,
    },
    VSB: {
      name: 'Phụ ngữ + động',
      desc: '',
      type: 'phrase',
      used: true,
    },
  }

  const list = Object.entries(cpos_map)

  const tabs = [
    {
      name: 'Cơ sở',
      list: list.filter(([_, { type }]) => type == 'base'),
    },
    {
      name: 'Từ đơn',
      list: list.filter(([_, { type }]) => type == 'word'),
    },
    {
      name: 'Cụm từ',
      list: list.filter(([_, { type }]) => type == 'phrase'),
    },
  ]

  const in_group = (curr_cpos: string, group: Array<[string, any]>) => {
    for (const [cpos] of group) {
      if (cpos == curr_cpos) return true
    }
    return false
  }
</script>

<script lang="ts">
  import { tooltip } from '$lib/actions'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  export let actived = false
  export let output = ''

  // prettier-ignore
  const on_close = (_?: any) => { actived = false }

  const pick_pos = (npos: string) => {
    output = npos
    on_close()
  }

  const scroll_to = (name: string) => {
    const elem = document.getElementById(`cpos-${name}-group`)
    if (elem) elem.scrollIntoView({ block: 'center', behavior: 'smooth' })
  }
</script>

<Dialog --z-idx={80} class="postag" {on_close}>
  <svelte:fragment slot="header">
    <span>Từ loại:</span>
    <span class="tabs">
      {#each tabs as { name, list }, idx}
        <button
          class="htab"
          class:_active={in_group(output, list)}
          data-kbd={idx + 1}
          on:click={() => scroll_to(name)}>
          <span>{name}</span>
        </button>
      {/each}
    </span>
  </svelte:fragment>

  <section class="body">
    {#each tabs as { name, list }}
      <h3 id="cpos-{name}-group">{name}</h3>
      <div class="cpos-list">
        {#each list as [cpos, { name, desc, used }]}
          {@const active = cpos == output}
          <button
            class="cpos-item"
            class:_active={active}
            class:_unused={!used}
            data-tag={cpos}
            use:tooltip={desc}
            data-anchor=".postag"
            on:click={() => pick_pos(cpos)}>
            <code>{cpos}</code>
            <span>{name}</span>
            {#if active}<SIcon name="check" />{/if}
          </button>
        {/each}
      </div>
    {/each}
  </section>

  <footer class="foot">
    <p><code>∗</code>: Những từ loại chưa có tác dụng!</p>
  </footer>
</Dialog>

<style lang="scss">
  $tab-height: 1.875rem;

  // .head {
  //   @include flex($gap: 0.5rem);
  //   padding-left: 0.25rem;
  //   flex: 1;
  //   height: $tab-height + 0.125rem;
  // }

  .tabs {
    flex: 1;
    padding-top: 0.375rem;
    margin-right: 1rem;
    @include flex-cx($gap: 0.25rem);
  }

  .htab {
    font-weight: 500;
    padding: 0 0.75rem;
    background-color: transparent;

    height: $tab-height;
    line-height: $tab-height;
    flex-shrink: 0;

    @include ftsize(sm);
    @include fgcolor(tert);

    @include bdradi($loc: top);
    @include border(--bd-main, $loc: top-left-right);

    &:hover {
      @include bgcolor(secd);
    }

    &._active {
      @include bgcolor(secd);
      @include fgcolor(primary, 5);
      @include bdcolor(primary, 5);
    }
  }

  h3 {
    font-weight: 500;
    line-height: 2.25rem;
    margin: 0rem 0.75rem;
    font-size: rem(15px);
    @include fgcolor(tert);

    // &.active {
    //   @include fgcolor(primary);
    // }
  }

  .body {
    display: block;
    position: relative;
    // padding-top: 0.25rem;
    padding-bottom: 0.75rem;
    height: 22rem;
    max-height: calc(100vh - 6.5rem);
    @include scroll();
    @include bgcolor(secd);
  }

  .cpos-list {
    @include grid(null, $gap: 0.375rem);
    grid-template-columns: 1fr 1fr 1fr;
    padding: 0 0.75rem;
  }

  .cpos-item {
    padding: 0.25rem 0.5rem;
    background: transparent;
    // font-weight: 500;

    code {
      margin-right: -0.2em;
    }

    flex-shrink: 1;
    line-height: 1.5rem;

    @include linesd(--bd-main);

    @include fgcolor(tert);
    @include bdradi(0.75rem);
    @include bps(font-size, rem(13px), $pl: rem(14px));
    @include clamp($width: 100%);

    &:hover,
    &._active {
      @include fgcolor(primary, 7);
      @include bgcolor(primary, 1);
      @include linesd(primary, 2, $ndef: false);

      @include tm-dark {
        @include fgcolor(primary, 3);
        @include bgcolor(primary, 9, 5);
        @include linesd(primary, 8, $ndef: false);
      }
    }

    &._unused {
      @include fgcolor(mute);
      font-style: italic;
      &:after {
        content: '∗';
      }
    }
  }

  .foot {
    @include flex-ca;
    @include fgcolor(tert);
    font-style: italic;
    @include ftsize(sm);
  }
</style>
