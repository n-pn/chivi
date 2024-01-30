<script context="module" lang="ts">
  export function capitalize(str: String) {
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  export function titleize(str: string, count = 9) {
    if (!str) return ''
    if (typeof count == 'boolean') count = count ? 9 : 0

    const res = str.split(' ')
    if (count > res.length) count = res.length

    for (let i = 0; i < count; i++) res[i] = capitalize(res[i])
    for (let i = count; i < res.length; i++) res[i] = res[i].toLowerCase()

    return res.join(' ')
  }

  function detitleize(str: String, count = 9) {
    const res = str.split(' ')
    if (count > res.length) count = res.length
    for (let i = 0; i < count; i++) res[i] = res[i].toLowerCase()
    for (let i = count; i < res.length; i++) res[i] = capitalize(res[i])

    return res.join(' ')
  }

  const v1_cache = new Map<string, string>()
</script>

<script lang="ts">
  import { deepl_word } from '$utils/qtran_utils/dl_tran'
  import { btran_word } from '$utils/qtran_utils/ms_tran'
  import { gtran_word } from '$utils/qtran_utils/gg_tran'
  import { baidu_word } from '$utils/qtran_utils/bd_tran'

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

  $: keep_caps = tform.cpos[0] == 'N'

  $: all_lower = tform.vstr.toLowerCase()
  $: all_title = titleize(tform.vstr, 99)

  const call_mt_v1 = async (ztext: string) => {
    let cached = v1_cache.get(ztext)
    if (cached) return cached

    const url = `/_m1/qtran/suggest?input=${ztext}&w_cap=false`
    const res = await fetch(url)
    if (!res.ok) return res.status
    cached = await res.text()
    v1_cache.set(ztext, cached)
    return cached
  }
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
      data-kbd="v"
      class:_same={more_type == 'prevs'}
      on:click={() => trigger_more('prevs')}
      use:tooltip={'Tải các nghĩa có sẵn từ hệ thống'}
      data-anchor=".vtform"
      disabled>
      <span>Có sẵn</span>
      <SIcon name="caret-down" />
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="t"
      class:_same={more_type == 'trans'}
      on:click={() => trigger_more('trans')}
      use:tooltip={'Chọn nghĩa từ gợi ý của các dịch vụ online'}
      data-anchor=".vtform">
      <span>Dịch ngoài</span>
      <SIcon name="caret-down" />
    </button>

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
      {:else if more_type == 'trans'}
        <img src="/icons/chivi.svg" alt="chivi" />
        {#await call_mt_v1(tform.ztext)}
          <SIcon name="loader-2" spin={true} />
        {:then vstr}
          <span class="txt" class:_same={tform.vstr == vstr} data-vstr={vstr}>
            {vstr}
          </span>
        {/await}

        <SIcon name="brand-google" />
        {#await gtran_word(tform.ztext, 'vi', keep_caps)}
          <SIcon name="loader-2" spin={true} />
        {:then vstr_list}
          {#each vstr_list as vstr}
            <span class="txt" class:_same={tform.vstr == vstr} data-vstr={vstr}>
              {vstr}
            </span>
          {/each}
        {/await}

        <SIcon name="brand-baidu" iset="extra" />
        {#await baidu_word(tform.ztext, 'vie', keep_caps)}
          <SIcon name="loader-2" spin={true} />
        {:then vstr_list}
          {#each vstr_list as vstr}
            <span class="txt" class:_same={tform.vstr == vstr} data-vstr={vstr}>
              {vstr}
            </span>
          {/each}
        {/await}

        <SIcon name="brand-bing" />
        {#await btran_word(tform.ztext, 'zh', keep_caps)}
          <SIcon name="loader-2" spin={true} />
        {:then vstr_list}
          {#each vstr_list as vstr}
            <span class="txt" class:_same={tform.vstr == vstr} data-vstr={vstr}>
              {vstr}
            </span>
          {/each}
        {/await}

        <img src="/icons/deepl.svg" alt="deepl" />
        {#await deepl_word(tform.ztext, 0)}
          <SIcon name="loader-2" spin={true} />
        {:then vstr}
          <span class="txt" class:_same={tform.vstr == vstr} data-vstr={vstr}>
            {vstr}
          </span>
        {/await}
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
