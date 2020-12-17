<script context="module">
  function make_hints(inquire, accept) {
    let res = []

    for (let { vals, hints } of inquire.entries) {
      for (let x of vals) res.push(x)
      for (let x of hints) res.push(x)
    }

    for (let x of inquire.suggest) res.push(x)
    if (accept) res.push(accept)

    return res.filter((v, i, s) => {
      if (v == inquire.hanviet) return false
      return s.indexOf(v) === i
    })
  }

  function capitalize(input) {
    return input.charAt(0).toUpperCase() + input.slice(1)
  }

  function titleize(input, count = 9) {
    const res = input.split(' ')
    if (count > res.length) count = res.length

    for (let i = 0; i < count; i++) res[i] = capitalize(res[i])
    for (let i = count; i < res.length; i++) res[i] = res[i].toLowerCase()

    return res.join(' ')
  }

  export async function dict_search(fetch, hanzi, dicts = ['dich-nhanh']) {
    const url = `/api/dicts/search/${hanzi}?dicts=${dicts.join('|')}`
    const res = await fetch(url)
    const data = await res.json()

    return data
  }

  export async function dict_upsert(fetch, dic, key, val = '') {
    const url = `/api/dicts/upsert/${dic}`
    const res = await fetch(url, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ key, val }),
    })

    return res
  }

  function fix_power(user, prev) {
    if (user < prev) return ['text', false]
    else if (user == prev) return ['line', false]
    else return ['solid', true]
  }

  function fix_label(new_val, old_val) {
    if (!new_val) return ['harmful', 'Xoá từ']
    else if (old_val) return ['primary', 'Sửa từ']
    else return ['success', 'Thêm từ']
  }

  import {
    // self_uname,
    self_power,
    upsert_input,
    upsert_dicts as dicts,
    upsert_ontab as d_idx,
    upsert_actived as actived,
  } from '$src/stores'

  import SvgIcon from '$atoms/SvgIcon'
  import RelTime from '$atoms/RelTime'

  import UpsertInput from './UpsertModal/Input.svelte'
  import UpsertLinks from './UpsertModal/Links.svelte'
</script>

<script>
  export let dirty = false

  let [input, lower, upper] = $upsert_input
  $: hanzi = input.substring(lower, upper)
  $: if ($actived && hanzi) inquire_hanzi(hanzi)

  let output = ''

  // let cached = {}
  let inquire = { entries: [], hanviet: '', binh_am: '', suggest: [] }
  let current = { key: '', vals: [], hints: [] }

  let existed = ''
  $: updated = existed != output
  $: [btn_power, prevail] = fix_power($self_power, current.power)
  $: [btn_class, btn_label] = fix_label(output, existed)

  let hints = []

  let value_elem // to be focused
  $: if ($actived) value_elem && value_elem.focus()
  // $: hints = make_hints(inquire, output)

  async function inquire_hanzi(hanzi) {
    const dnames = $dicts.map((x) => x[0])

    output = ''
    inquire = await dict_search(fetch, hanzi, dnames)
    hints = make_hints(inquire)
    update_val()
  }

  function change_tab(index) {
    $d_idx = index
    update_val()
  }

  function shoud_cap(index) {
    return $dicts[index][2]
  }

  function update_val(new_output = null) {
    current = inquire.entries[$d_idx] || { key: '', vals: [], hints: [] }
    if (current.key == '') return

    existed = current.vals[0]
    if (!new_output) new_output = existed

    if (new_output) {
      output = new_output
    } else {
      let new_output = inquire.hanviet
      if (shoud_cap($d_idx)) new_output = titleize(new_output, 9)

      if ($d_idx > 1 || hints.length == 0) output = new_output
      else output = hints[0]
    }

    value_elem.focus()
  }

  async function submit_val() {
    const dname = $dicts[$d_idx][0]
    const res = await dict_upsert(fetch, dname, hanzi, output.trim())

    $actived = false
    dirty = res.ok
  }

  function upcase_val(count = 100) {
    const new_val = titleize(output, count)
    update_val(new_val)
  }

  function handle_keydown(evt) {
    if (!$actived) return
    // evt.preventDefault()

    if (evt.keyCode == 13) {
      evt.preventDefault()
      return submit_val()
    }

    if (evt.keyCode == 27) return actived.set(false)

    if (!evt.altKey) return
    evt.preventDefault()

    switch (evt.key) {
      // change tab
      case 'x':
      case 'c':
      case 'v':

      // moving input range
      case 'h':
      case 'j':
      case 'k':
      case 'l':

      // capitalize
      case '1':
      case '2':
      case '3':
      case '4':
      case '0':

      // empty/restore
      case 'e':
      case 'r':
        let elem = holder.querySelector(`[data-kbd="${evt.key}"]`)
        if (elem) elem.click()
        break

      // manual mapping
      case '`':
        upcase_val(0)
        break

      // default:
      //   break
    }
  }

  function term_exists(inquire, index) {
    const current = inquire.entries[index]

    if (!current) return false
    return current.vals.length > 0
  }

  let holder
</script>

<div
  class="holder"
  tabindex="0"
  bind:this={holder}
  on:keydown={handle_keydown}
  on:click={() => ($actived = false)}>
  <div class="dialog" on:click|stopPropagation={() => value_elem.focus()}>
    <header class="header">
      <div class="hanzi">
        <UpsertInput {input} bind:lower bind:upper bind:output={hanzi} />
      </div>

      <button
        type="button"
        class="m-button _text"
        on:click={() => ($actived = false)}>
        <SvgIcon name="x" />
      </button>
    </header>

    <section class="tabs">
      {#each $dicts as [_dname, label], index}
        <span
          class="tab"
          class:_active={index == $d_idx}
          class:_exists={term_exists(inquire, index)}
          data-kbd={index == 0 ? 'x' : index == 1 ? 'c' : 'v'}
          on:click={() => change_tab(index)}>
          {label}
        </span>
      {/each}
    </section>

    <section class="body">
      <div class="output">
        <div class="hints">
          <span class="-hint" on:click={() => update_val(inquire.hanviet)}>
            {inquire.hanviet}
          </span>

          {#each hints as hint}
            {#if hint != output}
              <span
                class="-hint"
                class:_exist={hint == existed}
                on:click={() => update_val(hint)}>{hint}</span>
            {/if}
          {/each}

          <span class="-hint _right">[{inquire.binh_am}]</span>
        </div>

        <div class="value">
          <input
            lang="vi"
            type="text"
            name="value"
            class:_fresh={!existed}
            bind:this={value_elem}
            bind:value={output}
            autocomplete="off"
            autocapitalize={shoud_cap($d_idx) ? 'words' : 'off'} />
        </div>

        <div class="format">
          <button data-kbd="1" on:click={() => upcase_val(1)}>
            <span class="_show-sm">hoa</span>
            một chữ
          </button>

          <button data-kbd="2" on:click={() => upcase_val(2)}>hai chữ</button>

          <button
            class="_show-md"
            data-kbd="3"
            on:click={() => upcase_val(3)}>ba chữ</button>

          <button data-kbd="4" on:click={() => upcase_val(9)}>tất cả</button>

          <button data-kbd="0" on:click={() => upcase_val(0)}>không
            <span class="_show-sm"> hoa</span>
          </button>

          <button
            class="_right"
            data-kbd="e"
            on:click={() => (output = '')}>Xoá</button>

          {#if updated}
            <button
              class="_right"
              data-kbd="r"
              on:click={() => update_val(existed)}>
              Phục
            </button>
          {/if}
        </div>
      </div>

      <div class="action">
        {#if current && current.uname}
          <div class="latest">
            <span class="-text">Lưu:</span>
            <span class="-time"><RelTime time={current.mtime} /></span>
            <span class="-text">bởi</span>
            <span class="-user">{current.uname}</span>
            <span class="-text _hide">[Q.hạn {current.power}]</span>
          </div>
        {/if}

        <button
          class="m-button _{btn_class} _{btn_power} _right"
          disabled={!(updated || prevail)}
          on:click|once={submit_val}>
          <span class="-text">{btn_label}</span>
        </button>
      </div>
    </section>

    <footer>
      <UpsertLinks {hanzi} />
    </footer>
  </div>
</div>

<style lang="scss">
  $gutter: 0.75rem;

  .holder {
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

  .dialog {
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

    &._exists {
      @include fgcolor(neutral, 7);
    }

    &._active {
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

  .output {
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
      max-width: 25vw;
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

    font-size: rem(11px);

    @include screen-min(md) {
      font-size: rem(12px);
    }

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

    ._show-sm {
      display: none;
      @include screen-min(sm) {
        display: inline-block;
      }
    }

    ._show-md {
      display: none;
      @include screen-min(md) {
        display: inline-block;
      }
    }
  }

  .latest {
    font-style: italic;

    line-height: 2.25rem;
    @include fgcolor(neutral, 6);
    @include font-size(2);

    .-time,
    .-user {
      font-weight: 500;
      @include fgcolor(primary, 8);
    }

    ._hide {
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

    ._right {
      margin-left: auto;
    }
  }

  footer {
    border-top: 1px solid color(neutral, 3);
  }
</style>
