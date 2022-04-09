<!-- @hmr:keep-all -->
<script context="module" lang="ts">
  import { onDestroy } from 'svelte'
  import { writable } from 'svelte/store'

  import { vdict, zfrom, zupto } from '$lib/stores'

  export const ctrl = {
    ...writable({ tab: 0, state: 0 }),
    show: (tab = 0, state = 1, from?: number, upto?: number) => {
      if (from) zfrom.set(from)
      if (upto) zupto.set(upto)
      ctrl.set({ tab, state })
    },
    hide: () => ctrl.set_state(0),
    set_tab: (tab: number) => ctrl.update((x) => ({ ...x, tab })),
    set_state: (state: number) => ctrl.update((x) => ({ ...x, state })),
  }
  const tabs = [
    { kbd: 'x', icon: 'book', class: 'novel' },
    { kbd: 'c', icon: 'world', class: 'basic' },
    { kbd: 'v', icon: 'package', class: 'miscs' },
  ]
</script>

<script lang="ts">
  import { upsert_dicts } from '$utils/vpdict_utils'
  import { hint } from './Upsert/_shared'
  import { VpTerm } from '$lib/vp_term'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  import Hanzi from './Upsert/Hanzi.svelte'
  import Vdict from './Upsert/Vdict.svelte'
  import Emend from './Upsert/Emend.svelte'
  import Vhint from './Upsert/Vhint.svelte'
  import Vutil from './Upsert/Vutil.svelte'
  import Vrank from './Upsert/Vrank.svelte'
  import Links from './Upsert/Links.svelte'

  import Postag, { ptnames } from '$gui/parts/Postag.svelte'
  import { ctrl as tlspec } from '$gui/parts/Tlspec.svelte'
  import { make_vdict } from '$utils/vpdict_utils'

  export let on_change = () => {}
  export let on_destroy = () => {}
  onDestroy(on_destroy)

  let key = ''

  let extra = make_vdict('hanviet')
  $: vpdicts = upsert_dicts($vdict, extra)

  let vpterms: VpTerm[] = []
  $: vpterm = vpterms[$ctrl.tab] || new VpTerm()

  let dname = $vdict.dname
  $: if (extra) dname = vpdicts[$ctrl.tab].dname

  $: [lbl_state, btn_state] = vpterm.get_state(vpterm._priv)

  let focus: HTMLElement | null = null
  $: vpterm, focus && focus.focus()

  async function submit_val() {
    const { dname } = vpdicts[$ctrl.tab]
    const { val, rank, ptag: attr, _priv } = vpterm

    const res = await fetch('/api/terms/entry', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ key, val, rank, attr, _priv, dname }),
    })

    if (res.ok) {
      on_change()
      ctrl.hide()
    } else {
      const { error } = await res.json()
      alert(error)
    }
  }

  function swap_dict(entry?: CV.VpDict) {
    $ctrl = { tab: 2, state: 1 }
    if (entry) extra = entry
  }
</script>

<Dialog
  actived={$ctrl.state > 0}
  on_close={ctrl.hide}
  class="upsert"
  _size="lg">
  <upsert-head class="head">
    <Gmenu dir="left" loc="bottom">
      <button class="m-btn _text" slot="trigger">
        <SIcon name="menu-2" />
      </button>
      <svelte:fragment slot="content">
        <a class="gmenu-item" href="/dicts/{$vdict.dname}" target="_blank">
          <SIcon name="package" />
          <span>Từ điển</span>
        </a>

        <button class="gmenu-item" on:click={tlspec.show}>
          <SIcon name="flag" />
          <span>Báo lỗi</span>
        </button>
      </svelte:fragment>
    </Gmenu>

    <Hanzi {vpdicts} bind:vpterms bind:output={key} active={$ctrl.state > 0} />

    <button
      type="button"
      class="m-btn _text"
      data-kbd="esc"
      on:click={ctrl.hide}>
      <SIcon name="x" />
    </button>
  </upsert-head>

  <upsert-tabs>
    {#each vpdicts as { d_dub, descs }, tab}
      {@const infos = tabs[tab]}

      <button
        class="tab-item _{infos.class}"
        class:_active={$ctrl.tab == tab}
        class:_edited={vpterms[tab]?.state > 0}
        data-kbd={infos.kbd}
        on:click={() => ctrl.set_tab(tab)}
        use:hint={descs}>
        <SIcon name={infos.icon} />
        <span>{d_dub}</span>
      </button>
    {/each}

    <button
      class="tab-btn"
      on:click={() => ($ctrl.state = 3)}
      use:hint={'Chọn từ điển nâng cao'}>
      <SIcon name="package" />
    </button>
  </upsert-tabs>

  <upsert-body>
    <Emend {vpterm} />

    <upsert-main>
      <Vhint {dname} bind:vpterm />

      <div class="value" class:_fresh={vpterm.state == 0}>
        <input
          type="text"
          class="-input"
          bind:this={focus}
          bind:value={vpterm.val}
          autocomplete="off"
          autocapitalize={$ctrl.tab < 1 ? 'words' : 'off'} />

        {#if dname != 'hanviet'}
          <button class="ptag" data-kbd="w" on:click={() => ctrl.set_state(2)}>
            {ptnames[vpterm.ptag] || 'Phân loại'}
          </button>
        {/if}
      </div>

      <Vutil {key} tab={$ctrl.tab} bind:vpterm />
    </upsert-main>

    <upsert-foot>
      <Vrank {vpterm} bind:rank={vpterm.rank} />

      <btn-group>
        <button
          class="m-btn _lg _left {btn_state}"
          data-kbd="\"
          data-key="220"
          use:hint={vpterm._priv
            ? 'Đổi sang từ điển chung'
            : 'Đổi sang từ điển cá nhân'}
          on:click={() => (vpterm = vpterm.swap_dict())}>
          <SIcon name={vpterm._priv ? 'user' : 'share'} />
        </button>

        <button
          class="m-btn _lg _right {btn_state}"
          data-kbd="↵"
          disabled={!vpterm.changed}
          on:click={submit_val}
          use:hint={vpterm._priv
            ? 'Lưu nghĩa vào từ điển cá nhân (áp dụng cho riêng bạn)'
            : 'Lưu nghĩa vào từ điển chung (áp dụng cho mọi người)'}>
          <span class="submit-text">{lbl_state}</span>
        </button>
      </btn-group>
    </upsert-foot>
  </upsert-body>

  <Links {key} />
</Dialog>

<Vdict vdict={extra} bind:state={$ctrl.state} on_close={swap_dict} />
<Postag bind:ptag={vpterm.ptag} bind:state={$ctrl.state} />

<style lang="scss">
  $gutter: 0.75rem;

  upsert-head {
    @include flex();

    // @include bdradi($loc: top);
    @include border(--bd-main, $loc: bottom);
    // @include linesd(--bd-soft);

    .m-btn {
      @include fgcolor(neutral, 5);
      background: none;
      --linesd: none;

      &:hover {
        @include fgcolor(primary, 5);
      }
    }
  }

  $tab-height: 2rem;

  upsert-tabs {
    margin-top: 0.5rem;
    height: $tab-height;
    padding: 0 0.75rem;

    @include flex;
    @include border(--bd-main, $loc: bottom);
    font-size: rem(14px);

    // prettier-ignore
  }

  .tab-item {
    cursor: pointer;
    @include flex($center: vert);
    // text-transform: capitalize;
    margin-right: 0.25rem;
    padding: 0 0.375rem;
    flex-shrink: 0;
    height: $tab-height;
    line-height: $tab-height;
    font-weight: 500;
    background-color: transparent;

    @include bdradi($loc: top);
    @include fgcolor(tert);
    @include border(--bd-main, $loc: top-left-right);

    &._novel {
      min-width: 6rem;
      max-width: 40%;
    }

    &._basic {
      max-width: 30%;
      flex-shrink: 1;
    }

    &._miscs {
      margin-left: auto;
      max-width: 25%;
      flex-shrink: 1;
    }

    &._edited {
      @include fgcolor(secd);
    }

    &:hover {
      @include bgcolor(secd);
    }

    &._active {
      flex-shrink: 0;
      @include bgcolor(secd);
      @include fgcolor(primary, 5);
      @include bdcolor(primary, 5);
    }

    > span {
      display: block;
      @include clamp($width: 100%, $style: '-');
    }

    > :global(svg) {
      width: 1.25rem;
      margin-right: 0.125rem;
      @include bps(display, none, $pl: inline-block);
    }
  }

  .tab-btn {
    padding: 0 0.5rem;
    background-color: transparent;

    height: $tab-height;
    line-height: $tab-height;
    @include fgcolor(tert);
    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  upsert-body {
    display: block;
    padding: 0 0.75rem;
    @include bgcolor(bg-secd);
  }

  upsert-main {
    display: block;
    position: relative;
    @include bdradi;

    @include linesd(--bd-main, $inset: false);
    @include bgcolor(main);

    &:focus-within {
      // @include linesd(primary, 4, $ndef: false);
      @include bgcolor(secd);
    }
  }

  .value {
    display: flex;
    $h-outer: 3.25rem;
    $h-inner: 1.75rem;

    height: $h-outer;
    padding: math.div($h-outer - $h-inner, 2);

    @include linesd(--bd-main, $inset: false);

    &:focus-within {
      @include linesd(primary, 4, $ndef: false);
    }

    > * {
      height: $h-inner;
      // line-height: 1.75rem;
    }

    &._fresh > * {
      font-style: italic;
    }

    > .-input {
      flex: 1;
      min-width: 1rem;
      outline: 0;
      border: 0;
      background: transparent;
      @include fgcolor(main);
      @include ftsize(lg);
    }
  }

  .ptag {
    white-space: nowrap;
    padding: 0 0.5rem;
    margin-left: 0.5rem;
    background: transparent;
    border-radius: 0.75rem;
    font-weight: 500;

    @include fgcolor(tert);
    @include linesd(--bd-main);
    @include bps(font-size, rem(12px), rem(13px), rem(14px));

    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  upsert-foot {
    display: flex;
    padding: 0.75rem 0;
    justify-content: right;
  }

  btn-group {
    @include flex();
  }

  .m-btn._left {
    @include bdradi(0, $loc: right);
  }

  .m-btn._right {
    margin-left: -1px;
    @include bdradi(0, $loc: left);
    @include bps(padding-left, 0.25rem, $pl: 0.5rem);
    @include bps(padding-right, 0.25rem, $pl: 0.5rem);
    // prettier-ignore
    > span { width: 2rem; }
  }
</style>
