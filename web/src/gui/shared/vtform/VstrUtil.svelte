<script context="module" lang="ts">
  import { titleize, detitleize, uncapitalize } from '$utils/text_utils'

  import { gtran_word } from '$utils/qtran_utils'

  import { deepl_word } from '$utils/qtran_utils/dl_tran'
  import { btran_word } from '$utils/qtran_utils/ms_tran'
  import { baidu_word } from '$utils/qtran_utils/bd_tran'

  const cached_map = new Map<string, string[]>()

  const fetch_trans = async (ztext: string, qkind: string, w_cap = false) => {
    const c_ukey = `${qkind}-${ztext}`

    const cached = cached_map.get(c_ukey)
    if (cached) {
      if (w_cap || qkind == 'prevs') return cached
      return cached.map((x) => uncapitalize(x))
    }

    let trans: string[] = []

    switch (qkind) {
      case 'gtran':
        trans = await gtran_word(ztext, 'vi')
        break
      case 'btran':
        trans = await btran_word(ztext, 'zh')
        break
      case 'baidu':
        trans = await baidu_word(ztext, 'vie')

        break
      case 'deepl':
        trans = [await deepl_word(ztext, 0)]
        break

      case 'prevs':
        const resp = await fetch(`/_sp/utils/defns?zh=${ztext}`)
        const text = await resp.text()
        trans = resp.ok ? text.split('\n') : [resp.status.toString()]
        break
    }

    if (trans.length == 0) return trans

    if (!ztext.endsWith('。')) trans = trans.map((x) => x.replace(/\.$/, ''))
    cached_map.set(c_ukey, trans)

    if (w_cap || qkind == 'prevs') return trans
    return trans.map((x) => uncapitalize(x))
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

  const gen_format_hints = (input: string, is_hv = false) => {
    const output = []

    if (is_hv) {
      output.push(input.toLowerCase())
      output.push(titleize(input, 999))
    } else if (input.match(/^[a-z0-9]+$/i)) {
      output.push(input.toUpperCase())
    }

    let length = input.split(' ').length
    if (length > 3) length = 3

    for (let i = 1; i <= length; i++) {
      output.push(titleize(input, i))
    }

    for (let i = 1; i <= length; i++) {
      output.push(detitleize(input, i))
    }

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

  const tran_types = [
    ['prevs', 'img', 'chivi'],
    ['baidu', 'brand-baidu', 'extra'],
    ['gtran', 'brand-google'],
    ['btran', 'brand-bing'],
    ['deepl', 'img', 'deepl'],
  ]
</script>

<div class="util">
  <div class="util-main">
    <button
      type="button"
      class="btn"
      class:_same={more_type == 'hviet'}
      data-kbd="h"
      on:click={() => trigger_more('hviet')}
      use:tooltip={'Khởi tạo nghĩa bằng Hán Việt'}
      data-anchor=".vtform">
      <span>Hán Việt</span>
      <SIcon name="caret-down" />
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="t"
      class:_same={more_type == 'trans'}
      on:click={() => trigger_more('trans')}
      use:tooltip={'Dịch cụm từ bằng các công cụ dịch'}
      data-anchor=".vtform">
      <span>Gợi ý sẵn</span>
      <SIcon name="caret-down" />
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="y"
      class:_same={more_type == 'names'}
      disabled={tform.cpos[0] != 'N'}
      on:click={() => trigger_more('names')}
      use:tooltip={'Dịch tên riêng, viết hoa chữ đầu'}
      data-anchor=".vtform">
      <span>Tên riêng</span>
      <SIcon name="caret-down" />
    </button>

    {#each [1, 2, 3, 4] as value}
      <button
        type="button"
        data-kbd={value}
        on:click={() => (tform.vstr = titleize(tform.vstr, value))}
        hidden>
      </button>
    {/each}

    <button
      type="button"
      class="btn _right"
      data-kbd="0"
      class:_same={tform.vstr == all_lower}
      on:click={() => (tform.vstr = all_lower)}
      use:tooltip={'Viết thường tất cả'}
      data-anchor=".vtform">
      <SIcon name="letter-case-lower" />
    </button>

    <button
      type="button"
      class="btn"
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
      class:_same={more_type == 'cases'}
      on:click={() => trigger_more('cases')}
      use:tooltip={'Chuyển nhanh viết hoa viết thường'}
      data-anchor=".vtform">
      <SIcon name="letter-case-toggle" />
      <SIcon name="caret-down" />
    </button>
  </div>

  {#if show_more}
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div class="util-more" on:click={handle_click}>
      {#if more_type == 'hviet'}
        {#each gen_format_hints(tform.hviet, true) as vstr}
          <span class="txt" class:_same={tform.vstr == vstr} data-vstr={vstr}>
            {vstr}
          </span>
        {/each}
      {:else if more_type == 'cases'}
        {#each gen_format_hints(tform.vstr, false) as vstr}
          <span class="txt" class:_same={tform.vstr == vstr} data-vstr={vstr}>
            {vstr}
          </span>
        {/each}
      {:else}
        {#each tran_types as [qkind, itype, iname]}
          {#if itype == 'img'}
            <img src="/icons/{iname}.svg" alt={iname} />
          {:else}
            <SIcon name={itype} iset={iname || 'tabler'} />
          {/if}
          {#await fetch_trans(tform.ztext, qkind, more_type == 'names')}
            <SIcon name="loader-2" spin={true} />
          {:then list}
            {#each list as tran}
              <span class="txt" class:_same={tform.vstr == tran} data-vstr={tran}>{tran}</span>
            {/each}
          {/await}
        {/each}
      {/if}
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

    @include bps(font-size, rem(12px), $pm: rem(13px), $ts: rem(14px));
  }

  // .left {
  //   display: inline-flex;
  //   align-items: center;
  //   flex-shrink: 1;
  //
  //   min-width: 280px;
  // }

  ._right {
    margin-left: auto;
  }

  .btn {
    display: inline-flex;
    flex-wrap: nowrap;
    align-items: center;
    padding: 0 0.25rem;
    // font-weight: 500;
    @include fgcolor(tert);
    height: 100%;
    background: none;
    @include fgcolor(tert);

    // position: relative;
    // padding: 0;
    // padding-bottom: 0.125rem;
    :global(svg) {
      font-size: 1rem;
    }

    &._same,
    &:hover {
      @include fgcolor(primary, 5);
    }

    &[disabled] {
      @include fgcolor(mute);
    }
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
      // width: rem(12px);
      opacity: 0.6;
      width: 0.9em;
      height: auto;
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
