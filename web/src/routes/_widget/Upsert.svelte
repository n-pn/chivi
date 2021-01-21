<script context="module">
  import { u_power } from '$src/stores'
  import { writable } from 'svelte/store'

  import { titleize } from '$utils/text_utils'
  import { dict_upsert, dict_search } from '$utils/api_calls'

  export const phrase = writable(['', 0, 1])
  export const on_tab = writable(0)
  export const active = writable(false)

  const btn_class = { Thêm: 'success', Sửa: 'primary', Xoá: 'harmful' }
  const map_status = (val, old) => (!val ? 'Xoá' : old ? 'Sửa' : 'Thêm')

  function get_curr(infos, idx) {
    const info = infos[idx] || { vals: [], hints: [] }
    const orig = info.vals[0]
    const prev = info.hints[0]
    return { info, orig, prev }
  }

  const get_dict = (dicts, idx) => dicts[idx][0]
</script>

<script>
  import SvgIcon from '$atoms/SvgIcon'

  import Input from './Upsert/Input'
  import Dname from './Upsert/Dname'

  import Vhint from './Upsert/Vhint'
  import Vutil from './Upsert/Vutil'
  import Attrs from './Upsert/Attrs'

  import Emend from './Upsert/Emend'
  import Power from './Upsert/Power'

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
  let infos = []
  let curr = get_curr(infos, $on_tab)

  let value = curr.orig || null
  let attrs = curr.info.attrs || ''

  let value_field
  $: if (value) value_field.focus()

  let key = ''
  $: if ($active && key) init_search(key, d_name)

  async function init_search(key, dname) {
    const data = await dict_search(fetch, key, dname)
    trans = data.trans || { hanviet: '', binh_am: '' }
    infos = data.infos || []
    hints = data.hints || []

    change_tab($on_tab)
  }

  $: p_min = curr.info.power || $on_tab + 1
  $: power = p_min < $u_power ? p_min : $u_power

  $: updated = value !== curr.orig
  $: prevail = power >= p_min
  $: btn_power = power < p_min ? 'text' : power == p_min ? 'line' : 'solid'
  $: status = map_status(value, curr.orig)

  function change_tab(idx) {
    on_tab.set(idx)
    curr = get_curr(infos, idx)
    attrs = curr.info.attrs || ''
    update_val()
  }

  function update_val(new_val = curr.orig) {
    value = new_val || hints[0] || titleize(trans.hanviet, $on_tab < 1)
  }

  async function submit_val() {
    const dname = get_dict(dicts, $on_tab)
    const res = await dict_upsert(fetch, dname, { key, value, attrs, power })

    changed = res.ok
    $active = false
  }

  function handle_keydown(evt) {
    if (!$active) return

    switch (evt.keyCode) {
      case 13:
        return submit_val()

      case 27:
        return active.set(false)

      case 38:
        if (evt.altKey && power < $u_power) power += 1
        break

      case 40:
        if (evt.altKey && power > 0) power -= 1
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
        <Input phrase={$phrase} bind:output={key} binh_am={trans.binh_am} />
      </div>

      <button
        type="button"
        class="m-button _text"
        on:click={() => ($active = false)}>
        <SvgIcon name="x" />
      </button>
    </header>

    <section class="dicts">
      {#each dicts as [_dname, label], idx}
        <Dname
          d_name={label}
          active={idx == $on_tab}
          exists={get_curr(infos, idx).info.vals.length > 0}
          {idx}
          on:click={() => change_tab(idx)} />
      {/each}
    </section>

    <section class="vform">
      <div class="forms">
        <div class="value">
          <Vhint {hints} {trans} bind:value _orig={curr.orig} />

          <input
            name="value"
            lang="vi"
            type="vi"
            class="-input"
            class:_fresh={!curr.orig}
            bind:this={value_field}
            bind:value
            autocomplete="off"
            autocapitalize={$on_tab < 1 ? 'words' : 'off'} />

          <Vutil bind:value _orig={curr.orig} />
        </div>

        <Attrs bind:attrs dtype={$on_tab} />
      </div>

      <div class="vfoot">
        <div class="-emend">
          {#if curr.info.uname}
            <Emend {curr} />
          {/if}
        </div>

        <Power bind:power p_max={$u_power} />

        <button
          class="m-button _large _{btn_class[status]} _{btn_power}"
          disabled={!(updated || prevail)}
          on:click|once={submit_val}>
          <span class="-text">{status}</span>
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
