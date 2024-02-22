<script lang="ts">
  import { copy_to_clipboard } from '$utils/btn_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let title = ''
  export let wdata = ''
  export let state = wdata ? 2 : 0

  export let loader: (rmode: number) => Promise<string> = undefined

  export let lines = 3
  export let _full = false

  $: if (loader && state == 0) do_reload(1)

  const do_reload = async (rmode = 1) => {
    state = 1
    wdata = await loader(rmode)
    state = wdata ? 2 : 3
  }
</script>

<section class="panel {$$props.class}" style="--lc: {lines}">
  <header>
    <span class="title">{title}</span>
    <span class="tools">
      <slot name="tools" />

      {#if loader}
        <button
          type="button"
          class="-btn"
          data-tip="Dịch lại nội dung"
          data-tip-loc="bottom"
          data-tip-pos="right"
          disabled={state == 1}
          on:click={() => do_reload(2)}>
          <SIcon name="refresh" />
        </button>
      {/if}

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
    {#if state == 1}
      <div class="d-empty-xs">
        <SIcon name="loader-2" spin={true} />
        <em>Đang tải</em>
      </div>
    {:else if wdata}
      <slot>{wdata}</slot>
    {:else}
      <div class="d-empty-xs">
        <slot name="empty">Không có nội dung.</slot>
      </div>
    {/if}
  </div>
</section>

<style lang="scss">
  .panel {
    margin: 0.75rem -0.75rem 0;
    padding-bottom: 0.25rem;
    // border-radius: 4px;
    @include bgcolor(tert);
    // @include border(--bd-soft, $loc: bottom);
  }

  :global(.p-multi) > .panel {
    // @include border(--bd-soft);
    @include bgcolor(secd);

    @include bdradi;
    margin: 1rem 0;
    font-size: rem(17px);
    padding-bottom: 0.5rem;
    > header {
      font-size: rem(15px);
      padding: 0.25rem 0.5rem 0.25rem 1rem;
    }

    > .wbody {
      padding-left: 1rem;
      padding-right: 1rem;
    }
  }

  header {
    @include flex-cy;
    padding: 0 0.5rem 0 0.75rem;
    font-weight: 500;
    line-height: 1.75rem;
    // @include border(--bd-soft, $loc: bottom);
    @include ftsize(sm);
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
    padding: 0 0.75rem 0.25rem;

    text-align: justify;
    text-justify: auto;

    --lh: 1.25em;
    line-height: var(--lh);
    max-height: calc(var(--lh) * var(--lc, 3) + 0.5rem);

    @include bdradi($loc: bottom);

    @include scroll;

    &._lg {
      @include ftsize(lg);
    }

    &._sm {
      @include ftsize(sm);
    }

    &._full {
      max-height: initial;
    }
  }
</style>
