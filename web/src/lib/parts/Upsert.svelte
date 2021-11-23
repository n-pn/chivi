<!-- @hmr:keep-all -->
<script context="module">
  import { writable } from 'svelte/store'
  import { tag_label } from '$lib/pos_tag.js'
  import { dict_upsert, dict_search } from '$api/dictdb_api.js'

  export const tab = writable(0)
  export const state = writable(0)
  export const ztext = writable('')
  export const lower = writable(0)
  export const upper = writable(1)

  export function activate(data, active_tab = 0, active_state = 1) {
    if (typeof data == 'string') {
      ztext.set(data)
      lower.set(0)
      upper.set(data.length)
    } else {
      ztext.set(data[0])
      lower.set(data[1])
      upper.set(data[2])
    }

    tab.set(active_tab)
    state.set(active_state)
  }

  export function deactivate(_evt) {
    state.set(0)
  }
</script>

<script>
  import { session } from '$app/stores'
  import { enrich_term, hint } from './Upsert/_shared.js'

  import SIcon from '$atoms/SIcon.svelte'
  import CMenu from '$molds/CMenu.svelte'
  import Gmodal from '$molds/Gmodal.svelte'

  import Input from './Upsert/Input.svelte'
  import Emend from './Upsert/Emend.svelte'
  import Vhint from './Upsert/Vhint.svelte'
  import Vutil from './Upsert/Vutil.svelte'
  import Vrank from './Upsert/Vrank.svelte'
  import Links from './Upsert/Links.svelte'

  import Postag from '$parts/Postag.svelte'
  import { state as tlspec_state } from '$parts/Tlspec.svelte'

  export let dname = 'combine'
  export let d_dub = 'Tổng hợp'
  export let on_change = () => {}

  let key = ''
  $: if (key) change_key($ztext, $lower, $upper)

  let pinyins = {}
  let valhint = {}
  let vpterms = {}

  $: vpterm = (vpterms[key] || [])[$tab] || enrich_term({})

  $: [lbl_state, btn_state] = vpterm.get_state(vpterm._priv)

  let focus
  $: vpterm, focus && focus.focus()

  async function change_key(ztext, lower, upper) {
    await fetch_data(ztext, lower, upper)
    vpterms = vpterms
  }

  async function fetch_data(ztext, lower, upper) {
    const words = [ztext.substring(lower, upper)]

    if (lower > 0) words.push(ztext.substring(lower - 1, upper))
    if (lower + 1 < upper) words.push(ztext.substring(lower + 1, upper))

    if (upper - 1 > lower) words.push(ztext.substring(lower, upper - 1))
    if (upper + 1 < ztext.length) words.push(ztext.substring(lower, upper + 1))
    if (upper + 2 < ztext.length) words.push(ztext.substring(lower, upper + 2))
    if (upper + 3 < ztext.length) words.push(ztext.substring(lower, upper + 3))

    if (lower > 1) words.push(ztext.substring(lower - 2, upper))

    const to_fetch = words.filter((x) => x && !vpterms[x])
    if (to_fetch.length == 0) return

    const [err, res] = await dict_search(fetch, to_fetch, dname)
    if (err) return console.log({ err, res })

    for (const inp in res) {
      const data = res[inp]
      pinyins[inp] = data.binh_am
      valhint[inp] = data.val_hint
      vpterms[inp] = [
        enrich_term(data.special),
        enrich_term(data.regular),
        enrich_term(data.hanviet),
      ]
    }
  }

  async function submit_val() {
    const val = vpterm.val.replace('', '').trim()
    const attr = vpterm.ptag
    const params = { key, val, attr, rank: vpterm.rank, _priv: vpterm._priv }

    const dnames = [dname, 'regular', 'hanviet']
    const [status] = await dict_upsert(fetch, dnames[$tab], params)

    if (!status) on_change()
    deactivate()
  }

  function is_edited(key, tab) {
    const terms = vpterms[key]
    return terms ? terms[tab].state > 0 : false
  }
</script>

<Gmodal active={$state > 0} on_close={deactivate}>
  <upsert-wrap>
    <upsert-head class="head">
      <CMenu dir="left" loc="bottom">
        <button class="m-btn _text" slot="trigger">
          <SIcon name="menu-2" />
        </button>
        <svelte:fragment slot="content">
          <a class="-item" href="/dicts/{dname}" target="_blank">
            <SIcon name="package" />
            <span>Từ điển</span>
          </a>

          <button class="-item" on:click={() => ($tlspec_state = 1)}>
            <SIcon name="flag" />
            <span>Báo lỗi</span>
          </button>
        </svelte:fragment>
      </CMenu>

      <Input
        ztext={$ztext}
        bind:lower={$lower}
        bind:upper={$upper}
        pinyin={pinyins[key] || ''}
        bind:output={key} />

      <button
        type="button"
        class="m-btn _text"
        data-kbd="esc"
        on:click={deactivate}>
        <SIcon name="x" />
      </button>
    </upsert-head>

    <upsert-tabs>
      <button
        class="tab-item _book"
        class:_active={$tab == 0}
        class:_edited={is_edited(key, 0)}
        data-kbd="x"
        on:click={() => tab.set(0)}
        use:hint={`Từ điển riêng cho từng bộ truyện`}>
        <SIcon name="book" />
        <span>{d_dub}</span>
      </button>

      <button
        class="tab-item"
        class:_active={$tab == 1}
        class:_edited={is_edited(key, 1)}
        data-kbd="c"
        on:click={() => tab.set(1)}
        use:hint={'Từ điển chung cho tất cả các bộ truyện'}>
        <SIcon name="world" />
        <span>Thông dụng</span>
      </button>

      <div class="tab-right">
        <CMenu dir="right">
          <button slot="trigger" class="tab-item" class:_active={$tab > 1}>
            <SIcon name="caret-down" />
          </button>

          <svelte:fragment slot="content">
            <button
              class="-item"
              data-kbd={'c'}
              on:click={() => tab.set(2)}
              use:hint={'Phiên âm Hán Việt cho tên người, sự vật...'}>
              <span>Hán Việt</span>
            </button>
          </svelte:fragment>
        </CMenu>
      </div>
    </upsert-tabs>

    <upsert-body>
      <Emend {vpterm} />

      <div class="field">
        <Vhint {key} tab={$tab} hints={valhint[key] || []} bind:vpterm />

        <div class="value" class:_fresh={vpterm.state == 0}>
          <input
            type="text"
            class="-input"
            bind:this={focus}
            bind:value={vpterm.val}
            autocomplete="off"
            autocapitalize={$tab < 1 ? 'words' : 'off'} />

          {#if $tab < 2}
            <button
              class="postag"
              data-kbd="p"
              on:click={() => state.set(2)}
              use:hint={'Phân loại cụm từ: Danh, động, tính, trạng...'}>
              {tag_label(vpterm.ptag) || 'Phân loại'}
            </button>
          {/if}
        </div>

        <Vutil {key} tap={$tab} bind:vpterm />
      </div>

      <div class="vfoot">
        <Vrank {vpterm} bind:rank={vpterm.rank} />

        <div class="bgroup">
          <button
            class="m-btn _lg _fill _left {btn_state}"
            data-kbd="'"
            use:hint={vpterm._priv
              ? 'Đổi sang từ điển chung'
              : 'Đổi sang từ điển cá nhân'}
            on:click={() => (vpterm = vpterm.swap_dict())}>
            <SIcon name={vpterm._priv ? 'user' : 'users'} />
          </button>

          <button
            class="m-btn _lg _fill _right {btn_state}"
            data-kbd="↵"
            disabled={vpterm.disabled($session.privi)}
            on:click={submit_val}
            use:hint={vpterm._priv
              ? 'Lưu nghĩa vào từ điển cá nhân (áp dụng cho riêng bạn)'
              : 'Lưu nghĩa vào từ điển chung (áp dụng cho mọi người)'}>
            <span class="submit-text">{lbl_state}</span>
          </button>
        </div>
      </div>
    </upsert-body>

    <Links {key} />
  </upsert-wrap>
</Gmodal>

{#if $state == 2}
  <Postag bind:ptag={vpterm.ptag} bind:state={$state} />
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

  .field {
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

    @include ftsize(sm);

    @include fgcolor(tert);
    @include linesd(--bd-main);

    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .vfoot {
    display: flex;
    padding: 0.75rem 0;
    justify-content: right;
  }

  .bgroup {
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
