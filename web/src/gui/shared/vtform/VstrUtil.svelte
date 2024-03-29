<script context="module" lang="ts">
  import { titleize, detitleize, capitalize, uncapitalize } from '$utils/text_utils'

  import { gtran_word } from '$utils/qtran_utils'
  import { deepl_word } from '$utils/qtran_utils/dl_tran'
  import { btran_word } from '$utils/qtran_utils/ms_tran'
  import { baidu_word } from '$utils/qtran_utils/bd_tran'

  const cached_map = new Map<string, string[]>()

  const do_fetch = async (ztext: string, qkind: string) => {
    if (qkind == 'gtran') return await gtran_word(ztext, 'vi')
    if (qkind == 'btran') return await btran_word(ztext, 'zh')
    if (qkind == 'deepl') return [await deepl_word(ztext, 0)]

    if (qkind == 'baidu') {
      const trans = await baidu_word(ztext, 'vie')
      if (ztext.endsWith('。')) return trans
      return trans.map((x) => x.replace(/\.$/, ''))
    }

    const n_res = await fetch(`/_sp/utils/${qkind}?zh=${ztext}`)
    const trans = await n_res.text()
    return n_res.ok ? trans.split('\n') : [n_res.status.toString()]
  }

  const fetch_trans = async (ztext: string, qkind: string, keep_caps = false) => {
    const c_ukey = `${qkind}-${ztext}`

    let trans = cached_map.get(c_ukey)

    if (!trans) {
      trans = await do_fetch(ztext, qkind)
      if (trans.length > 0) cached_map.set(c_ukey, trans)
    }

    if (!keep_caps && should_be_lowercase(qkind, trans[0])) {
      trans = trans.map((x) => uncapitalize(x))
    }

    return trans
  }

  const should_be_lowercase = (qkind: string, vtran: string) => {
    if (qkind == 'defns' || qkind == 'names') return false
    return vtran == titleize(vtran, 1)
  }
</script>

<script lang="ts">
  import { tooltip } from '$lib/actions'
  import type { Viform } from './zvdefn_form'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let tform: Viform
  export let field: HTMLInputElement

  let show_more = false
  let more_type = ''

  const trigger_more = (type: string) => {
    field.focus()
    if (more_type == type) {
      show_more = false
      more_type = ''
    } else {
      show_more = true
      more_type = type
    }
  }

  const gen_hviet_hints = (input: string) => {
    const output = [input.toLowerCase()]
    if (input.match(/^[a-z0-9]+$/i)) output.push(input.toUpperCase())
    return [...new Set(output)]
  }

  const handle_click = (event: Event) => {
    const target = event.target as HTMLElement
    const vstr = target.dataset['vstr']
    if (vstr) {
      tform.vstr = vstr
      show_more = false
    }
  }

  $: all_lower = tform.vstr.toLowerCase()
  $: all_title = titleize(tform.vstr, 99)
  $: word_count = tform.vstr.split(' ').length

  let title_count = 1
  let detitle_count = 1

  $: keep_caps = tform.cpos == 'NR'

  const call_titleize = () => {
    tform.vstr = titleize(tform.vstr, title_count)
    title_count = title_count >= word_count ? 1 : title_count + 1
  }

  const call_detitleize = () => {
    tform.vstr = detitleize(tform.vstr, detitle_count)
    detitle_count = detitle_count >= word_count ? 1 : detitle_count + 1
  }

  const tran_types = [
    ['defns', 'img', 'stack.svg'],
    ['names', 'img', 'hirashiba.png'],
    ['baidu', 'brand-baidu', 'extra'],
    ['gtran', 'brand-google'],
    ['btran', 'brand-bing'],
    ['deepl', 'img', 'deepl.svg'],
  ]

  const fill_qtran = async (qkind: string, keep_caps = false) => {
    tform.vstr = '...'
    const trans = await fetch_trans(tform.zstr, qkind, keep_caps)
    tform.vstr = trans[0]
  }
</script>

<div class="util">
  <div class="util-main">
    <button
      type="button"
      class="btn"
      data-kbd="h"
      on:click={() => (tform.vstr = tform.hviet)}
      use:tooltip={'Điền vào Hán Việt'}
      data-anchor=".vtform">
      <SIcon name="letter-h" />
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="b"
      on:click={() => fill_qtran('baidu', keep_caps)}
      use:tooltip={'Dịch nhanh bằng Baidu Fanyi'}
      data-anchor=".vtform">
      <SIcon name="brand-baidu" iset="extra" />
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="g"
      on:click={() => fill_qtran('gtran', keep_caps)}
      use:tooltip={'Dịch nhanh bằng Google Translate'}
      data-anchor=".vtform">
      <SIcon name="brand-google" />
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="d"
      on:click={() => fill_qtran('names', keep_caps)}
      use:tooltip={'Điền tên riêng từ từ điển tên riêng tổng hợp'}
      data-anchor=".vtform">
      <img src="/icons/hirashiba.png" alt="hirashiba" />
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="d"
      on:click={() => fill_qtran('deepl', keep_caps)}
      use:tooltip={'Dịch nhanh bằng DeepL Translator'}
      data-anchor=".vtform">
      <img src="/icons/deepl.svg" alt="deepl" />
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="t"
      class:_same={more_type == 'trans'}
      on:click={() => trigger_more('trans')}
      use:tooltip={'Tất cả các kết quả gợi ý dịch'}
      data-anchor=".vtform">
      <SIcon name="language" />
      <SIcon name="caret-down" />
    </button>

    <button
      type="button"
      class="btn u-right"
      data-kbd="9"
      class:_same={tform.vstr == all_title}
      on:click={() => (tform.vstr = all_title)}
      use:tooltip={'Viết hoa chữ đầu tất cả'}
      data-anchor=".vtform">
      <SIcon name="letter-case-upper" />
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="f"
      on:click={call_titleize}
      use:tooltip={`Viết hoa ${title_count} chữ đầu`}
      data-anchor=".vtform">
      <SIcon name="letter-case" />
      <sup>{title_count}</sup>
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="g"
      on:click={call_detitleize}
      use:tooltip={`Viết thường ${detitle_count} chữ đầu`}
      data-anchor=".vtform">
      <SIcon name="letter-case-toggle" />
      <sup>{detitle_count}</sup>
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="0"
      class:_same={tform.vstr == all_lower}
      on:click={() => (tform.vstr = all_lower)}
      use:tooltip={'Viết thường tất cả'}
      data-anchor=".vtform">
      <SIcon name="letter-case-lower" />
    </button>

    <button
      type="button"
      class="btn _lg"
      data-kbd="e"
      on:click={() => (tform = tform.clear())}
      use:tooltip={'Xoá nghĩa từ / Xoá phân loại'}
      data-anchor=".vtform">
      <SIcon name="eraser" />
    </button>

    <button
      type="button"
      class="btn _lg"
      data-kbd="r"
      on:click={() => (tform = tform.reset())}
      use:tooltip={'Phục hồi lại nghĩa + phân loại ban đầu'}
      data-anchor=".vtform">
      <SIcon name="corner-up-left" />
    </button>

    {#each [1, 2, 3, 4] as value}
      <button
        type="button"
        data-kbd={value}
        on:click={() => (tform.vstr = titleize(tform.vstr, value))}
        hidden>
      </button>
    {/each}
  </div>

  {#if show_more}
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div class="util-more" on:click={handle_click}>
      <SIcon name="letter-h" />
      {#each gen_hviet_hints(tform.hviet) as vstr}
        <span class="txt" class:_same={tform.vstr == vstr} data-vstr={vstr}>
          {vstr}
        </span>
      {/each}

      {#each tran_types as [qkind, itype, iname]}
        {#if itype == 'img'}
          <img src="/icons/{iname}" alt={qkind} />
        {:else}
          <SIcon name={itype} iset={iname || 'tabler'} />
        {/if}
        {#await fetch_trans(tform.ztext, qkind, keep_caps)}
          <SIcon name="loader-2" spin={true} />
        {:then list}
          {#each list as tran}
            <span class="txt" class:_same={tform.vstr == tran} data-vstr={tran}>{tran}</span>
          {/each}
        {/await}
      {/each}
    </div>
  {/if}
</div>

<style lang="scss">
  $height: 2.25rem;

  .util {
    position: relative;
  }

  .util-main {
    @include flex-cy;
    position: relative;
    padding-left: 0.375rem;
    padding-right: 0.25rem;
    height: $height;

    @include ftsize(sm);
    // @include bps(font-size, rem(12px), $pm: rem(13px), $ts: rem(14px));
  }

  .btn {
    display: inline-flex;
    flex-wrap: nowrap;
    align-items: center;
    padding: 0 0.325rem;
    // font-weight: 500;
    @include fgcolor(tert);
    height: 100%;
    background: none;
    @include fgcolor(tert);

    // position: relative;
    // padding: 0;
    // padding-bottom: 0.125rem;
    :global(svg) {
      @include ftsize(lg);
    }

    img {
      width: 0.875rem;
      opacity: 0.7;
    }

    &._same,
    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .sep {
    padding-right: 0.375rem;
  }

  .util-more {
    position: absolute;
    z-index: 9999;
    top: 100%;
    margin-top: -3px;
    padding: 0.375rem 0.5rem;
    line-height: 1.375rem;

    left: 0;
    right: 0;

    @include fgcolor(tert);
    @include bgcolor(secd);
    @include ftsize(sm);
    @include border;
    @include bdradi($loc: bottom);

    :global(svg) {
      @include fgcolor(tert);
      display: inline-block;
      font-size: 0.9em;
      margin-top: -0.125em;
    }

    img {
      display: inline-block;
      opacity: 0.8;
      width: 0.9em;
      height: auto;
      margin-top: -0.1rem;
    }
  }

  .txt {
    cursor: pointer;

    &:hover,
    &._same {
      @include fgcolor(primary);
    }

    & + & {
      margin-left: 0.25rem;
    }
  }
</style>
