<script context="module" lang="ts">
  import cpos_info from '$lib/consts/cpos_info'
  const list = Object.entries(cpos_info)

  const tabs = [
    {
      name: 'Cơ sở',
      list: list.filter(([_, { type }]) => type == 'base'),
    },
    {
      name: 'Từ đơn',
      list: list.filter(([_, { type }]) => type == 'word'),
    },
    {
      name: 'Cụm từ',
      list: list.filter(([_, { type }]) => type == 'phrase'),
    },
  ]

  const in_group = (curr_cpos: string, group: Array<[string, any]>) => {
    for (const [cpos] of group) {
      if (cpos == curr_cpos) return true
    }
    return false
  }
</script>

<script lang="ts">
  import { tooltip } from '$lib/actions'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  export let actived = false
  export let output = ''

  // prettier-ignore
  const on_close = (_?: any) => { actived = false }

  const pick_pos = (npos: string) => {
    output = npos
    on_close()
  }

  const scroll_to = (name: string) => {
    const elem = document.getElementById(`cpos-${name}-group`)
    if (elem) elem.scrollIntoView({ block: 'center', behavior: 'smooth' })
  }
</script>

<Dialog class="cpos-picker" {on_close}>
  <svelte:fragment slot="header">
    <span>Từ loại:</span>
    <span class="tabs">
      {#each tabs as { name, list }, idx}
        <button
          class="htab"
          class:_active={in_group(output, list)}
          data-kbd={idx + 1}
          on:click={() => scroll_to(name)}>
          <span>{name}</span>
        </button>
      {/each}
    </span>
  </svelte:fragment>

  <section class="body">
    {#each tabs as { name, list }}
      <h3 id="cpos-{name}-group">{name}</h3>
      <div class="cpos-list">
        {#each list as [cpos, { name, desc }]}
          {@const active = cpos == output}
          <button
            class="cpos-item"
            class:_active={active}
            data-cpos={cpos}
            use:tooltip={desc}
            data-anchor=".cpos-picker"
            on:click={() => pick_pos(cpos)}>
            <code>{cpos}</code>
            <span>{name}</span>
            {#if active}<SIcon name="check" />{/if}
          </button>
        {/each}
      </div>
    {/each}
  </section>
</Dialog>

<style lang="scss">
  $tab-height: 1.875rem;

  // .head {
  //   @include flex($gap: 0.5rem);
  //   padding-left: 0.25rem;
  //   flex: 1;
  //   height: $tab-height + 0.125rem;
  // }

  .tabs {
    flex: 1;
    padding-top: 0.375rem;
    margin-right: 1rem;
    @include flex-cx($gap: 0.25rem);
  }

  .htab {
    font-weight: 500;
    padding: 0 0.75rem;
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

    &._active {
      @include bgcolor(secd);
      @include fgcolor(primary, 5);
      @include bdcolor(primary, 5);
    }
  }

  h3 {
    font-weight: 500;
    line-height: 2.25rem;
    margin: 0rem 0.75rem;
    font-size: rem(15px);
    @include fgcolor(tert);

    // &.active {
    //   @include fgcolor(primary);
    // }
  }

  .body {
    display: block;
    position: relative;
    // padding-top: 0.25rem;
    padding-bottom: 0.75rem;
    height: 22rem;
    max-height: calc(100vh - 6.5rem);
    @include scroll();
    @include bgcolor(secd);
  }

  .cpos-list {
    @include grid(null, $gap: 0.375rem);
    grid-template-columns: 1fr 1fr 1fr;
    padding: 0 0.75rem;
  }

  .cpos-item {
    padding: 0.25rem 0.5rem;
    background: transparent;
    // font-weight: 500;

    code {
      margin-right: -0.2em;
    }

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

  // .foot {
  //   @include flex-ca;
  //   @include fgcolor(tert);
  //   font-style: italic;
  //   @include ftsize(sm);
  // }
</style>
