<script context="module">
  import { writable } from 'svelte/store'
  import { labels } from '$lib/postag.js'
  import { titleize } from '$utils/text_utils'
  import { dict_upsert, dict_search } from '$api/dictdb_api'

  export const phrase = writable(['', 0, 1])
  export const on_tab = writable(0)
  export const active = writable(false)
</script>

<script>
  import { session } from '$app/stores'

  import SIcon from '$lib/blocks/SIcon.svelte'

  import Input from './Upsert/Input.svelte'
  import Emend from './Upsert/Emend.svelte'

  import Vhint from './Upsert/Vhint.svelte'
  import Vutil from './Upsert/Vutil.svelte'

  import Vrank from './Upsert/Vrank.svelte'

  import Privi from './Upsert/Privi.svelte'
  import Links from './Upsert/Links.svelte'

  export let dname = 'combine'
  export let bname = 'Tổng hợp'
  export let changed = false

  $: dicts = [
    [dname, bname],
    ['regular', 'Thông dụng'],
    ['hanviet', 'Hán Việt'],
  ]

  let props = { trans: {}, hints: [] }
  let infos = [{}, {}, {}]

  let key = ''
  $: if ($active && key) init_search(key, dname)

  let value = ['', '', '']
  let origs = ['', '', '']

  let p_old = [1, 2, 3]
  let p_now = [1, 2, 3]

  let value_field
  $: if (value[$on_tab]) focus_on_value()

  function focus_on_value() {
    value_field && value_field.focus()
  }

  function hide_modal(_evt, edited = false) {
    changed = edited
    $active = false
  }

  async function init_search(input, dname) {
    const [err, data] = await dict_search(fetch, input, dname)
    if (err) return

    props = data
    infos = props.infos

    p_old = infos.map((info) => info.privi)
    p_now = p_old.map((p_min, i) => {
      let privi = i + 2
      if (privi < p_min) privi = p_min
      return privi < $session.privi ? privi : $session.privi
    })

    origs = infos.map((info) => info.val[0] || '')

    const hanviet = props.trans.hanviet
    value = [
      origs[0] || origs[1] || props.hints[0] || titleize(hanviet, 9),
      origs[1] || origs[0] || props.hints[0] || hanviet,
      origs[2] || hanviet,
    ]
  }

  async function submit_val(tab = $on_tab) {
    const dname = dicts[tab][0]

    const val = value[tab].replace('', '').trim()
    const { tag, wgt } = infos[tab]

    const ext = tag == 3 ? tag : `${tag} ${wgt}`
    const opts = { key, val, ext, privi: p_now[tab] }

    const [status, _payload] = await dict_upsert(fetch, dname, opts)
    hide_modal(null, status == 0)
  }

  function handle_keydown(evt) {
    if (!$active) return

    switch (evt.keyCode) {
      case 13:
        return submit_val($on_tab)

      case 27:
        return hide_modal(evt, false)

      case 38:
        if (evt.altKey && p_now[$on_tab] < $session.privi) p_now[$on_tab] += 1
        break

      case 40:
        if (evt.altKey && p_now[$on_tab] > 1) p_now[$on_tab] -= 1
        break

      default:
        if (!evt.altKey) return

        // make `~` alias of `0`
        const key = evt.keyCode == 192 ? '0' : evt.key
        let elem = document.querySelector(`.upsert [data-kbd="${key}"]`)

        if (elem) {
          evt.preventDefault()
          elem.click()
        }
    }
  }

  $: submit_state = !value[$on_tab] ? 'Xoá' : origs[$on_tab] ? 'Sửa' : 'Thêm'
  $: curr_state_class = state_class(submit_state)
  $: curr_privi_class = privi_class(p_now[$on_tab], p_old[$on_tab])

  $: binh_am = props.trans.binh_am || ''
  $: hanviet = props.trans.hanviet || ''

  function privi_class(privi, p_old) {
    if (privi < p_old) return 'text'
    return privi == p_old ? 'line' : 'solid'
  }

  function state_class(state) {
    switch (state) {
      case 'Thêm':
        return 'success'
      case 'Sửa':
        return 'primary'
      default:
        return 'harmful'
    }
  }

  function postag_label(tag) {
    return labels[tag] || tag || 'Chưa phân loại'
  }

  function show_postag() {
    // TODO!
  }
</script>

<div
  class="window"
  on:click={() => active.set(false)}
  on:keydown={handle_keydown}>
  <div class="upsert" on:click|stopPropagation={focus_on_value}>
    <header class="header">
      <button type="button" class="m-button _text">
        <SIcon name="menu" />
      </button>

      <Input phrase={$phrase} pinyin={binh_am} bind:output={key} />

      <button type="button" class="m-button _text" on:click={hide_modal}>
        <SIcon name="x" />
      </button>
    </header>

    <section class="dicts">
      {#each dicts as [_dname, label], idx}
        <button
          class="-dname"
          class:_active={idx == $on_tab}
          class:_edited={origs[idx]}
          data-kbd={idx == 0 ? 'x' : idx == 1 ? 'c' : 'v'}
          on:click={() => ($on_tab = idx)}>
          <span>{label}</span>
        </button>
      {/each}
    </section>

    <section class="vform">
      <Emend info={infos[$on_tab]} />

      <div class="field">
        <Vhint
          {hanviet}
          hints={props.hints}
          _orig={origs[$on_tab]}
          bind:value={value[$on_tab]} />

        <div class="value" class:_fresh={!origs[$on_tab]}>
          <input
            id="value"
            type="text"
            class="-input"
            bind:this={value_field}
            bind:value={value[$on_tab]}
            autocomplete="off"
            autocapitalize={$on_tab < 1 ? 'words' : 'off'} />

          {#if $on_tab < 2}
            <button class="postag" on:click={show_postag}>
              {postag_label(infos[$on_tab].tag)}
            </button>
          {/if}
        </div>

        <Vutil bind:value={value[$on_tab]} _orig={origs[$on_tab]} />
      </div>

      <div class="vfoot">
        <Vrank bind:wgt={infos[$on_tab].wgt} />
        <Privi bind:privi={p_now[$on_tab]} p_max={$session.privi} />

        <button
          class="m-button _large _{curr_privi_class} _{curr_state_class}"
          disabled={$session.privi <= $on_tab}
          on:click={() => submit_val($on_tab)}>
          <span class="-text">{submit_state}</span>
        </button>
      </div>
    </section>

    <footer>
      <Links {key} />
    </footer>
  </div>
</div>

<style lang="scss">
  $gutter: 0.75rem;

  .window {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    z-index: 99999;
    background: rgba(#000, 0.75);
    @include flex($center: both);
  }

  .upsert {
    width: rem(30);
    min-width: 320px;
    max-width: 100%;
    @include bgcolor(neutral, 1);
    @include radius();
    @include shadow(3);
  }

  header {
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

  .dicts {
    height: $tab-height;
    padding: 0 0.75rem;

    @include flex();
    @include border($sides: bottom);

    // prettier-ignore
  }

  .-dname {
    // text-transform: capitalize;
    font-weight: 500;
    padding: 0 0.75rem;
    background-color: transparent;

    height: $tab-height;
    line-height: $tab-height;
    flex-shrink: 0;

    margin-right: 0.5rem;

    @include font-size(3);
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
      --bdcolor: #{color(primary, 3)};
      --bgcolor: #fff;
    }
  }

  .value {
    display: flex;
    height: 3rem;
    padding: 0.75rem;

    &._fresh > * {
      font-style: italic;
    }

    > .-input {
      flex: 1;
      margin: 0;
      outline: 0;
      border: 0;
      background: inherit;
      @include font-size(4);
    }
  }

  .postag {
    text-transform: uppercase;
    padding: 0 0.5rem;
    margin-left: 0.5rem;
    background: transparent;
    border-radius: 0.75rem;
    font-weight: 500;
    font-size: rem(12px);
    @include fgcolor(neutral, 6);
    @include border;

    &:hover {
      background: #fff;
    }
  }

  .vfoot {
    display: flex;
    margin-top: 0.75rem;
    justify-content: right;

    > button {
      margin-left: 0.75rem;
      justify-content: center;
      width: 4rem;
    }
  }

  footer {
    border-top: 1px solid color(neutral, 3);
  }
</style>
