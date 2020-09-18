<script context="module">
  function make_hints(search, reject, accept) {
    let res = []

    for (let { vals, hints } of search.entries) {
      for (let x of vals) res.push(x)
      for (let x of hints) res.push(x)
    }

    for (let x of search.suggest) res.push(x)
    if (accept) res.push(accept)

    return res.filter((v, i, s) => v !== reject && s.indexOf(v) === i)
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

  function compare_power(user, prev) {
    if (user < prev) return [false, 'text']
    else if (user == prev) return [false, 'line']
    else return [true, 'solid']
  }

  function compare_value(new_val, old_val) {
    if (new_val == '') return ['harmful', 'Xoá từ']
    else if (old_val == '') return ['success', 'Thêm từ']
    else return ['primary', 'Sửa từ']
  }

  export async function dict_search(fetch, hanzi, dicts = ['dich-nhanh']) {
    const url = `/_dicts/search/${hanzi}?dict=${dicts.join('|')}`
    const res = await fetch(url)
    const data = await res.json()

    return data
  }

  export async function dict_upsert(fetch, dic, key, val = '') {
    const url = `/_dicts/upsert/${dic}`
    const res = await fetch(url, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ key, val }),
    })

    return res
  }

  import {
    // self_uname,
    self_power,
    upsert_dicts as dicts,
    upsert_d_idx as d_idx,
    upsert_input,
    upsert_lower,
    upsert_upper,
    upsert_actived as actived,
  } from '$src/stores'

  import AIcon from '$atoms/AIcon'
  import ARtime from '$atoms/ARtime'

  import UpsertInput from './Upsert/Input.svelte'
  import UpsertLinks from './Upsert/Links.svelte'
</script>

<script>
  export let dirty = false

  $: lower = $upsert_lower
  $: upper = $upsert_upper
  $: hanzi = $upsert_input.substring(lower, upper)

  let value_elem

  // let cached = {}
  let search = {
    entries: [],
    hanviet: '',
    binh_am: '',
    suggest: [],
  }

  $: if ($actived && hanzi) inquire_hanzi(hanzi, false)

  $: current = search.entries[$d_idx] || { key: '', vals: [], hints: [] }
  $: existed = (current && current.vals[0]) || ''
  $: updated = out_val != existed

  $: if ($actived) value_elem && value_elem.focus()

  $: [prevail, btn_power] = compare_power($self_power, current.power)
  $: [btn_class, btn_label] = compare_value(out_val, existed)

  async function inquire_hanzi(hanzi, refresh = false) {
    // search = cached[hanzi]
    // if (search && !refresh) return

    const dnames = $dicts.map((x) => x[0])
    search = await dict_search(fetch, hanzi, dnames)

    // cached[hanzi] = search
    update_val()
  }

  let out_val = ''
  let hints = []

  function change_tab(index) {
    $d_idx = index
    update_val()
  }

  function update_val(new_val) {
    let current = search.entries[$d_idx]

    if (!new_val) {
      if (current) new_val = current.vals[0]
    }

    if (new_val) {
      out_val = new_val
      hints = make_hints(search, out_val)
    } else {
      let new_val = search.hanviet

      const [_1, _2, shoud_cap] = $dicts[$d_idx]
      if (shoud_cap) new_val = titleize(new_val, 9)

      hints = make_hints(search, new_val)

      if ($d_idx > 1 || hints.length == 0) out_val = new_val
      else {
        out_val = hints.pop()
        hints = hints
      }
    }

    value_elem.focus()
  }

  async function submit_val() {
    const dname = $dicts[$d_idx][0]
    const res = await dict_upsert(fetch, dname, input, out_val.trim())

    $actived = false
    dirty = res.ok
  }

  function upcase_val(count = 100) {
    const new_val = titleize(out_val, count)
    update_val(new_val)
  }

  function handle_enter(evt) {
    if (evt.keyCode == 13) {
      evt.preventDefault()
      return submit_val()
    }
  }

  function handle_keypress(evt) {
    if (!$actived) return
    // evt.preventDefault()

    if (evt.keyCode == 13) {
      evt.preventDefault()
      return submit_val()
    }

    if (evt.keyCode === 27) {
      evt.preventDefault()
      return actived.set(false)
    }

    if (!evt.altKey) return
    evt.preventDefault()

    switch (evt.keyCode) {
      case 49:
        upcase_val(1)
        break

      case 50:
        upcase_val(2)
        break

      case 51:
        upcase_val(3)
        break

      case 52:
        upcase_val(9)
        break

      case 48:
      case 192:
        upcase_val(0)
        break

      case 88:
        change_tab(0)
        break

      case 67:
        change_tab(1)
        break

      case 82:
        update_val(existed)
        break

      case 69:
        out_val = ''
        value_elem.focus()
        break

      default:
        break
    }
  }

  function term_exists(search, index) {
    const entry = search.entries[index]

    if (!entry) return false
    return entry.vals.length > 0
  }
</script>

<svelte:window />

<div
  class="holder"
  tabindex="0"
  on:keydown={handle_keypress}
  on:click={() => actived.set(false)}>
  <div class="dialog" on:click|stopPropagation={() => value_elem.focus()}>
    <header class="header">
      <div class="hanzi">
        <UpsertInput
          input={$upsert_input}
          bind:lower
          bind:upper
          bind:output={hanzi} />
      </div>
      <button
        type="button"
        class="m-button _text"
        on:click={() => actived.set(false)}>
        <AIcon name="x" />
      </button>
    </header>

    <section class="tabs">
      {#each $dicts as [_dname, label], index}
        <span
          class="tab"
          class:_active={index == $d_idx}
          class:_exists={term_exists(search, index)}
          on:click={() => change_tab(index)}>
          {label}
        </span>
      {/each}
    </section>

    <section class="body">
      <div class="output">
        <div class="hints">
          <span class="-hint" on:click={() => update_val(search.hanviet)}>
            {search.hanviet}
          </span>

          {#each hints as hint}
            <span class="-hint" on:click={() => update_val(hint)}>{hint}</span>
          {/each}

          <span class="-hint _right">[{search.binh_am}]</span>
        </div>

        <input
          type="text"
          lang="vi"
          class="val-field"
          class:_fresh={!existed}
          name="value"
          on:keypress={handle_enter}
          bind:this={value_elem}
          bind:value={out_val} />

        <div class="format">
          <span class="-lbl _show-sm">V.hoa:</span>
          <span class="-btn" on:click={() => upcase_val(1)}>Một chữ</span>
          <span class="-btn" on:click={() => upcase_val(2)}>Hai chữ</span>
          <span class="-btn _show-md" on:click={() => upcase_val(3)}>Ba chữ</span>
          <span class="-btn" on:click={() => upcase_val(9)}>Tất cả</span>
          <span class="-btn" on:click={() => upcase_val(0)}>Không</span>

          <span class="-btn _right" on:click={() => (out_val = '')}>Xoá</span>

          {#if updated}
            <span class="-btn _right" on:click={() => update_val(existed)}>
              Phục
            </span>
          {/if}
        </div>
      </div>

      <div class="action">
        {#if current.uname != ''}
          <div class="edit">
            <span class="-text">Lưu:</span>
            <span class="-time"><ARtime time={current.mtime} /></span>
            <span class="-text">bởi</span>
            <span class="-user">{current.uname}</span>
            <span class="-text _hide">[Q.hạn {current.power}]</span>
          </div>
        {/if}

        <button
          type="button"
          class="m-button _{btn_class} _{btn_power}"
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
    @include bgcolor(rgba(#000, 0.65));
  }

  .dialog {
    width: rem(30);
    min-width: 320px;
    max-width: 100%;
    // margin-top: -10%;
    @include bgcolor(neutral, 1);
    @include radius();
    @include shadow(3);
  }

  header {
    display: flex;
    padding: 0.75rem;

    > button {
      @include fgcolor(neutral, 6);
      @include hover {
        @include fgcolor(primary, 6);
      }
    }

    > .hanzi {
      margin-right: 0.5rem;
      flex-grow: 1;
    }
  }

  .tabs {
    // margin-top: 0.75rem;
    @include border($sides: bottom);
    @include flex($gap: 0.75rem);
    padding: 0 0.75rem;
    height: 2rem;
    line-height: 2rem;
    // flex: auto 1 1;
    // justify-content: center;
  }

  .tab {
    cursor: pointer;
    text-transform: uppercase;
    font-weight: 500;
    padding: 0 0.75rem;
    height: 2rem;
    margin-top: 0.25px;

    @include truncate(null);
    @include font-size(2);
    @include fgcolor(neutral, 5);

    @include radius();
    @include radius(0, $sides: bottom);

    @include border($color: neutral);
    @include border($color: none, $sides: bottom);

    &._exists {
      @include fgcolor(neutral, 7);
    }

    &._active {
      @include bgcolor(#fff);
      @include fgcolor(primary, 6);
      @include bdcolor($color: primary, $shade: 4);
      // @include bdwidth(2px, $sides: top);
      @include bdcolor($color: none, $sides: bottom);
    }

    flex-shrink: 0;
    &:first-child {
      flex-shrink: 1;
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

  .val-field {
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

    @include border();
    border-bottom: none;
    @include radius($sides: top);

    @include flex($gap: 0.25rem, $child: '.-hint');
    @include font-size(2);

    .-hint {
      cursor: pointer;
      font-style: italic;
      line-height: 1.5rem;
      height: 1.5rem;

      padding: 0 0.25rem;
      max-width: 25vw;
      @include truncate(null);

      @include fgcolor(neutral, 6);
      @include bgcolor(neutral, 1);
      @include radius;

      @include hover {
        @include fgcolor(primary, 6);
        @include bgcolor(primary, 1);
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

    @include clearfix;

    @include border();
    border-top: none;
    @include radius($sides: bottom);

    font-size: rem(11px);

    @include screen-min(md) {
      font-size: rem(12px);
    }

    .-lbl,
    .-btn {
      float: left;
      padding: 0 0.375rem;
      line-height: $height;
      font-weight: 500;
      text-transform: uppercase;

      @include fgcolor(neutral, 5);
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

    .-btn {
      cursor: pointer;

      // max-width: 14vw;
      @include truncate(null);

      @include hover {
        @include fgcolor(primary, 5);
        @include bgcolor(white);
      }

      &._right {
        float: right;
      }
    }
  }

  .edit {
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

    @include flex($gap: 0.5rem, $child: '.m-button');

    .m-button {
      margin-left: auto;
    }
  }

  footer {
    border-top: 1px solid color(neutral, 3);
  }
</style>
