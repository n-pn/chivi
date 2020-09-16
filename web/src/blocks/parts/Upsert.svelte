<script context="module">
  function generate_hints(meta, reject, accept) {
    let res = [
      ...meta.dicts.special.vals,
      ...meta.dicts.special.hints,
      ...meta.dicts.generic.vals,
      ...meta.dicts.generic.hints,
      ...meta.suggest,
    ]
    if (accept && accept !== '') res.push(accept)

    return res.filter(
      (v, i, s) =>
        v !== reject && v.toLowerCase() !== meta.hanviet && s.indexOf(v) === i
    )
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

  const tabs = [
    ['special', 'VP riêng'],
    ['generic', 'VP chung'],
    ['hanviet', 'Hán việt'],
  ]

  export async function dict_search(fetch, key, dic = 'dich-nhanh') {
    const url = `/_dicts/search/${key}?dic=${dic}`
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

    const { _stt } = await res.json()
    return _stt
  }
</script>

<script>
  import AIcon from '$atoms/AIcon'
  import ARtime from '$atoms/ARtime'
  import UpsertFooter from './Upsert/Footer.svelte'

  import {
    self_uname,
    self_power,
    upsert_atab as atab,
    upsert_udic as udic,
    upsert_input,
    upsert_lower,
    upsert_upper,
    upsert_actived as actived,
    upsert_changed as changed,
  } from '$src/stores'

  $: lower = $upsert_lower
  $: upper = $upsert_upper
  $: input = $upsert_input.substring(lower, upper)
  $: if ($actived && input) preload_input(input)

  let val_field

  let meta = {
    dicts: {
      special: { vals: [], hints: [], mtime: 0, uname: '', power: 0 },
      generic: { vals: [], hints: [], mtime: 0, uname: '', power: 0 },
      hanviet: { vals: [], hints: [], mtime: 0, uname: '', power: 0 },
    },
    hanviet: '',
    binh_am: '',
    suggest: [],
  }

  $: current = meta.dicts[$atab]
  $: existed = current.vals[0] || ''
  $: updated = out_val != existed

  $: [prevail, btn_power] = compare_power($self_power, current.power)
  $: [btn_class, btn_label] = compare_value(out_val, existed)

  async function preload_input(input) {
    out_val = ''
    meta = await dict_search(fetch, input, $udic)
    update_val()
  }

  let out_val = ''
  let hints = []

  function change_tab(new_tab) {
    $atab = new_tab
    update_val()
  }

  function update_val(new_val) {
    new_val = new_val || meta.dicts[$atab].vals[0]

    if (new_val) {
      out_val = new_val
      hints = generate_hints(meta, out_val)
    } else {
      let new_val = meta.hanviet
      if ($atab == 'special') new_val = titleize(new_val, 9)

      hints = generate_hints(meta, new_val)

      if ($atab == 'hanviet' || hints.length == 0) out_val = new_val
      else {
        out_val = hints.pop()
        hints = hints
      }
    }

    val_field.focus()
  }

  async function submit_val() {
    const dic = $atab == 'special' ? $udic : $atab
    const res = await dict_upsert(fetch, dic, key.trim(), out_val.trim())

    $actived = false
    $changed = res === 'ok' && updated
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
      case 53:
      case 192:
        upcase_val(0)
        break

      case 88:
        change_tab('special')
        break

      case 67:
        change_tab('generic')
        break

      case 82:
        update_val(existed)
        break

      case 69:
        out_val = ''
        val_field.focus()
        break

      default:
        break
    }
  }

  function dec(caret, lower) {
    return caret == lower ? caret : caret - 1
  }

  function inc(caret, upper) {
    return caret == upper ? caret : caret + 1
  }

  function reset_bounds() {
    lower = $upsert_lower
    upper = $upsert_upper
  }
</script>

<svelte:window on:keydown={handle_keypress} />

<div
  class="holder"
  class:_active={$actived}
  on:click={() => actived.set(false)}>
  <div class="dialog" on:click|stopPropagation={() => val_field.focus()}>
    <header class="header">
      <button class="m-button _text" on:click={reset_bounds}>
        <AIcon name="rotate-ccw" />
      </button>

      <div class="hanzi">
        <button
          class="-btn"
          disabled={lower == 0}
          on:click={() => (lower -= 1)}>
          <AIcon name="chevron-left" />
        </button>

        <button
          class="-btn _bd"
          disabled={lower == upper - 1}
          on:click={() => (lower += 1)}>
          <AIcon name="chevron-right" />
        </button>

        <span class="-inp">
          <span class="-sub">{$upsert_input.substring(0, lower)}</span>
          <span class="-key">{input}</span>
          <span class="-sub">{$upsert_input.substring(upper)}</span>
        </span>

        <button
          class="-btn _bd"
          disabled={upper == lower + 1}
          on:click={() => (upper -= 1)}>
          <AIcon name="chevron-left" />
        </button>

        <button
          class="-btn"
          disabled={upper == $upsert_input.length}
          on:click={() => (upper += 1)}>
          <AIcon name="chevron-right" />
        </button>
      </div>

      <button
        type="button"
        class="m-button _text"
        on:click={() => actived.set(false)}>
        <AIcon name="x" />
      </button>
    </header>

    <section class="tabs">
      {#each tabs as [name, label]}
        <span
          class="tab"
          class:_active={name == $atab}
          on:click={() => change_tab(name)}>
          {label}
        </span>
      {/each}
    </section>

    <section class="body">
      <div class="output">
        <div class="hints">
          <span class="-hint" on:click={() => update_val(meta.hanviet)}>
            {meta.hanviet}
          </span>

          {#each hints as hint}
            <span class="-hint" on:click={() => update_val(hint)}>{hint}</span>
          {/each}

          <span class="-hint _right">[{meta.binh_am}]</span>
        </div>

        <input
          type="text"
          lang="vi"
          class="val-field"
          class:_fresh={!existed}
          name="value"
          id="val_field"
          on:keypress={handle_enter}
          bind:this={val_field}
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

      <div class="footer">
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

    <UpsertFooter {input} />
  </div>
</div>

<style lang="scss">
  $gutter: 0.75rem;

  .holder {
    display: none;
    &._active {
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

  $header-height: 2.75rem;
  $header-gutter: 0.25rem;
  $header-inner-height: 2.25rem;

  .header {
    display: flex;
    position: relative;
    padding: $header-gutter 0.25rem;
    // height: $header-height;

    .m-button {
      margin: 0.375rem;
      @include fgcolor(neutral, 6);
      &:hover {
        @include fgcolor(primary, 6);
      }
    }
  }

  .hanzi {
    display: inline-flex;
    margin: 0.375rem 0;

    height: $header-inner-height;
    line-height: $header-inner-height;
    flex-grow: 1;

    @include radius();

    @include bgcolor(neutral, 1);
    @include border($color: neutral, $shade: 3);

    > .-inp {
      flex-grow: 1;
      display: inline-flex;
      overflow: hidden;
      justify-content: center;
      @include fgcolor(neutral, 5);

      > .-key {
        font-weight: 500;
        @include fgcolor(neutral, 7);
      }
    }

    > .-btn {
      background: transparent;
      padding: 0 0.375rem;
      margin: 0;
      line-height: 1em;
      @include font-size(4);
      @include fgcolor(neutral, 7);

      &:hover {
        background-color: #fff;
        @include fgcolor(primary, 5);
      }

      &:disabled {
        cursor: pointer;
        @include fgcolor(neutral, 5);
        background: transparent;
      }

      &._bd {
        @include border($sides: left-right);
      }
    }
  }

  .tabs {
    // margin-top: 0.75rem;
    @include border($sides: bottom);
    @include flex($gap: 0.5rem);
    padding: 0 0.75rem;
    height: 2rem;
    line-height: 2rem;
    // justify-content: center;
  }

  .tab {
    cursor: pointer;
    text-transform: uppercase;
    font-weight: 500;
    padding: 0 0.75rem;
    height: 2rem;
    margin-top: 0.25px;

    @include font-size(2);
    @include fgcolor(neutral, 6);

    @include radius();
    @include radius(0, $sides: bottom);

    @include border($color: neutral);
    @include border($color: none, $sides: bottom);

    &._active {
      @include bgcolor(#fff);
      @include fgcolor(primary, 6);
      @include bdcolor($color: primary, $shade: 4);
      // @include bdwidth(2px, $sides: top);
      @include bdcolor($color: none, $sides: bottom);
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

      &:hover {
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

      &:hover {
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

  .footer {
    margin-top: 0.75rem;

    @include flex($gap: 0.5rem, $child: '.m-button');

    .m-button {
      margin-left: auto;
    }
  }
</style>
