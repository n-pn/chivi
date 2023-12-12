<script lang="ts">
  import { copy_to_clipboard } from '$utils/btn_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let title = ''
  export let wdata = ''

  export let loader: (rmode: number) => Promise<string> = undefined
  export let loaded = !!wdata

  export let lines = 3
  export let _full = false

  $: if (loader && !loaded && !_onload) {
    do_reload(1)
  }

  let _onload = false

  const do_reload = async (rmode = 1) => {
    wdata = ''
    _onload = true

    wdata = await loader(rmode)
    if (wdata) loaded = true

    _onload = false
  }
</script>

<section class="panel {$$props.class}" style="--lc: {lines}">
  <header>
    <span class="title">{title}</span>
    <span class="tools">
      <slot name="tools" />
      <button
        type="button"
        class="-btn"
        data-tip="Sao chép bản dịch vào clipboard"
        data-tip-loc="bottom"
        data-tip-pos="right"
        disabled={!wdata}
        on:click={() => copy_to_clipboard(wdata)}>
        <SIcon name="copy" />
      </button>

      {#if loader}
        <button
          type="button"
          class="-btn"
          data-tip="Dịch lại nội dung"
          data-tip-loc="bottom"
          data-tip-pos="right"
          disabled={_onload}
          on:click={() => do_reload(2)}>
          <SIcon name="refresh" />
        </button>
      {/if}

      <button
        class="-btn"
        on:click={() => (_full = !_full)}
        data-tip="Mở rộng/thu hẹp cửa sổ"
        data-tip-loc="bottom"
        data-tip-pos="right">
        <SIcon name={_full ? 'minimize' : 'maximize'} />
      </button>
    </span>
  </header>

  <div class="wbody" class:_full>
    {#if wdata}
      <slot>{wdata}</slot>
    {:else if _onload || !loaded}
      <div class="d-empty-xs">
        <SIcon name="loader-2" spin={_onload} />
        <em>Đang tải</em>
      </div>
    {:else}
      <div class="d-empty-xs">
        <slot name="empty">Không có nội dung.</slot>
      </div>
    {/if}
  </div>
</section>

<style lang="scss">
  .panel {
    margin: 0.75rem 0;
    @include bdradi;
    @include border(--bd-soft);
    @include bgcolor(tert);

    // &:global(._big) {
    //   margin: 1rem 0;
    // }
  }

  header {
    @include flex-cy;
    padding: 0 0.25rem 0 0.5rem;
    font-weight: 500;
    line-height: 1.5rem;
    // @include border(--bd-soft, $loc: bottom);
    @include ftsize(sm);

    // :global(._big) > & {
    //   padding: 0.25rem 0.5rem 0.25rem 0.75rem;
    // }
  }

  .tools {
    @include flex-cy;
    margin-left: auto;
    gap: 0.125em;

    :global(svg + svg) {
      margin-left: -0.5em;
    }

    > :global(.-btn) {
      background-color: inherit;
      @include fgcolor(tert);
      font-style: italic;
      font-weight: 400;

      &:hover {
        @include fgcolor(primary, 5);
      }
      &:disabled {
        @include fgcolor(mute);
      }
    }

    > :global(.-btn._active) {
      @include fgcolor(primary, 5);
    }
  }

  .wbody {
    padding: 0.25rem 0.5rem;

    text-align: justify;
    text-justify: auto;

    --lh: 1.25em;
    line-height: var(--lh);
    max-height: calc(var(--lh) * var(--lc, 3) + 0.5rem);

    @include bgcolor(secd);
    @include bdradi($loc: bottom);

    @include scroll;

    &._lg {
      @include ftsize(lg);
    }

    &._sm {
      @include ftsize(sm);
    }

    &._ct {
      overflow-x: scroll;
    }

    &._full {
      max-height: initial;
    }
  }

  //   &:global(._zh) {
  //     $line: 1.5rem;
  //     line-height: $line;

  //     &._1 {
  //       max-height: $line * 3 + 0.75rem;
  //     }
  //   }

  //   &._mt {
  //     $line: 1.25rem;
  //     line-height: $line;
  //     max-height: $line * 6 + 0.75rem;
  //     font-size: rem(17px);
  //   }

  //   &._tl {
  //     $line: 1.125rem;
  //     line-height: $line;
  //     max-height: $line * 5 + 0.75rem;
  //     font-size: rem(15px);
  //   }

  //   &._ct {
  //     $line: 1.25rem;
  //     line-height: $line;
  //     overflow-y: visible;

  //     :global(x-n) {
  //       color: var(--active);
  //       font-weight: 450;
  //       border: 0;
  //       &:hover {
  //         border-bottom: 1px solid var(--border);
  //       }
  //     }
  //   }
  // }
</style>
