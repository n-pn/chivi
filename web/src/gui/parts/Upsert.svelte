<!-- @hmr:keep-all -->
<script context="module" lang="ts">
  import { onDestroy } from 'svelte'
  import { writable } from 'svelte/store'

  import { vdict, ztext, zfrom, zupto } from '$lib/stores'

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
  import { session } from '$lib/stores'

  import pt_labels from '$lib/consts/postag_labels.json'

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
  import Vprio from './Upsert/Vprio.svelte'
  import Links from './Upsert/Links.svelte'

  import Postag from '$gui/parts/Postag.svelte'
  import { ctrl as tlspec } from '$gui/parts/Tlspec.svelte'
  import { make_vdict } from '$utils/vpdict_utils'

  export let on_change = () => {}
  export let on_destroy = () => {}
  onDestroy(on_destroy)

  let key = $ztext.substring($zfrom, $zupto)

  let show_opts = $session.privi < 1

  let extra = make_vdict('$hanviet')
  $: vpdicts = upsert_dicts($vdict, extra)

  let vpterms: VpTerm[] = []
  $: [vpterm, show_opts] = init_term(vpterms, $ctrl.tab)

  function init_term(vpterms: VpTerm[], tab: number): [VpTerm, boolean] {
    const term = vpterms[tab] || new VpTerm()
    if ($session.privi > tab) {
      return [term, term._mode > 0 || show_opts]
    } else {
      term._mode = 1
      return [term, true]
    }
  }

  let dname = $vdict.dname
  $: if (extra) dname = vpdicts[$ctrl.tab].dname

  $: [lbl_state, btn_state] = vpterm.state

  async function submit_val() {
    const { dname } = vpdicts[$ctrl.tab]
    const { vals: vals_ary, tags: tags_ary, prio, _mode } = vpterm

    const vals = vals_ary.join('ǀ')
    const tags = tags_ary.join(' ')

    // prettier-ignore
    const body = { key, vals, tags, prio, dname, _mode, _raw: $ztext, _idx: $zfrom }

    const res = await fetch('/_db/terms/entry', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    })

    if (res.ok) {
      on_change()
      ctrl.hide()
    } else {
      const body = await res.json()
      alert(body.message)
    }
  }

  function swap_dict(entry?: CV.VpDict) {
    $ctrl = { tab: 2, state: 1 }
    if (entry) extra = entry
  }

  let inputs: HTMLInputElement[] = []

  $: if (vpterm) refocus()

  const refocus = () => {
    const field = inputs[vpterm._slot]
    if (field) field.focus()
  }

  function copy_key() {
    navigator.clipboard.writeText(key)
  }

  function changed(term: VpTerm) {
    if (term._mode != term.init._mode) return true
    if (term.prio != term.init.prio) return true

    const init_vals = term.init.vals || []
    if (term.vals.length != init_vals.length) return true

    const init_tags = term.init.tags || []
    if (term.tags.length != init_tags.length) return true

    for (let i = 0; i < term.vals.length; i++) {
      if (term.vals[i] != init_vals[i]) return true
    }

    for (let i = 0; i < term.tags.length; i++) {
      if (term.tags[i] != init_tags[i]) return true
    }

    return false
  }

  const save_modes = [
    {
      text: 'Cộng đồng',
      desc: 'Ngay lập tức cập nhật nghĩa dịch cho tất cả mọi người. Ghi đè lên nghĩa "Lưu tạm" nếu có.',
      pmin: 1,
    },
    {
      text: 'Lưu nháp',
      desc: 'Tạm thời chỉ áp dụng nghĩa dịch cho riêng bạn cho tới khi nghĩa được kiểm tra kỹ.',
      pmin: 0,
    },
    {
      text: 'Riêng bạn',
      desc: 'Chỉ áp dụng cho riêng bạn, không bị ảnh hưởng khi người khác cập nhật nghĩa của từ.',
      pmin: 2,
    },
  ]
</script>

<Dialog
  actived={$ctrl.state > 0}
  on_close={ctrl.hide}
  class="upsert"
  _size="lg">
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <upsert-head class="head" on:click={refocus}>
    <Gmenu dir="left" loc="bottom">
      <button class="m-btn _text" slot="trigger">
        <SIcon name="menu-2" />
      </button>
      <svelte:fragment slot="content">
        <a
          class="gmenu-item"
          href="/dicts/{$vdict.dname}"
          target="_blank"
          rel="noreferrer">
          <SIcon name="package" />
          <span>Từ điển</span>
        </a>

        <button class="gmenu-item" on:click={tlspec.show}>
          <SIcon name="flag" />
          <span>Báo lỗi</span>
        </button>

        <button class="gmenu-item" data-kbd="⌃c" on:click={copy_key}>
          <SIcon name="copy" />
          <span>Copy text</span>
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

  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <upsert-tabs on:click={refocus}>
    {#each vpdicts as { d_dub, d_tip }, tab}
      {@const infos = tabs[tab]}

      <button
        class="tab-item _{infos.class}"
        class:_active={$ctrl.tab == tab}
        class:_edited={vpterms[tab]?.init.state != 'Xoá'}
        data-kbd={infos.kbd}
        on:click={() => ctrl.set_tab(tab)}
        use:hint={d_tip}>
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

  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <upsert-body on:click={refocus}>
    <Emend {vpterm} />

    <upsert-main>
      <Vhint {dname} bind:vpterm />

      <div class="value" class:_fresh={vpterm.init.state == 'Xoá'}>
        <input
          type="text"
          class="-input"
          bind:this={inputs[0]}
          bind:value={vpterm.vals[vpterm._slot]}
          autocomplete="off"
          autocapitalize={$ctrl.tab < 1 ? 'words' : 'off'} />

        {#if !dname.startsWith('$')}
          <button class="ptag" data-kbd="w" on:click={() => ctrl.set_state(2)}>
            {pt_labels[vpterm.tags[0]] || 'Phân loại'}
          </button>
        {/if}
      </div>

      <Vutil {key} tab={$ctrl.tab} bind:vpterm />
    </upsert-main>

    {#if show_opts}
      <section class="opts">
        {#each save_modes as { text, desc, pmin }, index}
          {@const privi = $ctrl.tab + pmin}
          <label class="label" class:_active={vpterm._mode == index}
            ><input
              type="radio"
              name="_mode"
              bind:group={vpterm._mode}
              disabled={$session.privi < privi}
              value={index} />
            <span class="-text" use:hint={desc}>{text}</span>
            <span class="-icon" use:hint={'Yêu cần quyền hạn: ' + privi}>
              <SIcon name="privi-{privi}" iset="sprite" />
            </span>
          </label>
        {/each}
      </section>
    {/if}

    <upsert-foot>
      <Vprio {vpterm} bind:prio={vpterm.prio} />

      <btn-group>
        <button
          class="m-btn _lg"
          class:_active={show_opts}
          data-kbd="&bsol;"
          data-key="Backslash"
          use:hint={'Thay đổi chế độ lưu trữ'}
          on:click={() => (show_opts = !show_opts)}>
          <SIcon name="tools" />
        </button>

        <button
          class="m-btn _lg _fill {btn_state}"
          data-kbd="↵"
          disabled={!changed(vpterm)}
          on:click={submit_val}>
          <span class="submit-text">{lbl_state}</span>
        </button>
      </btn-group>
    </upsert-foot>
  </upsert-body>

  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <footer class="foot" on:click={refocus}>
    <Links {key} />
  </footer>
</Dialog>

<Vdict vdict={extra} bind:state={$ctrl.state} on_close={swap_dict} />
<Postag bind:ptag={vpterm.tags[vpterm._slot]} bind:state={$ctrl.state} />

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
    @include bdradi;

    @include linesd(--bd-main, $inset: true);
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

    @include linesd(--bd-main, $inset: true);

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
    gap: 0.5rem;
  }

  .opts {
    display: flex;
    justify-content: right;
    gap: 0.5rem;
    margin-top: 0.5rem;
    margin-bottom: -0.25rem;

    > .label {
      display: inline-flex;
      cursor: pointer;
      align-items: center;
      gap: 0.25rem;

      line-height: 1.25rem;
      font-weight: 500;
      @include ftsize(sm);
      @include fgcolor(tert);
      &._active {
        @include fgcolor(secd);
      }
    }

    .-icon {
      display: inline-flex;
    }
  }

  .foot {
    position: relative;
    @include border(--bd-main, $loc: top);
  }
</style>
