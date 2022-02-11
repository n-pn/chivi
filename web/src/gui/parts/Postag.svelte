<script context="module">
  export const ptnames = {
    '_': 'Không rõ',
    'nr': 'Tên người',
    'nn': 'Nơi sở thuộc',
    'nz': 'Tên riêng khác',

    'n': 'Danh từ',
    'nw': 'Danh xưng',
    'na': 'Thuộc tính',
    // 'nc': 'Danh từ trừu tượng,
    's': 'Nơi chốn',
    'f': 'Phương vị',
    't': 'Thời gian',
    'ng': 'Ngữ tố danh từ',
    'tg': 'Ngữ tố thời gian',

    'a': 'Hình dung từ',
    'b': 'Khu biệt từ',
    'al': 'Cụm tính từ',
    'an': 'Danh hình từ',
    'ad': 'Phó hình từ',
    'ag': 'Ngữ tố tính từ',

    'v': 'Động từ',
    'vd': 'Phó động từ',
    'vn': 'Danh động từ',
    'vi': 'Nội động từ',
    'vo': 'Cụm động tân',
    'vf': 'Động từ xu hướng',
    'vx': 'Động từ hình thức',
    'vm': 'Động từ năng nguyện',
    'vg': 'Ngữ tố động từ',

    'rr': 'Đại từ nhân xưng',
    'rz': 'Đại từ chỉ thị',
    'ry': 'Đại từ nghi vấn',
    'r': 'Đại từ chưa phân loại',

    'nl': 'Cụm danh từ',
    'i': 'Thành/quán ngữ',

    'm': 'Số từ',
    'q': 'Lượng từ',
    'mq': 'Số lượng từ',

    'd': 'Phó từ',
    'c': 'Liên từ',
    'cc': 'Liên từ liệt kê',
    'p': 'Giới từ',
    'u': 'Trợ từ',
    'e': 'Thán từ',
    'y': 'Ngữ khí',
    'o': 'Tượng thanh',

    // affixes
    'kn': 'Hậu tố danh từ',
    'ka': 'Hậu tố tính từ',
    'kv': 'Hậu tố động từ',
    'k': 'Hậu tố chưa phân loại',

    'x': 'Chữ latin',
    'xx': 'Chuỗi ký tự',
    'w': 'Dấu câu',

    '!': 'Từ đặc biệt',
    'np': 'Cụm danh từ',
    'vp': 'Cụm động từ',
    'ap': 'Cụm tính từ',
    'dp': 'Cụm định ngữ',
    'sv': 'Cụm chủ + vị (động)',
    'sa': 'Cụm chủ + vị (tính)',
  }

  // prettier-ignore
  export const tooltips = {
    '_': 'Các thực từ chưa được phân loại',
    'nr': 'Tên/họ riêng của người, như Trương Tam, Joe hay Kazuto.',
    'nn': 'Tên địa danh, khu vực, cơ quan, tổ chức, bang phái...',
    'nz': 'Các từ viết hoa khác như tựa sách, chiêu thức, từ viết tắt đứng độc lập',
    'n': 'Danh từ thông dụng như tên động vật, đồ vật hoặc các khái niệm trừu tượng',
    'nw': 'Danh xưng cho người như tỷ tỷ, muội muội, đại nhân, lão sư, tiểu thư',
    'na': 'Danh từ chỉ màu sắc, đặc điểm nhận dạng, phân chia cấp độ...',
    // 'nc': 'Danh từ trừu tượng,
    's': 'Từ chỉ nơi chốn của đồ vật như trên bàn, dưới núi, trong thư viện',
    'f': 'Các danh từ chỉ phương hướng như phía trên, bên dưới, đằng sau, ở giữa',
    't': 'Các từ chỉ thời gian như buổi sáng, 12 giờ, thứ hai, tháng 7, năm 2021',
    'ng': 'Kết quả của công cụ phân loại từ tự động, cần được đổi về dạng từ khác phù hợp hơn',
    'tg': 'Kết quả của công cụ phân loại từ tự động, cần được đổi về dạng từ khác phù hợp hơn',

    'a': 'Các từ mô tả hình dạng/tính chất của sự vật, hoặc trạng thái của hành vi',
    'b': 'Tính từ phi vị ngữ, có thể làm định ngữ trực tiếp cho danh từ không cần 的',
    'al': 'Từ trạng thái như ướt sùng sũng, đo đỏ / Các thành ngữ mang vai trò tính từ',
    'an': 'Từ vừa đóng vai trò tính từ vừa đóng vai trò danh từ',
    'ad': 'Từ vừa đóng vai trò tính từ vừa có thể là trạng ngữ cho động từ',
    'ag': 'Kết quả của công cụ phân loại từ tự động, cần được đổi về dạng từ khác phù hợp hơn',

    'v': 'Từ chỉ động tác, hành vi, biến hoá, phát triển. Đằng sau cần một hoặc 2 tân ngữ',
    'vd': 'Những từ vừa có vai trò là động từ vừa có thể làm trạng ngữ cho động từ đằng sau',
    'vn': 'Các từ vừa đóng vai trò động từ vừa đóng vai trò danh từ. Cần tân ngữ',
    'vi': 'Các động từ không cần thiết tân ngữ đằng sau',
    'vf': 'Đứng sau động từ, biểu thị xu hướng của động tác như lên, xuống, ra, vào...',
    'vx': 'Động từ mang nghĩa bổ xung cho động từ đằng sau, đứng độc lập không có nghĩa',
    'vm': 'Trợ động từ biểu đạt năng lực, nguyện vọng, yêu cầm, khả năng của một việc',
    'vg': 'Kết quả của công cụ phân loại từ tự động, cần được đổi về dạng từ khác phù hợp hơn',

    'rr': 'Đại từ chỉ ngôi thứ nhất, thứ hai hoặc thứ ba. Ví dụ ta, ngươi, hắn, trẫm, ngài',
    'rz': 'Các từ này, kia hoặc này/kia + lượng từ',
    'ry': 'Đại từ nghi vấn',
    'r': 'Đại từ chưa phân loại',

    'nl': 'Các cấu trúc kết hợp danh từ với số lượng từ hoặc đại từ chỉ thị ở đằng trước',
    'vo': 'Cấu trúc gồm một động từ + một danh từ, có thể làm định ngữ, bổ ngữ hoặc động từ li hợp',
    'i': 'Các cụm từ thường gặp nhưng chưa được phân loại sang danh/động/tính',

    'm': 'Các từ chỉ số lượng như một hai vạn ức, 1 2 3...',
    'q': 'Biểu thị đơn vị của sự vật hoặc động tác, ví dụ chiếc, con, quyển...',
    'mq': 'Các cụm từ là kết hợp của số từ và lượng từ',

    'd': 'Từ đặt trước động từ, tính từ đẻ làm trạng ngữ',
    'c': 'Liên từ là những hư từ dùng để liên kết từ với từ, cụm từ với cụm từ hoặc câu với câu',
    'cc': 'Các liên từ mang nghĩa liệt kê các từ tương đương, ví dụ "và", "với", "cùng"...',
    'p': 'Các từ có thể tổ hợp với các từ khác làm cụm giới từ làm định ngữ hoặc trạng ngữ',
    'u': 'Các từ đi kèm với từ, cụm từ hoặc câu để bổ trợ cho tác dụng của từ',
    'e': 'Từ biểu thị cảm thán, kêu gọi, hò hét, đối đáp',
    'y': 'Trợ từ ngữ khí: vừa là trợ từ vừa là thán từ',
    'o': 'Những từ mô phỏng âm thanh',

    // affixes
    'kn': 'Hậu tố danh từ',
    'ka': 'Hậu tố tính từ',
    'kv': 'Hậu tố động từ',
    'k': 'Hậu tố chưa phân loại',

    'x': 'Các cụm từ là chữ cái latin từ a tới z, bao gồm cả gạch chân _',
    'xx': 'Dùng để ký hiệu các cụm từ emoji/kaomoji hoặc là đường link',
    'w': 'Các loại dấu câu như chấm hỏi, chấm than, hai chấm, ba chấm...',

    '!': 'Các từ được sử lý đặc biệt trong máy dịch',
    'vp': 'Cụm động từ',
    'np': 'Cụm danh từ',
    'ap': 'Cụm tính từ',
    'dp': 'Cụm định ngữ',
    'sv': 'Cụm chủ + vị (động)',
    'sa': 'Cụm chủ + vị (tính)',
  }

  export const gnames = ['Cơ bản', 'Hiếm gặp', 'Đặc biệt']

  export const groups = [
    // prettier-ignore
    [
      'nr','nn', 'nz',
      '-',
      'n', 'nw', 'na',
      't', 's', 'f',
      '-',
      'a', 'an', 'ad',
      'b', 'al',
      '-',
      'v', 'vn', 'vd',
      'vi', 'vo',
      '-',
      'rr', 'rz', 'ry',
      'r',
    ],
    // prettier-ignore
    [
      '-',
      'nl', 'i',
      '-',
      'm', 'q', 'mq',
      '-',
      'vx', 'vm', 'vf',
      '-',
      'd', 'p', 'u',
      'c', 'cc',
      '-',
      'e', 'y', 'o',
    ],
    // prettier-ignore
    [
      '-',
      'kn', 'ka', 'kv',
      'ag', 'vg', 'ng',
      'tg',
      '-',
      'x', 'xx', 'w',
      '!'
    ],
  ]

  function find_group(tag) {
    for (const [idx, group] of groups.entries()) {
      if (group.includes(tag)) return idx
    }

    return -1
  }

  function map_kbd(tag) {
    if (tag.length == 1) return tag

    // prettier-ignore
    switch (tag) {
      case 'nr': return '['
      case 'nn': return ']'
      case 'nz': return '.'
      case 'nw': return '/'

      case 'al': return ';'
      case 'vo': return '\''

      default: return ''
    }
  }
</script>

<script>
  import { onMount } from 'svelte'
  import { tooltip } from '$utils/custom_actions'

  import SIcon from '$atoms/SIcon.svelte'
  import Dialog from '$molds/Dialog.svelte'

  export let ptag = ''
  export let state = 1

  let active_tab = 0
  let origin_tab = 0

  let modal

  onMount(() => {
    if (!ptag) return
    origin_tab = find_group(ptag)
    active_tab = origin_tab > 0 ? origin_tab : 0
    scroll_to_tag(ptag)
  })

  const on_close = (ntag) => {
    ptag = ptag == ntag ? '' : ntag
    state = 1
  }

  function scroll_to_tab(tab) {
    sections[tab]?.scrollIntoView({ behavior: 'smooth' })
    active_tab = tab
  }

  function scroll_to_tag(tag) {
    modal
      ?.querySelector(`.pos-tag[data-tag="${tag}"]`)
      ?.scrollIntoView({ behavior: 'smooth', block: 'center' })
  }

  let sections = []
</script>

<Dialog actived={state == 2} --z-idx={80} class="postag" {on_close}>
  <postag-head slot="header">
    <postag-tabs>
      {#each gnames as gname, tab}
        <button
          class="postag-tab"
          class:_active={tab == active_tab}
          class:_origin={tab == origin_tab}
          on:click={() => scroll_to_tab(tab)}>
          <span>{gname}</span>
        </button>
      {/each}
    </postag-tabs>
  </postag-head>

  <postag-body>
    {#each groups as tags, tab}
      <section class="tags" bind:this={sections[tab]}>
        {#each tags as ntag}
          {#if ntag != '-'}
            <button
              class="pos-tag"
              class:_active={ntag == ptag}
              data-tag={ntag}
              data-kbd={map_kbd(ntag)}
              use:tooltip={tooltips[ntag]}
              data-anchor="postag-body"
              on:click={() => on_close(ntag)}>
              <span>{ptnames[ntag]}</span>
              {#if ntag == ptag}
                <SIcon name="check" />
              {/if}
            </button>
          {:else}
            <div class="-sep" />
          {/if}
        {/each}
      </section>
    {/each}
  </postag-body>
</Dialog>

<style lang="scss">
  $tab-height: 1.875rem;

  postag-head {
    @include flex($gap: 0.5rem);
    padding-left: 0.25rem;
    flex: 1;
    height: $tab-height + 0.125rem;
  }

  postag-tabs {
    flex: 1;
    padding-top: 0.375rem;
    @include flex-cx($gap: 0.375rem);
  }

  .postag-tab {
    font-weight: 500;
    padding: 0 0.5rem;
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

    &._origin {
      @include fgcolor(secd);
    }

    &._active {
      @include bgcolor(secd);
      @include fgcolor(primary, 5);
      @include bdcolor(primary, 5);
    }
  }

  postag-body {
    display: block;
    position: relative;
    padding-top: 0.25rem;
    height: 22rem;
    max-height: calc(100vh - 6.5rem);
    @include scroll();
    @include bgcolor(secd);
  }

  .tags {
    @include grid(null, $gap: 0.375rem);
    grid-template-columns: 1fr 1fr 1fr;
    padding: 0.5rem 0.75rem;
  }

  .pos-tag {
    padding: 0.25rem 0.5rem;
    background: transparent;
    font-weight: 500;

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
  }

  .-sep {
    width: 50%;
    grid-column: 1 / -1;
    margin: 0.125rem auto;
    @include border(--bd-main, $loc: top);
  }
</style>
