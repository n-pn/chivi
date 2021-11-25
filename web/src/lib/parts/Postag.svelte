<script context="module">
  export const ptnames = {
    '_': 'Không rõ',
    'nr': 'Tên người',
    'ns': 'Địa danh',
    'nt': 'Tổ chức',
    'nz': 'Tên riêng khác',

    'n': 'Danh từ',
    'nw': 'Danh xưng',
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
    'vl': 'Cụm động tân',
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
    'xx': 'Kaomoji',
    'xu': 'Đường link',
    'w': 'Dấu câu',

    '!': 'Từ đặc biệt',
    'vp': 'Cụm động từ',
    'np': 'Cụm danh từ',
    'ap': 'Cụm tính từ',
    'dp': 'Cụm định ngữ',
    'sv': 'Cụm chủ + vị (động)',
    'sa': 'Cụm chủ + vị (tính)',
  }

  // prettier-ignore
  export const tooltips = {
    '_': 'Các thực từ chưa được phân loại',
    'nr': 'Tên/họ riêng của người, như Trương Tam, Joe hay Kazuto.',
    'ns': 'Tên địa danh như nước Tống, núi Thiếm Lâm, Trường Giang',
    'nt': 'Tên cơ quan, tổ chức, bang phái',
    'nz': 'Các từ viết hoa khác như tựa sách, chiêu thức, từ viết tắt đứng độc lập',
    'n': 'Danh từ thông dụng như tên động vật, đồ vật hoặc các khái niệm trừu tượng',
    'nw': 'Danh xưng cho người như tỷ tỷ, muội muội, đại nhân, lão sư, tiểu thư',
    // 'nc': 'Danh từ trừu tượng,
    's': 'Từ chỉ nơi chốn của đồ vật như trên bàn, dưới núi, trong thư viện',
    'f': 'Các danh từ chỉ phương hướng như phía trên, bên dưới, đằng sau, ở giữa',
    't': 'Các từ chỉ thời gian như buổi sáng, 12 giờ, thứ hai, tháng 7, năm 2021',
    'ng': 'Ngữ tố danh từ',
    'tg': 'Ngữ tố thời gian',

    'a': 'Các từ mô tả hình dạng/tính chất của sự vật, hoặc trạng thái của hành vi',
    'b': 'Tính từ phi vị ngữ, có thể làm định ngữ trực tiếp cho danh từ không cần 的',
    'al': 'Từ trạng thái như ướt sùng sũng, đo đỏ / Các thành ngữ mang vai trò tính từ',
    'an': 'Từ vừa đóng vai trò tính từ vừa đóng vai trò danh từ',
    'ad': 'Từ vừa đóng vai trò tính từ vừa có thể là trạng ngữ cho động từ',
    'ag': 'Ngữ tố tính từ',

    'v': 'Từ chỉ động tác, hành vi, biến hoá, phát triển. Đằng sau cần một hoặc 2 tân ngữ',
    'vd': 'Những từ vừa có vai trò là động từ vừa có thể làm trạng ngữ cho động từ đằng sau',
    'vn': 'Các từ vừa đóng vai trò động từ vừa đóng vai trò danh từ. Cần tân ngữ',
    'vi': 'Các động từ không cần thiết tân ngữ đằng sau',
    'vf': 'Động từ xu hướng',
    'vx': 'Động từ mang nghĩa bổ xung cho động từ đằng sau, đứng độc lập không có nghĩa',
    'vm': 'Trợ động từ biểu đạt năng lực, nguyện vọng, yêu cầm, khả năng của một việc',
    'vg': 'Ngữ tố động từ',

    'rr': 'Đại từ chỉ ngôi thứ nhất, thứ hai hoặc thứ ba. Ví dụ ta, ngươi, hắn, trẫm, ngài',
    'rz': 'Đại từ chỉ thị',
    'ry': 'Đại từ nghi vấn',
    'r': 'Đại từ chưa phân loại',

    'nl': 'Cụm danh từ',
    'bl': 'Cụm khu biệt',
    'vl': 'Cụm động tân',
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
    'xx': 'Kaomoji',
    'xu': 'Đường link',
    'w': 'Dấu câu',

    '!': 'Từ đặc biệt',
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
      'nr','ns','nt',
      'nz',
      '-',
      'n', 'nw', 't',
      's', 'f',
      '-',
      'a', 'an', 'ad',
      'b', 'al',
      '-',
      'v', 'vn', 'vd',
      'vi', 'vl',
      '-',
      'rr', 'rz', 'ry',
      'r',
      '-',
      'nl', 'i',
    ],
    // prettier-ignore
    [
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
      'x', 'xx', 'xu',
      'w', '!'
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
      case 'nr': return '1'
      case 'ns': return '2'
      case 'nt': return '3'
      case 'nz': return '4'
      case 'nw': return 'z'

      case 'an': return '5'
      case 'vn': return '6'

      default: return ''
    }
  }
</script>

<script>
  import { onMount } from 'svelte'
  import { tooltip } from '$utils/actions'

  import SIcon from '$atoms/SIcon.svelte'
  import Gmodal from '$molds/Gmodal.svelte'

  export let ptag = ''
  export let state = 1

  let active_tab = 0
  let origin_tab = 0

  let modal

  onMount(() => {
    if (!ptag) return

    origin_tab = find_group(ptag)
    active_tab = origin_tab > 0 ? origin_tab : 0
    // scroll_to_tab(active_tab)
    scroll_to_tag(ptag)
  })

  function hide_modal() {
    state = 1
  }

  function update_tag(ntag) {
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

<Gmodal _klass="postag" actived={state > 1} index={80} on_close={hide_modal}>
  <postag-wrap>
    <postag-head>
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

      <button type="button" class="-btn" data-kbd="esc" on:click={hide_modal}>
        <SIcon name="x" />
      </button>
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
                data-anchor="postag-wrap"
                on:click={() => update_tag(ntag)}>
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
  </postag-wrap>
</Gmodal>

<style lang="scss">
  postag-wrap {
    display: block;
    width: 28rem;
    max-width: 100%;
    padding-bottom: 0.25rem;

    @include bdradi();
    @include shadow(1);
    @include bgcolor(secd);

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
  }

  $tab-height: 2rem;

  postag-head {
    @include flex($gap: 0.25rem);
    padding-left: 0.75rem;
    padding-right: 0.25rem;

    height: $tab-height + 0.125rem;
    margin-bottom: 0.25rem;

    @include border(--bd-main, $loc: bottom);
    @include bdradi($loc: top);
    @include bgcolor(tert);

    > .-btn {
      padding: 0.25rem;
      @include fgcolor(tert);
      @include bgcolor(tert);

      &:hover {
        @include fgcolor(primary, 6);
      }
    }

    :global(svg) {
      width: 1.25rem;
      height: 1.25rem;
    }
  }

  postag-tabs {
    flex: 1;
    @include flex-cx($gap: 0.375rem);
  }

  .postag-tab {
    font-weight: 500;
    padding: 0 0.5rem;
    background-color: transparent;

    // height: $tab-height;
    line-height: $tab-height;
    flex-shrink: 0;

    @include ftsize(sm);
    @include fgcolor(tert);

    @include border(--bd-main, $loc: left-right);

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
      @include border(primary, 5, $width: 0.125rem, $loc: top);

      > span {
        display: block;
        margin-top: -0.125rem;
      }
    }
  }

  postag-body {
    display: block;

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
    @include bps(font-size, rem(13px), rem(14px));
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
