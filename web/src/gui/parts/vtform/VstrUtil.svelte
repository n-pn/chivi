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
</script>

<script lang="ts">
  import { tooltip } from '$lib/actions'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import { gtran, btran, deepl } from '$utils/qtran_utils'

  import type { Vtform } from '$lib/models/viterm'

  export let tform: Vtform
  export let field: HTMLInputElement

  async function run_gtran(tab = 0) {
    field.focus()
    tform.vstr = await gtran(tform.init.zstr, tab)
  }

  async function run_btran(tab = 0) {
    field.focus()
    tform.vstr = await btran(tform.init.zstr, tab, true)
  }

  async function run_deepl(tab = 0) {
    field.focus()
    tform.vstr = await deepl(tform.init.zstr, tab, false)
  }

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

  const gen_format_hints = (input: string) => {
    const output = []

    output.push(input.toLowerCase())
    output.push(titleize(input, 999))

    let length = input.split(' ').length
    if (length > 3) length = 3

    for (let i = 1; i < length; i++) {
      output.push(titleize(input, i))
    }

    for (let i = 1; i < length; i++) {
      output.push(detitleize(input, i))
    }

    return [...new Set(output)]
  }

  const apply_vstr = (vstr: string) => {
    tform.vstr = vstr
    show_more = false
  }
</script>

<div class="util">
  <div class="util-main">
    <button
      type="button"
      class="btn"
      class:_active={more_type == 'hviet'}
      data-kbd="h"
      on:click={() => trigger_more('hviet')}
      use:tooltip={'Khởi tạo nghĩa bằng Hán Việt'}
      data-anchor=".vtform">
      <span>H. Việt</span>
      <SIcon name="caret-down" />
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="v"
      class:_active={more_type == 'prevs'}
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
      class:_active={more_type == 'trans'}
      on:click={() => trigger_more('trans')}
      use:tooltip={'Thêm các lựa chọn dịch ngoài'}
      data-anchor=".vtform">
      <span>D. ngoài</span>
      <SIcon name="caret-down" />
    </button>

    <button
      type="button"
      class="btn"
      data-kbd="f"
      class:_active={more_type == 'cases'}
      on:click={() => trigger_more('cases')}
      use:tooltip={'Thêm các lựa chọn viết hoa/thường'}
      data-anchor=".vtform">
      <span>V. hoa</span>
      <SIcon name="caret-down" />
    </button>

    <div class="right">
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
    </div>
  </div>

  {#if show_more}
    <div class="util-more">
      {#if more_type == 'hviet'}
        {#each gen_format_hints(tform.init.hviet) as vstr}
          <!-- svelte-ignore a11y-click-events-have-key-events -->
          <!-- svelte-ignore a11y-no-static-element-interactions -->
          <span
            class="txt"
            class:_active={tform.vstr == vstr}
            on:click={() => apply_vstr(vstr)}>
            <span>{vstr}</span>
          </span>
        {/each}
      {:else if more_type == 'cases'}
        {#each gen_format_hints(tform.vstr) as vstr}
          <!-- svelte-ignore a11y-click-events-have-key-events -->
          <!-- svelte-ignore a11y-no-static-element-interactions -->
          <span
            class="txt"
            class:_active={tform.vstr == vstr}
            on:click={() => apply_vstr(vstr)}>
            <span>{vstr}</span>
          </span>
        {/each}
      {:else if more_type == 'trans'}
        <SIcon name="brand-google" />
        {#await gtran(tform.init.zstr, 0)}
          <SIcon name="loader-2" spin={true} />
        {:then vstr}
          <!-- svelte-ignore a11y-click-events-have-key-events -->
          <!-- svelte-ignore a11y-no-static-element-interactions -->
          <span
            class="txt"
            class:_active={tform.vstr == vstr}
            on:click={() => apply_vstr(vstr)}>
            <span>{vstr}</span>
          </span>
        {/await}

        <SIcon name="brand-bing" />

        {#await btran(tform.init.zstr, 0)}
          <SIcon name="loader-2" spin={true} />
        {:then vstr}
          <!-- svelte-ignore a11y-click-events-have-key-events -->
          <!-- svelte-ignore a11y-no-static-element-interactions -->
          <span
            class="txt"
            class:_active={tform.vstr == vstr}
            on:click={() => apply_vstr(vstr)}>
            <span>{vstr}</span>
          </span>
        {/await}

        <img class="sep" src="/icons/deepl.svg" alt="deepl" />

        {#await deepl(tform.init.zstr, 0)}
          <SIcon name="loader-2" spin={true} />
        {:then vstr}
          <!-- svelte-ignore a11y-click-events-have-key-events -->
          <!-- svelte-ignore a11y-no-static-element-interactions -->
          <span
            class="txt"
            class:_active={tform.vstr == vstr}
            on:click={() => apply_vstr(vstr)}>
            <span>{vstr}</span>
          </span>
        {/await}
      {/if}
    </div>
  {/if}

  <!-- <div class="util-more" class:_active={show_trans}>

    <button
        type="button"
        class="btn"
        on:click={() => run_gtran(1)}
        use:tooltip={'Dịch bằng Google từ Trung sang Anh'}
        data-anchor=".vtform">
        <SIcon name="brand-google" />
        <span class="lang">Anh</span>
      </button>

      <button
        type="button"
        class="btn"
        on:click={() => run_btran(1)}
        use:tooltip={'Dịch bằng Bing từ Trung sang Anh'}
        data-anchor=".vtform">
        <SIcon name="brand-bing" />
        <span class="lang">Anh</span>
      </button>

      <span class="sep" />

      <button
        type="button"
        class="btn"
        on:click={() => run_gtran(2)}
        use:tooltip={'Dịch bằng Google từ Nhật sang Anh'}
        data-anchor=".vtform">
        <SIcon name="brand-google" />
        <span class="lang">Nhật</span>
      </button>
    <button
      type="button"
      class="btn"
      on:click={() => run_gtran(1)}
      use:tooltip={'Dịch bằng Google từ Trung sang Anh'}
      data-anchor=".vtform">
      <SIcon name="brand-google" />
      <span class="lang">Anh</span>
    </button>

    <button
      type="button"
      class="btn"
      on:click={() => run_btran(1)}
      use:tooltip={'Dịch bằng Bing từ Trung sang Anh'}
      data-anchor=".vtform">
      <SIcon name="brand-bing" />
      <span class="lang">Anh</span>
    </button>

    <span class="sep" />

    <button
      type="button"
      class="btn"
      on:click={() => run_gtran(2)}
      use:tooltip={'Dịch bằng Google từ Nhật sang Anh'}
      data-anchor=".vtform">
      <SIcon name="brand-google" />
      <span class="lang">Nhật</span>
    </button>
  </div> -->
</div>

<style lang="scss">
  $height: 2.5rem;

  .util {
    position: relative;
  }

  .util-main {
    @include flex-cy;
    position: relative;
    padding: 0 0.375rem;
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

  .right {
    display: inline-flex;
    margin-left: auto;

    > .btn {
      padding: 0 0.5rem;
    }
  }

  .btn {
    display: inline-flex;
    flex-wrap: nowrap;
    align-items: center;
    padding: 0 0.375rem;
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

    &._active,
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
    margin-top: -4px;
    padding: 0.375rem 0.75rem;
    line-height: 1.25rem;

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
      margin-bottom: 0.2em;
    }

    img {
      display: inline-block;
      // width: rem(12px);
      opacity: 0.6;
      width: 0.9em;
      height: auto;
      margin-right: 0.05rem;
    }
  }

  .txt {
    cursor: pointer;
    // display: inline-block;

    max-width: 40vw;
    background-color: inherit;
    color: inherit;
    // @include clamp($width: null);

    &:hover,
    &._active {
      @include fgcolor(primary);
    }

    & + & {
      margin-left: 0.375rem;
    }
  }
  .sep {
    margin-left: 0.25rem;
  }
</style>
