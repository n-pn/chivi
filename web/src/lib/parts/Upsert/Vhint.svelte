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
  export let hints = []
  export let vpterm = {}

  $: [ptag_priv, ptag_base, tag_hints] = gen_hint(key)

  function gen_hint(key) {
    const priv = get_ptag(vpterm, '_priv') || ''
    const base = get_ptag(vpterm, '_base') || ''
    const list = [priv, base, vpterm._priv.ptag || '']

    const last_char = key.charAt(key.length - 1)
    if (locations.includes(last_char)) list.push('ns')
    if (organizations.includes(last_char)) list.push('nt')
    if (surnames.includes(key.charAt(0))) hints.push('nr')
    if (vpterm.ptag == 'nr') list.push('ns', 'nt')

    const hints = list.filter((x, i, s) => s.indexOf(x) == i)
    return [priv, base, hints.slice(0, 2)]
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

  {#each tag_hints as hint}
    {#if hint != vpterm.ptag}
      <button
        class="hint _ptag"
        class:_base={hint == ptag_base}
        class:_priv={hint == ptag_priv}
        on:click={() => (vpterm.ptag = hint)}>{tag_label(hint)}</button>
    {/if}
  {/each}
</div>

<style lang="scss">
  .hints {
    padding: 0 0.5rem;
    height: 2rem;

    @include flex($gap: 0.125rem);
    @include ftsize(sm);
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
      margin-left: auto;
      font-size: rem(13px);
    }

    &._priv, &._base { @include fgcolor(secd); }
    &._priv { font-weight: 500; }
    &._base { font-style: italic; }

    @include hover { @include fgcolor(primary, 5); }
  }
</style>
