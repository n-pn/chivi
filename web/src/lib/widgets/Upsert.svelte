<script context="module">
  import { writable } from 'svelte/store'
  import { tag_label } from '$lib/postag.js'
  import { titleize } from '$utils/text_utils'
  import { dict_upsert, dict_search } from '$api/dictdb_api'

  export const tab = writable(0)
  export const state = writable(0)
  export const input = writable(['', 0, 1])

  export function activate(inp, on_tab = 0, active_state = 1) {
    if (typeof inp == 'string') inp = [inp, 0, inp.length]

    tab.set(on_tab)
    state.set(active_state)
    input.set(inp)
  }

  export function deactivate() {
    state.set(0)
  }

  export class Term {
    constructor(term = {}, p_min = 1, p_max = 1) {
      this.key = term.key

      const val = term.val || []
      this.val = this.old_val = val[0] || ''

      this.tag = this.old_tag = term.tag || ''
      this.wgt = this.old_wgt = term.wgt || 3

      this.old_privi = term.privi || p_min
      this.old_state = term.state
      this.old_uname = term.uname
      this.old_mtime = term.mtime

      this.privi = p_min > term.privi ? p_min : term.privi
      if (this.privi > p_max) this.privi = p_max
    }

    get ext() {
      return this.tag == 3 ? this.tag : `${this.tag} ${this.wgt}`
    }

    get state() {
      return !this.val ? 'Xoá' : this.old_val ? 'Sửa' : 'Thêm'
    }

    get result() {
      return {
        key: this.key,
        val: this.val.replace('', '').trim(),
        ext: this.ext,
        privi: this.privi,
      }
    }

    reset() {
      this.val = this.old_val
      this.tag = this.old_tag

      return this
    }

    clear() {
      this.val = ''
      this.tag = ''

      return this
    }

    fix_val(new_val) {
      if (!this.val) this.val = new_val
    }

    fix_tag(new_tag) {
      if (!this.tag) this.tag = new_tag
    }
  }
</script>

<script>
  import { session } from '$app/stores'

  import Postag from './Postag.svelte'

  import SIcon from '$lib/blocks/SIcon.svelte'

  import Input from './Upsert/Input.svelte'
  import Emend from './Upsert/Emend.svelte'

  import Vhint from './Upsert/Vhint.svelte'
  import Vutil from './Upsert/Vutil.svelte'

  import Vrank from './Upsert/Vrank.svelte'

  import Privi from './Upsert/Privi.svelte'
  import Links from './Upsert/Links.svelte'

  export let dname = 'combine'
  export let label = 'Tổng hợp'
  export let dirty = false

  $: dicts = [
    [dname, label],
    ['regular', 'Thông dụng'],
    ['hanviet', 'Hán Việt'],
  ]

  let trans = []
  let hints = []
  let terms = []

  $: term = terms[$tab] || new Term({ key }, $tab + 1, $session.privi)

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

    trans = data.trans
    terms = data.infos.map((x, i) => new Term(x, i + 2, $session.privi))

    const first_hint = data.hints

    terms[0].fix_val(terms[1].val || first_hint || titleize(trans.hanviet, 9))
    terms[1].fix_val(terms[0].val || first_hint || trans.hanviet)

    terms[1].fix_tag(terms[0].tag)
    terms[0].fix_tag(terms[1].tag || 'nr')
    hints = [trans.hanviet, ...data.hints]
  }

  async function submit_val() {
    dirty = await dict_upsert(fetch, dicts[$tab][0], term.result)
    deactivate()
  }

  function handle_keyboard(evt) {
    if ($state < 1) return

    switch (evt.keyCode) {
      case 13:
        return submit_val()

      case 27:
        return deactivate()

      case 38:
        if (evt.altKey && term?.privi < $session.privi) term.privi += 1
        break

      case 40:
        if (evt.altKey && term?.privi > 1) term.privi -= 1
        break

      default:
        if (!evt.altKey) return

        // make `~` alias of `0`
        const key = evt.keyCode == 192 ? '0' : evt.key
        let elem = document.querySelector(`#upsert [data-kbd="${key}"]`)

        if (elem) {
          evt.preventDefault()
          elem.click()
        }
    }
  }
</script>

<div
  class="wrap"
  class:_active={$state > 0}
  tabindex="-1"
  on:click={deactivate}
  on:keydown={handle_keyboard}>
  <div id="upsert" class="main" on:click|stopPropagation={focus_on_value}>
    <header class="head">
      <button type="button" class="m-button _text">
        <SIcon name="menu" />
      </button>

      <Input phrase={$input} pinyin={trans.binh_am} bind:output={key} />

      <button type="button" class="m-button _text" on:click={deactivate}>
        <SIcon name="x" />
      </button>
    </header>

    <section class="tabs">
      {#each dicts as [_dname, label], idx}
        <button
          class="-tab"
          class:_active={idx == $tab}
          class:_edited={terms[idx]?.old_val}
          data-kbd={idx == 0 ? 'x' : idx == 1 ? 'c' : 'v'}
          on:click={() => tab.set(idx)}>
          <span>{label}</span>
        </button>
      {/each}
    </section>

    <section class="vform">
      <Emend {term} />

      <div class="field">
        <Vhint {hints} bind:term />

        <div class="value" class:_fresh={!term.old_val}>
          <input
            id="value"
            type="text"
            class="-input"
            bind:this={value_field}
            bind:value={term.val}
            autocomplete="off"
            autocapitalize={$tab < 1 ? 'words' : 'off'} />

          {#if $tab < 2}
            <button class="postag" on:click={() => state.set(2)}>
              {tag_label(term.tag) || 'Chưa phân loại'}
            </button>

            <Postag bind:input={term.tag} bind:state={$state} />
          {/if}
        </div>

        <Vutil bind:term />
      </div>

      <div class="vfoot">
        <Vrank bind:wgt={term.wgt} />

        <Privi
          {term}
          p_min={$tab + 1}
          p_max={$session.privi}
          on:click={() => submit_val($tab)} />
      </div>
    </section>

    <footer>
      <Links {key} />
    </footer>
  </div>
</div>

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
    visibility: hidden;
    &._active {
      visibility: visible;
    }
  }

  .main {
    width: rem(30);
    min-width: 320px;
    max-width: 100%;
    @include bgcolor(neutral, 1);
    @include radius();
    @include shadow(3);
  }

  .head {
    display: flex;
    padding: 0.5rem 0.25rem;
    overflow: hidden;

    > button {
      @include fgcolor(neutral, 6);

      &:hover {
        background: transparent;
        @include fgcolor(primary, 6);
      }
    }
  }

  $tab-height: 2rem;

  .tabs {
    height: $tab-height;
    padding: 0 0.75rem;

    @include flex();
    @include border($sides: bottom);

    // prettier-ignore
  }

  .-tab {
    // text-transform: capitalize;
    font-weight: 500;
    padding: 0 0.75rem;
    background-color: transparent;

    height: $tab-height;
    line-height: $tab-height;
    flex-shrink: 0;

    margin-right: 0.5rem;

    @include font-size(2);
    @include fgcolor(neutral, 5);
    @include truncate(null);
    @include radius($sides: top);
    @include border($color: neutral, $sides: top-left-right);

    &:first-child {
      max-width: 38%;
      flex-shrink: 1;
    }

    &._edited {
      @include fgcolor(neutral, 7);
    }

    &:hover {
      @include bgcolor(#fff);
    }

    &._active {
      @include bgcolor(#fff);
      @include fgcolor(primary, 6);
      @include bdcolor($color: primary, $shade: 4);
    }

    &:last-child {
      margin-left: auto;
      margin-right: 0;
    }
  }

  .vform {
    @include bgcolor(#fff);
    padding: 0 0.75rem 0.75rem;
  }

  .field {
    position: relative;
    @include radius;

    --bdcolor: #{color(neutral, 3)};
    --bgcolor: #{color(neutral, 1)};

    background: var(--bgcolor);
    box-shadow: 0 0 0 1px var(--bdcolor);

    &:focus-within {
      --bdcolor: #{color(primary, 4)};
      --bgcolor: #fff;
    }
  }

  .value {
    display: flex;
    $h-outer: 3rem;
    $h-inner: 1.75rem;

    height: $h-outer;
    padding: math.div($h-outer - $h-inner, 2);

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
      @include font-size(4);
    }
  }

  .postag {
    white-space: nowrap;
    padding: 0 0.5rem;
    margin-left: 0.5rem;
    background: transparent;
    border-radius: 0.75rem;
    font-weight: 500;
    font-size: rem(14px);

    @include fgcolor(neutral, 6);

    --bdcolor: #{color(neutral, 2)};
    box-shadow: 0 0 0 1px var(--bdcolor);

    &:hover {
      @include fgcolor(primary, 7);
      @include bgcolor(primary, 1);
      --bdcolor: #{color(primary, 3)};
    }
  }

  .vfoot {
    display: flex;
    margin-top: 0.75rem;
    justify-content: right;
  }

  footer {
    border-top: 1px solid color(neutral, 3);
  }
</style>
