<!-- @hmr:keep-all -->
<script context="module">
  import { onDestroy } from 'svelte'
  import { writable } from 'svelte/store'
  import { session } from '$app/stores'

  import { vdict, ztext, zfrom, zupto } from '$lib/stores'
  import { decor_term, hint } from './Upsert/_shared.js'

  export const ctrl = {
    ...writable({ tab: 0, state: 0 }),
    show: (tab = 0, state = 1, from, upto) => {
      if (from) zfrom.set(from)
      if (upto) zupto.set(upto)
      ctrl.set({ tab, state })
    },
    hide: () => ctrl.set_state(0),
    set_tab: (tab) => ctrl.update((x) => ({ ...x, tab })),
    set_state: (state) => ctrl.update((x) => ({ ...x, state })),
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Gmenu from '$molds/Gmenu.svelte'
  import Gmodal from '$molds/Gmodal.svelte'

  import Hanzi from './Upsert/Hanzi.svelte'
  import Emend from './Upsert/Emend.svelte'
  import Vhint from './Upsert/Vhint.svelte'
  import Vutil from './Upsert/Vutil.svelte'
  import Vrank from './Upsert/Vrank.svelte'
  import Links from './Upsert/Links.svelte'

  import Postag, { ptnames } from '$parts/Postag.svelte'
  import { ctrl as tlspec } from '$parts/Tlspec.svelte'

  export let on_change = () => {}
  export let on_destroy = () => {}
  onDestroy(on_destroy)

  let vpterms = []
  let valhint = []
  let key = ''

  $: vpterm = vpterms[$ctrl.tab] || decor_term({})
  $: [lbl_state, btn_state] = vpterm.get_state(vpterm._priv)

  let focus
  $: vpterm, focus && focus.focus()

  async function submit_val() {
    const dname = [$vdict.dname, 'regular', 'hanviet'][$ctrl.tab]
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

  function is_edited(tab) {
    return vpterms[tab]?.state > 0
  }
</script>

<Gmodal actived={$ctrl.state > 0} on_close={ctrl.hide} _klass="upsert">
  <upsert-wrap>
    <upsert-head class="head">
      <Gmenu dir="left" loc="bottom">
        <button class="m-btn _text" slot="trigger">
          <SIcon name="menu-2" />
        </button>
        <svelte:fragment slot="content">
          <a class="-item" href="/dicts/{$vdict.dname}" target="_blank">
            <SIcon name="package" />
            <span>Từ điển</span>
          </a>

          <button class="-item" on:click={tlspec.show}>
            <SIcon name="flag" />
            <span>Báo lỗi</span>
          </button>
        </svelte:fragment>
      </Gmenu>

      <Hanzi bind:vpterms bind:valhint bind:output={key} />

      <button
        type="button"
        class="m-btn _text"
        data-kbd="esc"
        on:click={ctrl.hide}>
        <SIcon name="x" />
      </button>
    </upsert-head>

    <upsert-tabs>
      <button
        class="tab-item _book"
        class:_active={$ctrl.tab == 0}
        class:_edited={is_edited(0)}
        data-kbd="x"
        on:click={() => ctrl.set_tab(0)}
        use:hint={'Từ điển riêng cho từng bộ truyện'}>
        <SIcon name="book" />
        <span>{$vdict.d_dub}</span>
      </button>

      <button
        class="tab-item"
        class:_active={$ctrl.tab == 1}
        class:_edited={is_edited(1)}
        data-kbd="c"
        on:click={() => ctrl.set_tab(1)}
        use:hint={'Từ điển chung cho tất cả các bộ truyện'}>
        <SIcon name="world" />
        <span>Thông dụng</span>
      </button>

      <div class="tab-right">
        <Gmenu dir="right">
          <button slot="trigger" class="tab-item" class:_active={$ctrl.tab > 1}>
            <SIcon name="caret-down" />
          </button>

          <svelte:fragment slot="content">
            <button
              class="-item"
              data-kbd="v"
              on:click={() => ctrl.set_tab(2)}
              use:hint={'Phiên âm Hán Việt cho tên người, sự vật...'}>
              <span>Hán Việt</span>
            </button>
          </svelte:fragment>
        </Gmenu>
      </div>
    </upsert-tabs>

    <upsert-body>
      <Emend privi={$session.privi} {vpterm} />

      <upsert-main>
        <Vhint {key} tab={$ctrl.tab} hints={valhint} bind:vpterm />

        <div class="value" class:_fresh={vpterm.state == 0}>
          <input
            type="text"
            class="-input"
            bind:this={focus}
            bind:value={vpterm.val}
            autocomplete="off"
            autocapitalize={$ctrl.tab < 1 ? 'words' : 'off'} />

          {#if $ctrl.tab < 2}
            <button
              class="postag"
              data-kbd="w"
              on:click={() => ctrl.set_state(2)}>
              {ptnames[vpterm.ptag] || 'Phân loại'}
            </button>
          {/if}
        </div>

        <Vutil {key} tab={$ctrl.tab} bind:vpterm />
      </upsert-main>

      <upsert-foot>
        <Vrank {vpterm} bind:rank={vpterm.rank} />

        <upsert-btns>
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
            disabled={vpterm.disabled($session.privi)}
            on:click={submit_val}
            use:hint={vpterm._priv
              ? 'Lưu nghĩa vào từ điển cá nhân (áp dụng cho riêng bạn)'
              : 'Lưu nghĩa vào từ điển chung (áp dụng cho mọi người)'}>
            <span class="submit-text">{lbl_state}</span>
          </button>
        </upsert-btns>
      </upsert-foot>
    </upsert-body>

    <Links {key} />
  </upsert-wrap>
</Gmodal>

{#if $ctrl.state == 2}
  <Postag bind:ptag={vpterm.ptag} bind:state={$ctrl.state} />
{/if}

<style lang="scss">
  $gutter: 0.75rem;

  upsert-wrap {
    display: block;
    width: $bp-phone-lg;
    min-width: 320px;
    max-width: 100%;

    @include bgcolor(tert);
    @include shadow(3);

    @include bps(border-radius, 0, $pl: 0.25rem);

    @include tm-dark {
      @include linesd(--bd-soft, $inset: false);
    }
  }

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

  $tab-height: 2.25rem;

  upsert-tabs {
    margin-top: 0.5rem;
    height: $tab-height;
    padding: 0 0.75rem;

    @include flex($gap: 0.5rem);
    @include border(--bd-main, $loc: bottom);
    @include ftsize(md);

    // prettier-ignore
  }

  .tab-right {
    margin-left: auto;
  }

  .tab-item {
    cursor: pointer;
    @include flex($center: vert);
    // text-transform: capitalize;
    font-weight: 500;
    padding: 0 0.5rem;
    background-color: transparent;

    height: $tab-height;
    line-height: $tab-height;
    flex-shrink: 0;

    @include bdradi($loc: top);
    @include fgcolor(tert);
    @include border(--bd-main, $loc: top-left-right);

    &._book {
      min-width: 6rem;
      max-width: 50%;
      flex-shrink: 1;
    }

    &._edited {
      @include fgcolor(secd);
    }

    &:hover {
      @include bgcolor(secd);
    }

    &._active {
      @include bgcolor(secd);
      @include fgcolor(primary, 5);
      @include bdcolor(primary, 5);
    }

    > span {
      display: block;
      @include clamp($width: 100%);
    }

    > :global(svg) {
      width: 1.25rem;
      margin-right: 0.125rem;
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

  .postag {
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

  upsert-btns {
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
