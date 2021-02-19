<script context="module">
  import { u_power } from '$src/stores'
  import { writable } from 'svelte/store'

  import { titleize } from '$utils/text_utils'
  import { dict_upsert, dict_search } from '$api/dictdb_api'

  export const phrase = writable(['', 0, 1])
  export const on_tab = writable(0)
  export const active = writable(false)
</script>

<script>
  import SIcon from '$blocks/SIcon'

  import Input from './Upsert/Input'
  import Dname from './Upsert/Dname'

  import Vhint from './Upsert/Vhint'
  import Vutil from './Upsert/Vutil'
  import Vattr from './Upsert/Vattr'
  import Vprio from './Upsert/Vprio'

  import Emend from './Upsert/Emend'
  import Power from './Upsert/Power'
  import Bsend from './Upsert/Bsend'

  import Links from './Upsert/Links'

  export let dname = 'various'
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
    props = await dict_search(fetch, input, dname)
    infos = props.infos

    p_old = infos.map((info) => info.power)
    p_now = p_old.map((pmin) => (pmin < $u_power ? pmin : $u_power))

    origs = infos.map((info) => info.vals[0] || '')

    const hanviet = props.trans.hanviet
    value = [
      origs[0] || origs[1] || props.hints[0] || titleize(hanviet, 9),
      origs[1] || origs[0] || props.hints[0] || hanviet,
      origs[2] || hanviet,
    ]
  }

  async function submit_val(tab = $on_tab) {
    const dname = dicts[tab][0]
    const params = {
      key,
      vals: value[tab],
      prio: infos[tab].prio,
      attr: infos[tab].attr,
      power: p_now[tab],
    }

    const res = await dict_upsert(fetch, dname, params)
    hide_modal(null, res.ok)
  }

  function handle_keydown(evt) {
    if (!$active) return

    switch (evt.keyCode) {
      case 13:
        return submit_val($on_tab)

      case 27:
        return hide_modal(evt, false)

      case 38:
        if (evt.altKey && p_now[$on_tab] < $u_power) p_now[$on_tab] += 1
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
</script>

<div
  class="window"
  on:click={() => active.set(false)}
  on:keydown={handle_keydown}>
  <div class="upsert" on:click|stopPropagation={focus_on_value}>
    <header class="header">
      <div class="hanzi">
        <Input phrase={$phrase} bind:output={key} />
      </div>

      <button type="button" class="m-button _text" on:click={hide_modal}>
        <SIcon name="x" />
      </button>
    </header>

    <section class="dicts">
      {#each dicts as [_dname, label], idx}
        <Dname
          dname={label}
          active={idx == $on_tab}
          exists={origs[idx]}
          {idx}
          on:click={() => ($on_tab = idx)} />
      {/each}
    </section>

    <section class="vform">
      <Emend info={infos[$on_tab]} />

      <div class="forms">
        <div class="value">
          <Vhint
            hints={props.hints}
            trans={props.trans}
            _orig={origs[$on_tab]}
            bind:value={value[$on_tab]} />

          <input
            id="value"
            lang="vi"
            type="text"
            class="-input"
            class:_fresh={!origs[$on_tab]}
            bind:this={value_field}
            bind:value={value[$on_tab]}
            autocomplete="off"
            autocapitalize={$on_tab < 1 ? 'words' : 'off'} />

          {#if $on_tab < 2}
            <Vattr bind:attr={infos[$on_tab].attr} />
          {/if}

          <Vutil bind:value={value[$on_tab]} _orig={origs[$on_tab]} />
        </div>
      </div>

      <div class="vfoot">
        <Bsend
          value={value[$on_tab]}
          _orig={origs[$on_tab]}
          power={p_now[$on_tab]}
          p_min={p_old[$on_tab]}
          on:click={() => submit_val($on_tab)} />

        <Power bind:power={p_now[$on_tab]} p_max={$u_power} />
        <Vprio bind:prio={infos[$on_tab].prio} />
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
    padding: 0.75rem;

    button {
      @include fgcolor(neutral, 6);
      &:hover {
        @include fgcolor(primary, 6);
      }
    }

    .hanzi {
      flex-grow: 1;
      margin-right: 0.5rem;
    }
  }

  .dicts {
    height: 2.25rem;
    padding: 0 0.75rem;

    @include flex();
    @include border($sides: bottom);

    // prettier-ignore
    > :global(*) {
      margin-right: 0.75rem;
      &:last-child { margin-right: 0; }
    }
  }

  .vform {
    @include bgcolor(#fff);
    padding: 0.75rem;
    padding-top: 0;
  }

  .forms {
    position: relative;
  }

  .value {
    position: relative;

    .-input {
      display: block;
      width: 100%;
      margin: 0;
      line-height: 2.5rem;
      padding: 2rem 0.75rem;
      // text-align: center;
      outline: none;

      @include radius;
      @include border;
      @include bgcolor(neutral, 1);
      @include font-size(4);

      &:focus,
      &:active {
        @include bdcolor(primary, 3);
        @include bgcolor(white);
      }
    }

    ._fresh {
      font-style: italic;
    }
  }

  .vfoot {
    margin-top: 0.75rem;
    @include flow();
    > :global(*) {
      float: right;
      margin-left: 0.5rem;
    }
  }

  footer {
    border-top: 1px solid color(neutral, 3);
  }
</style>
