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
</script>

<script>
  import SvgIcon from '$atoms/SvgIcon'
  import RelTime from '$atoms/RelTime'

  import Input from './Upsert/Input'
  import Links from './Upsert/Links'

  export let changed = false
  export let d_name = 'various'
  export let b_name = 'Tổng hợp'

  $: dicts = [
    [d_name, b_name],
    ['regular', 'Thông dụng'],
    ['hanviet', 'Hán Việt'],
  ]

  let value_field
  $: if ($active && value_field) value_field.focus()

  let key = $phrase[0].substring($phrase[1], $phrase[2])
  let value
  let attrs = ''

  let hanviet = ''
  let binh_am = ''

  let infos = []
  let hints = []

  $: if ($active && key) init_search(d_name)

  async function init_search(dname) {
    const data = await dict_search(fetch, key, dname)

    hanviet = data.hanviet
    binh_am = data.binh_am
    infos = data.infos
    hints = data.hints.filter((x) => x != hanviet)

    update_val()
  }

  let _curr = {}
  let _orig, _prev

  $: p_min = _curr.power || $on_tab + 1
  $: power = p_min < $u_power ? p_min : $u_power

  $: updated = value != _orig
  $: prevail = power >= p_min
  $: btn_power = power < p_min ? 'text' : power == p_min ? 'line' : 'solid'
  $: status = map_status(value, _orig)

  async function submit_val() {
    const dname = dicts[$on_tab][0]
    const res = await dict_upsert(fetch, dname, { key, value, attrs, power })

    changed = res.ok
    console.log({ changed })

    $active = false
  }

  function update_val(new_val) {
    _curr = infos[$on_tab] || { vals: [], hints: [] }
    _orig = _curr.vals[0]
    _prev = _curr.hints[0] || new_val

    new_val = new_val || _orig || hints[0]
    value = new_val || titleize(hanviet, $on_tab < 1 ? 10 : 0)
    value_field.focus()
  }

  function change_tab(idx) {
    on_tab.set(idx)
    update_val()
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

      default:
        if (!evt.altKey) return

        // make `~` alias of `0`
        const key = evt.keyCode == 192 ? '0' : evt.key
        let elem = documemt.querySelector(`.upsert [data-kbd="${key}"]`)

        if (elem) {
          // evt.preventDefault()
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

    <section class="tabs">
      {#each dicts as [_dname, label], idx}
        <span
          class="tab"
          class:_actived={idx == $on_tab}
          class:_existed={infos[idx] && infos[idx].vals.length > 0}
          data-kbd={idx == 0 ? 'x' : idx == 1 ? 'c' : 'v'}
          on:click={() => change_tab(idx)}>
          {label}
        </span>
      {/each}
    </section>

    <section class="body">
      <div class="value">
        <div class="hints">
          <span class="-hint" on:click={() => update_val(hanviet)}>
            {hanviet}
          </span>

          {#each hints as _hint}
            {#if _hint != value}
              <span
                class="-hint"
                class:_exist={_hint == _orig}
                on:click={() => update_val(_hint)}>{_hint}</span>
            {/if}
          {/each}

          <span class="-hint _right">[{binh_am}]</span>
        </div>

        <div class="value">
          <input
            lang="vi"
            type="text"
            name="value"
            class:_fresh={!_orig}
            bind:this={value_field}
            bind:value
            autocomplete="off"
            autocapitalize={$on_tab < 1 ? 'words' : 'off'} />
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
              on:click={() => update_val(_orig || _prev)}>Phục</button>
          {/if}
        </div>
      </div>

      <div class="action">
        {#if _curr && _curr.uname}
          <div class="-emend">
            <div class="-line">
              <span class="-text"
                >{map_status(_orig, _curr && _curr.hints[0])} bởi:
              </span>
              <span class="-user">{_curr.uname}</span>
              <span class="-text">Q.hạn:</span>
              <span class="-user">{_curr.power}</span>
            </div>

            <div class="-line">
              <span class="-text">Thời gian:</span>
              <span class="-time"><RelTime m_time={_curr.mtime} /></span>
            </div>
          </div>
        {/if}

        <div class="-right">
          <div class="-power">
            <div class="-value"><span>Q.h:</span>{power}</div>

            <button
              class="-up"
              disabled={power == $u_power}
              on:click={() => (power += 1)}
              ><SvgIcon name="chevron-up" /></button>
            <button
              class="-dn"
              disabled={power == 0}
              on:click={() => (power -= 1)}
              ><SvgIcon name="chevron-down" /></button>
          </div>

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

  .tabs {
    padding: 0 0.75rem;
    height: 2rem;
    line-height: 2rem;

    @include border($sides: bottom);
    @include flex();
    @include flex-gap(0.75rem, $child: '.tab');
  }

  .tab {
    cursor: pointer;
    text-transform: uppercase;
    font-weight: 500;
    padding: 0 0.75rem;
    height: 2rem;
    margin-top: 0.25px;

    flex-shrink: 0;

    @include truncate(null);
    @include font-size(2);
    @include fgcolor(neutral, 5);

    @include radius($sides: top);
    @include border($color: neutral, $sides: top-left-right);

    &:first-child {
      max-width: 35%;
      flex-shrink: 1;
    }

    &._existed {
      @include fgcolor(neutral, 7);
    }

    &._actived {
      @include bgcolor(#fff);
      @include fgcolor(primary, 6);
      @include bdcolor($color: primary, $shade: 4);
    }
  }

  .body {
    @include bgcolor(#fff);
    padding: 0.75rem;
  }

  $label-width: 3rem;

  $suggests-height: 2rem;
  $titleize-height: 2rem;
  $val-line-height: 2.5rem;

  .value {
    @include bgcolor(neutral, 1);
  }

  .value > input {
    display: block;
    width: 100%;

    margin: 0;

    line-height: 1.5rem;
    padding: 0.75rem;

    outline: none;
    @include border();
    @include bgcolor(neutral, 1);

    &:focus,
    &:active {
      @include bgcolor(white);
      @include bdcolor($color: primary, $shade: 3);
    }

    &._fresh {
      font-style: italic;
    }
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
    margin-top: 0.75rem;
    @include flex();
    @include flex-gap($gap: 0.5rem, $child: ':global(*)');

    .-right {
      display: flex;
      margin-left: auto;
    }
  }

  .-emend {
    @include fgcolor(neutral, 6);
    @include font-size(2);

    .-text {
      font-style: italic;
    }

    .-time,
    .-user {
      @include fgcolor(primary, 8);
    }

    .-user {
      font-weight: 500;
      @include truncate(5vw);
    }
  }

  .-power {
    padding-left: 0.5rem;
    padding-right: 1.75rem;

    position: relative;
    margin-right: 0.5rem;
    font-weight: 500;

    @include border;
    @include radius;

    > .-value {
      display: inline-block;
      line-height: 2.625rem;

      span {
        padding-right: 0.125rem;
        @include fgcolor(neutral, 5);
      }
    }

    > button {
      position: absolute;

      right: 0;
      background-color: transparent;

      &.-up {
        top: 0;
      }

      &.-dn {
        bottom: 0;
      }
    }
  }

  footer {
    border-top: 1px solid color(neutral, 3);
  }
</style>
