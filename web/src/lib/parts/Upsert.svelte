<!-- @hmr:keep-all -->
<script context="module">
  import { writable } from 'svelte/store'
  import { tag_label } from '$lib/pos_tag.js'
  import { dict_upsert, dict_search } from '$api/dictdb_api.js'

  export const tab = writable(0)
  export const state = writable(0)
  export const input = writable(['', 0, 1])

  export function activate(inp, _tab = 0, _state = 1) {
    tab.set(_tab)

    if (typeof inp == 'string') inp = [inp, 0, inp.length]
    input.set(inp)

    state.set(_state)
  }

  export function deactivate(_evt) {
    state.set(0)
  }
</script>

<script>
  import { session } from '$app/stores'

  import { VpTerm } from './Upsert/_shared.js'

  import SIcon from '$atoms/SIcon.svelte'
  import CMenu from '$molds/CMenu.svelte'

  import Postag from '$parts/Postag.svelte'
  import Input from './Upsert/Input.svelte'
  import Emend from './Upsert/Emend.svelte'
  import Vhint from './Upsert/Vhint.svelte'
  import Vutil from './Upsert/Vutil.svelte'
  import Vrank from './Upsert/Vrank.svelte'
  import Links from './Upsert/Links.svelte'

  export let dname = 'combine'
  export let label = 'Tổng hợp'

  export let _dirty = false

  $: dnames = [dname, 'regular', 'hanviet']

  let binh_am = ''
  let hanviet = ''

  let hints = ['']
  let terms = []

  $: term = terms[$tab] || new VpTerm({ val: '', ptag: '', rank: 3 })

  let key = ''
  $: if (key) init_search(key, dname)

  let value_field
  $: if (term) focus_on_value()

  function focus_on_value() {
    value_field && value_field.focus()
  }

  async function init_search(input, dname) {
    const [err, data] = await dict_search(fetch, input, dname)
    if (err) return
    console.log({ data })

    binh_am = data.binh_am
    hanviet = data.hanviet.val

    hints = [hanviet, ...data.vals.map((x) => x[0])]

    terms = [
      new VpTerm(data.uniq),
      new VpTerm(data.core),
      new VpTerm(data.hanviet),
    ]
  }

  async function submit_val(stype = '_main') {
    const params = {
      key,
      val: term.val.replace('', '').trim(),
      attr: term.ptag,
      rank: term.rank,
      stype,
    }

    const [status] = await dict_upsert(fetch, dnames[$tab], params)
    _dirty = !status
    deactivate()
  }

  $: disabled = $session.privi < $tab + 1 || !term.changed

  let vhint = -1
</script>

<div class="wrap" on:click={deactivate}>
  <div
    id="upsert"
    class="main"
    on:click|stopPropagation={focus_on_value}
    on:mouseenter={() => (vhint = -1)}>
    <header class="head">
      <CMenu dir="left" loc="top">
        <button class="m-button _text" slot="trigger">
          <SIcon name="menu-2" />
        </button>
        <svelte:fragment slot="content">
          <a class="-item" href="/dicts/{dname}" target="_blank">
            <SIcon name="package" />
            <span>Từ điển</span>
          </a>
        </svelte:fragment>
      </CMenu>

      <Input phrase={$input} pinyin={binh_am} bind:output={key} bind:vhint />

      <button
        type="button"
        class="m-button _text"
        data-kbd="esc"
        on:click={deactivate}>
        <SIcon name="x" />
      </button>
    </header>

    <section class="tabs">
      <div
        class="tab-item _book"
        class:_active={$tab == 0}
        class:_edited={!term[0]?._raw.fresh}
        data-kbd="x"
        on:click={() => tab.set(0)}
        on:mouseenter|stopPropagation={() => (vhint = 3)}>
        <SIcon name="book" />
        <span>{label}</span>
      </div>

      <div
        class="tab-item"
        class:_active={$tab == 1}
        class:_edited={!terms[1]?._raw.fresh}
        data-kbd="c"
        on:click={() => tab.set(1)}
        on:mouseenter|stopPropagation={() => (vhint = 4)}>
        <SIcon name="world" />
        <span>Thông dụng</span>
      </div>

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
              on:mouseenter|stopPropagation={() => (vhint = 5)}>
              <span>Hán Việt</span>
            </button>
          </svelte:fragment>
        </CMenu>
      </div>
    </section>

    <section class="body">
      <Emend {term} p_min={$tab + 1} />

      <div class="field">
        <Vhint {hints} bind:term bind:vhint />

        <div class="value" class:_fresh={term._raw.fresh}>
          <input
            type="text"
            class="-input"
            bind:this={value_field}
            bind:value={term.val}
            autocomplete="off"
            autocapitalize={$tab < 1 ? 'words' : 'off'} />

          {#if $tab < 2}
            <button class="postag" data-kbd="p" on:click={() => state.set(2)}>
              {tag_label(term.ptag) || 'Phân loại'}
            </button>
          {/if}
        </div>

        <Vutil bind:term bind:vhint />
      </div>

      <div class="vfoot">
        <Vrank bind:rank={term.rank} bind:vhint />

        <div class="bgroup">
          <button
            class="bgroup-left m-button btn-lg _fill {term.btn_state}  "
            data-kbd="enter"
            {disabled}
            on:mouseenter|stopPropagation={() => (vhint = 1)}
            on:click={() => submit_val('_main')}>
            <SIcon name="users" />
            <span class="submit-text">{term.state}</span>
          </button>

          <button
            class="bgroup-right m-button btn-lg _fill {term.btn_state} "
            data-kbd="shift+enter"
            {disabled}
            on:mouseenter|stopPropagation={() => (vhint = 2)}
            on:click={() => submit_val('_priv')}>
            <SIcon name="user" />
          </button>
        </div>
      </div>
    </section>

    <Links {key} dlabel={label} bind:vhint />
  </div>
</div>

{#if $state > 1}
  <Postag bind:ptag={term.ptag} bind:state={$state} />
{/if}

<style lang="scss">
  $gutter: 0.75rem;

  .wrap {
    @include flex($center: both);
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    z-index: 9999;
    background: rgba(#000, 0.75);
  }

  .main {
    width: rem(30);
    min-width: 320px;
    max-width: 100%;
    @include bgcolor(tert);
    @include bdradi();
    @include shadow(3);
  }

  .head {
    @include flex();
    margin-bottom: 0.5rem;

    @include bdradi($loc: top);
    @include linesd(--bd-soft);

    .m-button {
      @include fgcolor(neutral, 5);
      background: none;
      --linesd: none;

      &:hover {
        @include fgcolor(primary, 5);
      }
    }
  }

  $tab-height: 2rem;

  .tabs {
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
      @include fgcolor(main);
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

  .body {
    @include bgcolor(bg-secd);
    padding: 0 0.75rem;
  }

  .field {
    position: relative;
    @include bdradi;

    @include linesd(--bd-main);
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

    @include linesd(--bd-main);

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

  .bgroup-left {
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

  .bgroup-right {
    margin-left: -1px;
    @include bdradi(0, $loc: left);
  }
</style>
