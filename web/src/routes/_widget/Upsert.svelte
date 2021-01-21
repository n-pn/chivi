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
  import Value from './Upsert/Value'
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
  let infos = []
  let hints = []

  let value_field
  $: if ($active && value_field) value_field.focus()
  $: key = $phrase[0].substring($phrase[1], $phrase[2])

  let curr = get_curr(infos, $on_tab)

  let value = curr.orig
  $: attrs = curr.info.attrs

  $: if ($active && key) init_search(d_name)

  async function init_search(dname) {
    const data = await dict_search(fetch, key, dname)
    trans = data.trans
    infos = data.infos
    hints = data.hints

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
    update_val()
  }

  function update_val(new_val = curr.orig) {
    value = new_val || hints[0] || titleize(trans.hanviet, $on_tab < 1)
    value_field.focus()
  }

  async function submit_val() {
    const dname = get_dict(dicts, $on_tab)
    const res = await dict_upsert(fetch, dname, { key, value, attrs, power })

    changed = res.ok
    $active = false
  }

  function upcase_val(node, count) {
    const handle_click = (_) => update_val(titleize(value, count))
    node.addEventListener('click', handle_click)

    return {
      destroy: () => node.removeEventListener('click', handle_click),
    }
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
        <Input phrase={$phrase} bind:output={key} />
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
      <div class="value">
        <div class="hints">
          <span class="-hint" on:click={() => update_val(trans.hanviet)}>
            {trans.hanviet}
          </span>

          {#each hints as hint}
            {#if hint != value}
              <span
                class="-hint"
                class:_exist={hint == curr.orig}
                on:click={() => update_val(hint)}>{hint}</span>
            {/if}
          {/each}

          <span class="-hint _right">[{trans.binh_am}]</span>
        </div>

        <div class="output">
          <Value
            bind:value
            bind:field={value_field}
            fresh={!curr.orig}
            autocap={$on_tab < 1 ? 'words' : 'off'} />
        </div>

        <div class="format">
          <button data-kbd="1" use:upcase_val={1}>
            <span class="_md">hoa</span>
            một chữ
          </button>
          <button data-kbd="2" use:upcase_val={2}>hai chữ</button>
          <button class="_md" data-kbd="3" use:upcase_val={3}>ba chữ</button>
          <button data-kbd="4" use:upcase_val={99}>tất cả</button>
          <button data-kbd="0" use:upcase_val={0}>
            không
            <span class="_sm">hoa</span>
          </button>
          <button class="_right" data-kbd="e" on:click={() => (value = '')}
            >Xoá</button>
          {#if updated}
            <button
              class="_right"
              data-kbd="r"
              on:click={() => update_val(curr.orig)}>Phục</button>
          {/if}
        </div>
      </div>

      <div class="action">
        {#if curr.info.uname}
          <Emend {curr} />
        {/if}

        <div class="-right">
          <Power bind:power p_max={$u_power} />
          <button
            class="m-button _large _{btn_class[status]} _{btn_power}"
            disabled={!(updated || prevail)}
            on:click|once={submit_val}>
            <span class="-text">{status}</span>
          </button>
        </div>
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
    display: flex;
    position: fixed;
    align-items: center;
    justify-content: center;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 999;
    background: rgba(#000, 0.75);
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

  .hints {
    // width: 100%;
    // height: $suggests-height;

    padding: 0.25rem 0.5rem;
    font-style: italic;

    @include border($sides: top-left-right);
    @include radius($sides: top);

    @include flex();
    @include flex-gap(0.25rem, $child: '.-hint');
    @include font-size(2);

    .-hint {
      cursor: pointer;
      line-height: 1.5rem;
      height: 1.5rem;
      padding: 0 0.25rem;
      @include truncate(null);

      @include fgcolor(neutral, 6);
      @include bgcolor(neutral, 1);
      @include radius;

      &:hover {
        @include fgcolor(primary, 6);
        @include bgcolor(primary, 1);
      }

      &._exist {
        font-style: normal;
        font-weight: 500;
      }

      &._right {
        margin-left: auto;
      }
    }
  }

  .format {
    $height: 2.25rem;

    padding: 0 0.375rem;
    overflow: hidden;
    height: $height;

    @include flow();

    @include border();
    border-top: none;
    @include radius($sides: bottom);

    @include props(font-size, rem(11px), $md: rem(12px));

    button {
      float: left;
      padding: 0 0.375rem;
      line-height: $height;
      font-weight: 500;
      text-transform: uppercase;
      background: none;
      @include fgcolor(neutral, 5);

      // max-width: 14vw;
      @include truncate(null);

      &:hover {
        @include fgcolor(primary, 5);
        background: #fff;
      }

      &._right {
        float: right;
      }
    }

    ._md {
      display: none;
      @include screen-min(md) {
        display: inline-block;
      }
    }

    ._sm {
      display: none;
      @include screen-min(sm) {
        display: inline-block;
      }
    }
  }

  .action {
    padding-top: 0.75rem;
    @include bgcolor(#fff);
    @include flex();
    @include flex-gap($gap: 0.5rem, $child: ':global(*)');

    .-right {
      display: flex;
      margin-left: auto;
    }
  }

  footer {
    border-top: 1px solid color(neutral, 3);
  }
</style>
