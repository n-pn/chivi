<script context="module">
  // prettier-ignore
  const surnames = [
    "赵", "钱", "孙", "李", "周", "吴", "郑", "王", "冯", "陈",
    "褚", "衞", "蒋", "沈", "韩", "杨", "朱", "秦", "尤", "许",
    "何", "吕", "施", "张", "孔", "曹", "严", "华", "金", "魏",
    "陶", "姜", "戚", "谢", "邹", "喻", "柏", "水", "窦", "章",
    '雲', '苏', '潘', '葛', '奚', '范', '彭', '郎', '鲁', '韦',
    '昌', '马', '苗', '凤', '花', '方', '俞', '任', '袁', '柳',
    '酆', '鮑', '史', '唐', '費', '廉', '岑', '薛', '雷', '賀',
    '倪', '湯', '滕', '殷', '罗', '毕', '郝', '邬', '安', '常',
  ]

  // prettier-ignore
  const locations = [
    '区', '谷', '町', '山', '岛', '国', '洲', '海', '峡', '省',
    '湾', '江', '市', '桥', '宫', '城', '池', '县', '寺', '殿',
    '峠', '乡', '川', '园', '湖', '都', '堂', '坡', '河', '坂',
    '社', '关', '门', '墟', '庙', '镇', '院', '村'
  ]

  // prettier-ignore
  const organizations = [
    '门', '教', '组', '朝', '校', '廷', '会', '部', '司', '宗',
    '派', '家', '人', '楼', '氏', '府', '队', '织', '学', '院',
  ]
</script>

<script>
  import { tag_label } from '$lib/pos_tag.js'

  export let key = ''
  export let tab = 0
  export let hints = []
  export let vpterm = {}

  $: [ptag_priv, ptag_base, tag_hints] = gen_hint(key, tab, vpterm)

  function gen_hint(key, tab, vpterm) {
    if (tab > 1) return ['', '', []]

    const priv = get_ptag(vpterm, '_priv') || ''
    const base = get_ptag(vpterm, '_base') || ''
    const list = [priv, base, ...similar_tag(vpterm.ptag)]

    const last_char = key.charAt(key.length - 1)
    if (locations.includes(last_char)) list.push('ns')
    if (organizations.includes(last_char)) list.push('nt')
    if (surnames.includes(key.charAt(0))) list.push('nr')

    if (tab == 0) list.push('nr', 'ns', 'nt')
    else list.push('n', 'nr')

    const filter = (x, i, s) => x && x != vpterm.ptag && s.indexOf(x) == i
    const hints = list.filter(filter)
    return [priv, base, hints.slice(0, 2)]
  }

  function similar_tag(ptag) {
    switch (ptag) {
      case '_':
        return ['n', 'a', 'v']

      case 'ng':
      case 'nl':
      case 'np':
        return ['n']

      case 'nz':
        return ['nr', 'n']

      case 'n':
        return ['s', 't']

      case 'a':
        return ['b', 'an']

      case 'b':
        return ['a', 'n']

      case 'az':
        return ['a', 'al']

      case 'an':
        return ['a', 'n']

      case 'ad':
        return ['a', 'd']

      case 'ag':
        return ['a', 'k']

      case 'v':
        return ['vi', 'vn']

      case 'vd':
        return ['v', 'd']

      case 'vn':
        return ['v', 'n']

      case 'vi':
        return ['v', 'vl']

      case 'vg':
        return ['v', 'kv']

      case 'r':
      case 'rr':
      case 'ry':
      case 'rz':
        return ['rr', 'rz', 'ry']

      case 'al':
        return ['a', 'bl']

      case 'bl':
        return ['b', 'al']

      case 'vl':
        return ['al', 'nl']

      case 'i':
        return ['nl', 'vl']

      case 'm':
      case 'q':
      case 'mp':
        return ['m', 'q', 'mq']

      case 'c':
      case 'cc':
      case 'd':
        return ['d', 'c', 'cc']

      case 'e':
      case 'y':
      case 'o':
        return ['e', 'y', 'o']

      case 'k':
      case 'ka':
      case 'kn':
      case 'kv':
        return ['ka', 'kn', 'kv']

      default:
        return ['n']
    }
  }

  function get_ptag(vpterm, type) {
    const orig = vpterm[type]
    return orig.mtime < 0 || orig.ptag == vpterm.ptag ? null : orig.ptag
  }
</script>

<div class="hints">
  {#each hints as hint, idx (hint)}
    {#if (idx == 0 || hint != vpterm.val.trim()) && hint}
      <button
        class="hint"
        class:_base={vpterm._base.mtime >= 0 && hint == vpterm._base.val}
        class:_priv={vpterm._priv.mtime >= 0 && hint == vpterm._priv.val}
        on:click={() => (vpterm.val = hint)}>{hint}</button>
    {/if}
  {/each}

  <div class="right">
    {#each tag_hints as hint}
      <button
        class="hint _ptag"
        class:_base={hint == ptag_base}
        class:_priv={hint == ptag_priv}
        on:click={() => (vpterm.ptag = hint)}>{tag_label(hint)}</button>
    {/each}
  </div>
</div>

<style lang="scss">
  .hints {
    padding: 0 0.5rem;
    height: 2rem;

    @include flex($gap: 0.125rem);
    @include ftsize(sm);
  }

  .right {
    margin-left: auto;
    @include flex();
    max-width: 30%;
  }

  // prettier-ignore
  .hint {
    cursor: pointer;
    padding: 0.25rem;
    line-height: 1.5rem;
    background-color: inherit;
    @include fgcolor(tert);

    @include bdradi;
    @include clamp($width: null);

    &._ptag {

      font-size: rem(13px);
    }

    &._priv, &._base { @include fgcolor(secd); }
    &._priv { font-weight: 500; }
    &._base { font-style: italic; }

    @include hover { @include fgcolor(primary, 5); }
  }
</style>
