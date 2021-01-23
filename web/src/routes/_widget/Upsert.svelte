<script context="module">
  import { u_power } from '$src/stores'
  import { writable } from 'svelte/store'

  import { titleize } from '$utils/text_utils'
  import { dict_upsert, dict_search } from '$utils/api_calls'

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
  import Attrs from './Upsert/Attrs'

  import Emend from './Upsert/Emend'
  import Power from './Upsert/Power'
  import Bsend from './Upsert/Bsend'

  import Links from './Upsert/Links'

  export let changed = false
  export let d_name = 'various'
  export let b_name = 'Tổng hợp'

  $: dicts = [
    [d_name, b_name],
    ['regular', 'Thông dụng'],
    ['hanviet', 'Hán Việt'],
  ]

  let trans = {}
  let hints = []
  let infos = [{}, {}, {}]

  let key = ''
  $: if ($active && key) init_search(key, d_name)

  let value = ['', '', '']
  let origs = ['', '', '']
  let attrs = ['', '', '']

  let p_min = [1, 2, 3]
  let power = [1, 2, 3]

  let value_field
  $: if (value_field && value[$on_tab]) value_field.focus()

  async function init_search(input, dname) {
    const data = await dict_search(fetch, input, dname)

    trans = data.trans
    hints = data.hints
    infos = data.infos

    p_min = infos.map((v, i) => (+v.power > i + 1 ? +v.power : i + 1))
    power = p_min.map((x) => (x < $u_power ? x : $u_power))

    origs = infos.map((v) => v.vals[0] || '')
    value = origs.map((v, i) => v || hints[0] || titleize(trans.hanviet, i < 1))

    let _attr = value[1] ? infos[1].attrs || '' : 'N'
    attrs = infos.map((v, i) => (v.attrs || i == 0 ? _attr : ''))
  }

  async function submit_val(tab = $on_tab) {
    const dname = dicts[tab][0]
    const params = {
      key,
      value: value[tab],
      attrs: attrs[tab],
      power: power[tab],
    }

    const res = await dict_upsert(fetch, dname, params)
    changed = res.ok
    $active = false
  }

  function handle_keydown(evt) {
    if (!$active) return

    switch (evt.keyCode) {
      case 13:
        return submit_val($on_tab)

      case 27:
        return active.set(false)

      case 38:
        if (evt.altKey && power < $u_power) power += 1
        break

      case 40:
        if (evt.altKey && power > 1) power -= 1
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
  <div class="upsert" on:click|stopPropagation={() => value_field.focus()}>
    <header class="header">
      <div class="hanzi">
        <Input phrase={$phrase} bind:output={key} />
      </div>

      <button
        type="button"
        class="m-button _text"
        on:click={() => ($active = false)}>
        <SIcon name="x" />
      </button>
    </header>

    <section class="dicts">
      {#each dicts as [_dname, label], idx}
        <Dname
          d_name={label}
          active={idx == $on_tab}
          exists={origs[idx]}
          {idx}
          on:click={() => ($on_tab = idx)} />
      {/each}
    </section>

    <section class="vform">
      <div class="forms">
        <div class="value">
          <Vhint
            {hints}
            {trans}
            bind:value={value[$on_tab]}
            _orig={origs[$on_tab]} />

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

          <Vutil bind:value={value[$on_tab]} _orig={origs[$on_tab]} />
        </div>

        <Attrs bind:attrs={attrs[$on_tab]} with_types={$on_tab < 2} />
      </div>

      <div class="vfoot">
        <div class="-emend">
          {#if infos[$on_tab].uname}
            <Emend info={infos[$on_tab]} />
          {/if}
        </div>

        <Power bind:power={power[$on_tab]} p_max={$u_power} />

        <Bsend
          value={value[$on_tab]}
          _orig={origs[$on_tab]}
          power={power[$on_tab]}
          p_min={p_min[$on_tab]}
          on:click={() => submit_val($on_tab)} />
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
    z-index: 999;
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
    @include flex();

    .-emend {
      flex: 1;
    }

    > :global(*) {
      margin-right: 0.75rem;

      &:last-child {
        margin-right: 0;
      }
    }
  }

  footer {
    border-top: 1px solid color(neutral, 3);
  }
</style>
