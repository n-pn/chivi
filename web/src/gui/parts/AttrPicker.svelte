<script context="module" lang="ts">
  import attr_info from '$lib/consts/attr_info'

  const groups = [
    ['At_h', 'At_t', 'Prfx', 'Sufx'],
    ['Ndes', 'Ntmp', 'Nper', 'Nloc', 'Norg', 'Pn_d', 'Pn_i'],
    ['Hide', 'Asis', 'Capn', 'Capx', 'Undb', 'Undn'],
    ['Vint', 'Vdit', 'Vmod', 'Vpsy'],
  ]
</script>

<script lang="ts">
  import { tooltip } from '$lib/actions'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  export let actived = false
  export let output = ''

  // prettier-ignore
  const on_close = (_?: any) => { actived = false }

  const toggle_attr = (attr: string, hide_after = true) => {
    if (output.includes(attr)) output = output.replace(attr, '').trim()
    else output = (output + ' ' + attr).trim()

    if (hide_after) actived = false
  }

  $: attrs = output.trim().split(' ').filter(Boolean)
</script>

<Dialog --z-idx={80} class="attr-picker" {on_close}>
  <svelte:fragment slot="header">
    <span>Từ tính</span>
  </svelte:fragment>

  <section class="body">
    {#each groups as list}
      <div class="list">
        {#each list as attr}
          {@const active = attrs.includes(attr)}
          {@const { desc, used } = attr_info[attr] || {}}

          <button
            class="attr"
            class:_active={active}
            class:_unused={!used}
            on:click={() => toggle_attr(attr, true)}
            on:contextmenu|preventDefault={() => toggle_attr(attr, false)}
            use:tooltip={desc}
            data-anchor=".attr-picker">
            <SIcon name={active ? 'check' : 'square'} />
            <code>{attr}</code>
            <span>{desc}</span>
          </button>
        {/each}
      </div>
    {/each}
  </section>

  <footer class="foot">
    <p><code>∗</code>: Những từ tính chưa có tác dụng!</p>
  </footer>
</Dialog>

<style lang="scss">
  $tab-height: 1.875rem;

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

  .list {
    // @include grid(null, $gap: 0.375rem);
    // grid-template-columns: 1fr 1fr 1fr 1fr;
    margin-top: 0.375rem;
    padding: 0 0.75rem;

    & + & {
      padding-top: 0.375rem;
      @include border($loc: top);
    }
  }

  .attr {
    padding: 0;
    background: transparent;

    line-height: 1.875rem;
    text-align: left;

    border: none;
    @include fgcolor(tert);
    @include bps(font-size, rem(13px), $pl: rem(14px));
    @include clamp($width: 100%);

    &:hover,
    &._active {
      @include fgcolor(primary, 7);

      @include tm-dark {
        @include fgcolor(primary, 3);
      }
    }

    &._unused {
      @include fgcolor(mute);
      font-style: italic;
      &:after {
        // font-size: rem(10px);
        content: '∗';
      }
    }
  }

  .foot {
    @include flex-ca;
    @include fgcolor(tert);
    font-style: italic;
    @include ftsize(sm);
  }
</style>
