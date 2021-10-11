<!-- @hmr:keep-all -->
<script context="module">
  import { writable } from 'svelte/store'
  import { tag_label } from '$lib/pos_tag.js'
  import { dict_upsert, dict_search } from '$api/dictdb_api.js'

  export const tab = writable(0)
  export const state = writable(0)
  export const input = writable([])
  export const lower = writable(0)
  export const upper = writable(1)

  export function activate(data, active_tab = 0, active_state = 1) {
    if (typeof data == 'string') {
      input.set(data)
      lower.set(0)
      upper.set(data.length)
    } else {
      input.set(data[0])
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
  import { scale, fade } from 'svelte/transition'
  import { backInOut } from 'svelte/easing'
  import { VpTerm, hint } from './Upsert/_shared.js'

  import SIcon from '$atoms/SIcon.svelte'
  import CMenu from '$molds/CMenu.svelte'

  import Postag from '$parts/Postag.svelte'
  import Input from './Upsert/Input.svelte'
  import Emend from './Upsert/Emend.svelte'
  import Vhint from './Upsert/Vhint.svelte'
  import Vutil from './Upsert/Vutil.svelte'
  import Vrank from './Upsert/Vrank.svelte'
  import Links from './Upsert/Links.svelte'
  import { detach_before_dev } from 'svelte/internal'

  export let dname = 'combine'
  export let label = 'Tổng hợp'
  export let _dirty = false

  let cached = {}

  let binh_am = ''
  let hints = []
  let terms = []

  let term = new VpTerm({ val: '', ptag: '', rank: 3 })

  let key = ''
  $: if (key) init_search(key, $input, $lower, $upper)

  let value_field
  $: if (term) focus_on_value()

  function focus_on_value() {
    value_field && value_field.focus()
  }

  async function init_search(key, input, lower, upper) {
    if (cached[key]) update_term(cached[key])

    const words = gen_words(input, lower, upper)
    if (words.length == 0) return // skip fetching if all words fetched

    const [err, res] = await dict_search(fetch, words, dname)
    if (err) return console.log({ err, res })

    if (res[key]) update_term(res[key])
    for (const k in res) cached[k] = res[k]
  }

  function gen_words(hanzi, lower, upper) {
    const res = [hanzi.substring(lower, upper)]

    if (lower > 0) res.push(hanzi.substring(lower - 1, upper))
    if (lower + 1 < upper) res.push(hanzi.substring(lower + 1, upper))

    if (upper - 1 > lower) res.push(hanzi.substring(lower, upper - 1))
    if (upper + 1 < hanzi.length) res.push(hanzi.substring(lower, upper + 1))
    if (upper + 2 < hanzi.length) res.push(hanzi.substring(lower, upper + 2))
    if (upper + 3 < hanzi.length) res.push(hanzi.substring(lower, upper + 3))

    if (lower > 1) res.push(hanzi.substring(lower - 2, upper))

    return res.filter((x) => x && !cached[x])
  }

  function update_term(data) {
    binh_am = data.binh_am
    hints = data.val_hint

    terms = [
      new VpTerm(data.u_priv, data.u_base),
      new VpTerm(data.c_priv, data.c_base),
      new VpTerm(data.hanviet, data.hanviet),
    ]

    term = terms[$tab]
  }

  function change_tab(new_tab) {
    $tab = new_tab
    term = terms[$tab]
  }

  async function submit_val(stype = '_base') {
    const params = {
      key,
      val: term.val.replace('', '').trim(),
      attr: term.ptag,
      rank: term.rank,
      stype,
    }

    const dnames = [dname, 'regular', 'hanviet']
    const [status] = await dict_upsert(fetch, dnames[$tab], params)
    _dirty = !status
    deactivate()
  }
</script>

<modal-wrap on:click={deactivate} transition:fade={{ duration: 100 }}>
  <modal-main
    on:click|stopPropagation={focus_on_value}
    transition:scale={{ duration: 100, easing: backInOut }}>
    <modal-head class="head">
      <CMenu dir="left" loc="top">
        <button class="m-btn _text" slot="trigger">
          <SIcon name="menu-2" />
        </button>
        <svelte:fragment slot="content">
          <a class="-item" href="/dicts/{dname}" target="_blank">
            <SIcon name="package" />
            <span>Từ điển</span>
          </a>
        </svelte:fragment>
      </CMenu>

      <Input
        input={$input}
        bind:lower={$lower}
        bind:upper={$upper}
        pinyin={binh_am}
        bind:output={key} />

      <button
        type="button"
        class="m-btn _text"
        data-kbd="esc"
        on:click={deactivate}>
        <SIcon name="x" />
      </button>
    </modal-head>

    <modal-tabs>
      <button
        class="tab-item _book"
        class:_active={$tab == 0}
        class:_edited={!terms[0]?.fresh}
        data-kbd="x"
        on:click={() => change_tab(0)}
        use:hint={`Từ điển riêng cho [${label}]`}>
        <SIcon name="book" />
        <span>{label}</span>
      </button>

      <button
        class="tab-item"
        class:_active={$tab == 1}
        class:_edited={!terms[1]?.fresh}
        data-kbd="c"
        on:click={() => change_tab(1)}
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
              on:click={() => change_tab(2)}
              use:hint={'Phiên âm Hán Việt cho tên người, sự vật...'}>
              <span>Hán Việt</span>
            </button>
          </svelte:fragment>
        </CMenu>
      </div>
    </modal-tabs>

    <modal-body>
      <Emend {term} p_min={$tab + 1} />

      <div class="field">
        {#key key}
          <Vhint {hints} bind:term />

          <div class="value" class:_fresh={term.fresh}>
            <input
              type="text"
              class="-input"
              bind:this={value_field}
              bind:value={term.val}
              autocomplete="off"
              autocapitalize={$tab < 1 ? 'words' : 'off'} />

            {#if $tab < 2}
              <button
                class="postag"
                data-kbd="p"
                on:click={() => state.set(2)}
                use:hint={'Phân loại cụm từ: Danh, động, tính, trạng...'}>
                {tag_label(term.ptag) || 'Phân loại'}
              </button>
            {/if}
          </div>

          <Vutil bind:term />
        {/key}
      </div>

      <div class="vfoot">
        <Vrank {term} bind:rank={term.rank} />

        <div class="bgroup">
          <button
            class="m-btn _lg _fill _left {term.btn_state('_base')}"
            data-kbd="↵"
            disabled={term.disabled('_base', $session.privi, $tab + 1)}
            use:hint={'Lưu nghĩa vào từ điển chung (áp dụng cho mọi người)'}
            on:click={() => submit_val('_base')}>
            <SIcon name="users" />
            <span class="submit-text">{term.state}</span>
          </button>

          <button
            class="m-btn _lg _fill _right {term.btn_state('_priv')}"
            data-kbd="⇧↵"
            disabled={term.disabled('_priv', $session.privi, $tab + 1)}
            use:hint={'Lưu nghĩa vào từ điển cá nhân (áp dụng cho riêng bạn)'}
            on:click={() => submit_val('_priv')}>
            <SIcon name="user" />
          </button>
        </div>
      </div>
    </modal-body>

    <Links {key} />
  </modal-main>
</modal-wrap>

{#if $state > 1}
  <Postag bind:ptag={term.ptag} bind:state={$state} />
{/if}

<style lang="scss">
  $gutter: 0.75rem;

  modal-wrap {
    @include flex($center: both);
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    z-index: 999;
    background: rgba(#000, 0.75);
  }

  modal-main {
    display: block;
    width: rem(30);
    min-width: 320px;
    max-width: 100%;
    @include bgcolor(tert);
    @include bdradi();
    @include shadow(3);

    @include tm-dark {
      @include linesd(--bd-soft, $inset: false);
    }
  }

  modal-head {
    @include flex();

    // @include bdradi($loc: top);
    @include border(--bd-soft, $loc: bottom);
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

  modal-tabs {
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

  modal-body {
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
    padding-right: 0.25rem;
    @include bps(padding-left, 0.25rem, $sm: 0.5rem);
    @include bdradi(0, $loc: right);

    > span {
      width: 2rem;
    }

    > :global(svg) {
      @include bps(display, none, $sm: inline-block);
    }
  }

  .m-btn._right {
    margin-left: -1px;
    @include bdradi(0, $loc: left);
  }
</style>
